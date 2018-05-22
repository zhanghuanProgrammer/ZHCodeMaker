
#import "ResourceStringSearcher.h"
#import "ResourceFileSearcher.h"
#import "StringUtils.h"

NSString * const kNotificationResourceStringQueryDone = @"kNotificationResourceStringQueryDone";

static NSString * const kPatternIdentifyEnable      = @"PatternEnable";
static NSString * const kPatternIdentifySuffix      = @"PatternSuffix";
static NSString * const kPatternIdentifyRegex       = @"PatternRegex";
static NSString * const kPatternIdentifyGroupIndex  = @"PatternGroupIndex";

#pragma mark - ResourceStringPattern

@implementation ResourceStringPattern

- (id)initWithDictionary:(NSDictionary *)dict;
{
    if (self = [super init]) {
        _suffix = dict[kPatternIdentifySuffix];
        _enable = [dict[kPatternIdentifyEnable] boolValue];
        _regex = dict[kPatternIdentifyRegex];
        _groupIndex = [dict[kPatternIdentifyGroupIndex] integerValue];
    }
    return self;
}

@end

#pragma mark - ResourceStringSearcher

@interface ResourceStringSearcher ()

@property (strong, nonatomic) NSMutableSet *resStringSet;
@property (strong, nonatomic) NSString *projectPath;
@property (strong, nonatomic) NSArray *resSuffixs;
@property (strong, nonatomic) NSArray *excludeFolders;
@property (strong, nonatomic) NSMutableDictionary *fileSuffixToResourcePatterns;
@property (assign, nonatomic) BOOL isRunning;

@end


@implementation ResourceStringSearcher

+ (instancetype)sharedObject {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)startWithProjectPath:(NSString *)projectPath excludeFolders:(NSArray *)excludeFolders resourceSuffixs:(NSArray *)resourceSuffixs resourcePatterns:(NSArray *)resourcePatterns {
    if (self.isRunning) {
        return;
    }
    if (projectPath.length == 0 || resourcePatterns.count == 0) {
        return;
    }
    
    self.isRunning = YES;
    self.projectPath = projectPath;
    self.resSuffixs = resourceSuffixs;
    self.excludeFolders = excludeFolders;
    
    self.fileSuffixToResourcePatterns = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in resourcePatterns) {
        ResourceStringPattern *pattern = [[ResourceStringPattern alloc] initWithDictionary:dict];
        if (pattern.enable) {
            [self.fileSuffixToResourcePatterns setObject:pattern forKey:pattern.suffix];
        }
    }
    
    [self runSearchTask];
}

- (void)reset {
    self.isRunning = NO;
    [self.resStringSet removeAllObjects];
}

- (BOOL)containsResourceName:(NSString *)name {
    if ([self.resStringSet containsObject:name]) {
        return YES;
    } else {
        if ([name pathExtension]) {
            NSString *nameWithoutSuffix = [StringUtils stringByRemoveResourceSuffix:name];
            return [self.resStringSet containsObject:nameWithoutSuffix];
        }
    }
    return NO;
}

- (BOOL)containsSimilarResourceName:(NSString *)name {
    NSString *regexStr = @"([-_]?\\d+)";
    NSRegularExpression* regexExpression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* matchs = [regexExpression matchesInString:name options:0 range:NSMakeRange(0, name.length)];
    if (matchs != nil && [matchs count] == 1) {
        NSTextCheckingResult *checkingResult = [matchs objectAtIndex:0];
        NSRange numberRange = [checkingResult rangeAtIndex:1];
        
        NSString *prefix = nil;
        NSString *suffix = nil;
        
        BOOL hasSamePrefix = NO;
        BOOL hasSameSuffix = NO;
        
        if (numberRange.location != 0) {
            prefix = [name substringToIndex:numberRange.location];
        } else {
            hasSamePrefix = YES;
        }
        
        if (numberRange.location + numberRange.length < name.length) {
            suffix = [name substringFromIndex:numberRange.location + numberRange.length];
        } else {
            hasSameSuffix = YES;
        }
        
        for (NSString *res in self.resStringSet) {
            if (hasSameSuffix && !hasSamePrefix) {
                if ([res hasPrefix:prefix]) {
                    return YES;
                }
            }
            if (hasSamePrefix && !hasSameSuffix) {
                if ([res hasSuffix:suffix]) {
                    return YES;
                }
            }
            if (!hasSamePrefix && !hasSameSuffix) {
                if ([res hasPrefix:prefix] && [res hasSuffix:suffix]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSArray *)createDefaultResourcePatternsWithResourceSuffixs:(NSArray *)resSuffixs {
    NSArray *enables = @[@1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1];
    NSArray *fileSuffixs = @[@"h", @"m", @"mm", @"swift", @"xib", @"storyboard", @"strings", @"c", @"cpp", @"html", @"js", @"json", @"plist", @"css"];
    
    NSString *cPattern = [NSString stringWithFormat:@"([a-zA-Z0-9_-]*)\\.(%@)", [resSuffixs componentsJoinedByString:@"|"]]; // *.(png|gif|jpg|jpeg)
    NSString *ojbcPattern = @"@\"(.*?)\""; // @"imageNamed:@\"(.+)\"";//or: (imageNamed|contentOfFile):@\"(.*)\" // http://www.raywenderlich.com/30288/nsregularexpression-tutorial-and-cheat-sheet
    NSString *xibPattern = @"image name=\"(.+?)\""; // image name="xx"
    
    NSArray *filePatterns = @[cPattern,    // .h
                              ojbcPattern, // .m
                              ojbcPattern, // .mm
                              @"\"(.*?)\"",// swift.
                              xibPattern,  // .xib
                              xibPattern,  // .storyboard
                              @"=\\s*\"(.*)\"\\s*;",  // .strings
                              cPattern,    // .c
                              cPattern,    // .cpp
                              @"img\\s+src=[\"\'](.*?)[\"\']", // .html, <img src="xx"> <img src='xx'>
                              @"[\"\']src[\"\'],\\s+[\"\'](.*?)[\"\']", // .js,  "src", "xx"> 'src', 'xx'>
                              @":\\s*\"(.*?)\"", // .json, "xx"
                              @">(.*?)<",  // .plist, "<string>xx</string>"
                              cPattern];   // .css
    
    NSArray *matchGroupIndexs = @[@1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1, @1];
    
    NSMutableArray *patterns = [NSMutableArray array];
    for (NSInteger index = 0; index < fileSuffixs.count; ++ index) {
        [patterns addObject:@{kPatternIdentifyEnable: enables[index],
                              kPatternIdentifySuffix: fileSuffixs[index],
                              kPatternIdentifyRegex: filePatterns[index],
                              kPatternIdentifyGroupIndex: matchGroupIndexs[index]}];
    }
    
    return patterns;
}

- (NSDictionary *)createEmptyResourcePattern {
    return @{kPatternIdentifyEnable: @(1),
             kPatternIdentifySuffix: @"tmp",
             kPatternIdentifyRegex: @"(.+)",
             kPatternIdentifyGroupIndex: @(1)};
}

#pragma mark - Private

- (void)runSearchTask {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.resStringSet = [NSMutableSet set];
        [self handleFilesAtPath:self.projectPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isRunning = NO;
            [ZHBlockSingleCategroy runBlockNULLIdentity:@"kNotificationResourceStringQueryDone"];
        });
    });
}

- (BOOL)handleFilesAtPath:(NSString *)dir {
    // Get all files at the dir
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error];
    if (files.count == 0) {
        return NO;
    }
    
    for (NSString *file in files) {
        if ([file hasPrefix:@"."]) {
            continue;
        }
        if ([self.excludeFolders containsObject:file]) {
            continue;
        }
        
        NSString *tempPath = [dir stringByAppendingPathComponent:file];
        if ([self isDirectory:tempPath]) {
            [self handleFilesAtPath:tempPath];
        } else {
            NSString *ext = [[file pathExtension] lowercaseString];
            ResourceStringPattern *resourcePattern = self.fileSuffixToResourcePatterns[ext];
            if (!resourcePattern) {
                continue;
            }
            [self parseFileAtPath:tempPath withResourcePattern:resourcePattern];
        }
    }
    return YES;
}

- (void)parseFileAtPath:(NSString *)path withResourcePattern:(ResourceStringPattern *)resourcePattern {
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!content) {
        return;
    }

    if (resourcePattern.regex.length && resourcePattern.groupIndex >= 0) {
        NSSet *set = [self getMatchStringWithContent:content pattern:resourcePattern.regex groupIndex:resourcePattern.groupIndex];
        [self.resStringSet unionSet:set];
    }
}

- (NSSet *)getMatchStringWithContent:(NSString *)content pattern:(NSString*)pattern groupIndex:(NSInteger)index {
    NSRegularExpression *regexExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray* matchs = [regexExpression matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    if (matchs.count) {
        NSMutableSet *set = [NSMutableSet set];
        for (NSTextCheckingResult *checkingResult in matchs) {
            NSString *res = [content substringWithRange:[checkingResult rangeAtIndex:index]];
            if (res.length) {
                res = [res lastPathComponent];
                res = [StringUtils stringByRemoveResourceSuffix:res];
                [set addObject:res];
            }
        }
        return set;
    }
    
    return nil;
}

- (BOOL)isDirectory:(NSString *)path {
    // Ignore x.imageset/Contents.json
    if ([[ResourceFileSearcher sharedObject] isImageSetFolder:path]) {
        return NO;
    }
    BOOL isDirectory;
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
}

@end
