
#import "ResourceFileSearcher.h"
#import "StringUtils.h"
#import "FileUtils.h"
#import "CMStringUtils.h"

NSString * const kNotificationResourceFileQueryDone = @"kNotificationResourceFileQueryDone";

static NSString * const kSuffixImageSet    = @".imageset";
static NSString * const kSuffixLaunchImage = @".launchimage";
static NSString * const kSuffixAppIcon     = @".appiconset";
static NSString * const kSuffixBundle      = @".bundle";
static NSString * const kSuffixPng         = @".png";


@implementation ResourceFileInfo

@end


@interface ResourceFileSearcher ()

@property (assign, nonatomic) BOOL isRunning;
@property (strong, nonatomic) NSMutableDictionary *resNameInfoDict;
@end


@implementation ResourceFileSearcher

+ (instancetype)sharedObject {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (void)startWithProjectPath:(NSString *)projectPath excludeFolders:(NSArray *)excludeFolders resourceSuffixs:(NSArray *)resourceSuffixs {
    if (self.isRunning) {
        return;
    }
    if (projectPath.length == 0 || resourceSuffixs.count == 0) {
        return;
    }
    
    self.isRunning = YES;
    
    [self scanResourceFileWithProjectPath:projectPath excludeFolders:excludeFolders resourceSuffixs:resourceSuffixs];
}

- (void)reset {
    self.isRunning = NO;
    [self.resNameInfoDict removeAllObjects];
}

- (BOOL)isImageSetFolder:(NSString *)folder
{
    if ([folder hasSuffix:kSuffixImageSet]
        || [folder hasSuffix:kSuffixAppIcon]
        || [folder hasSuffix:kSuffixLaunchImage]) {
        return YES;
    }
    return NO;
}

- (BOOL)isInImageSetFolder:(NSString *)folder
{
    if (![self isImageSetFolder:folder]
        && ([folder rangeOfString:kSuffixImageSet].location != NSNotFound
        || [folder rangeOfString:kSuffixAppIcon].location != NSNotFound
        || [folder rangeOfString:kSuffixLaunchImage].location != NSNotFound)) {
        return YES;
    }
    return NO;
}

#pragma mark - Private

- (void)scanResourceFileWithProjectPath:(NSString *)projectPath excludeFolders:(NSArray *)excludeFolders resourceSuffixs:(NSArray *)resourceSuffixs {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *resPaths = [self resourceFilesInDirectory:projectPath excludeFolders:excludeFolders resourceSuffixs:resourceSuffixs];
        NSMutableDictionary *tempResNameInfoDict = [NSMutableDictionary dictionary];
        for (NSString *path in resPaths) {
            NSString *name = [path lastPathComponent];
            if (!name.length) {
                continue;
            }
            
            NSString *keyName = [StringUtils stringByRemoveResourceSuffix:name];

            if (!tempResNameInfoDict[keyName]) {
                BOOL isDir = NO;
                ResourceFileInfo *info = [ResourceFileInfo new];
                info.name = name;
                info.path = path;
                info.fileSize = [FileUtils fileSizeAtPath:path isDir:&isDir];
                info.isDir = isDir;
                tempResNameInfoDict[keyName] = info;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resNameInfoDict = tempResNameInfoDict;
            self.isRunning = NO;
            [ZHBlockSingleCategroy runBlockNULLIdentity:@"kNotificationResourceFileQueryDone"];
        });
    });
}

- (NSArray *)resourceFilesInDirectory:(NSString *)directoryPath excludeFolders:(NSArray *)excludeFolders resourceSuffixs:(NSArray *)suffixs {
    
    NSMutableArray *resources = [NSMutableArray array];
    
    NSArray *pathList = [CMStringUtils images:directoryPath];
    for (NSString *str in pathList) {
        NSLog(@"%@",str);
    }
    //running1
    if (pathList.count) {
        for (NSString *path in pathList) {
            if (![self isInImageSetFolder:path]
                && [path rangeOfString:kSuffixBundle].location == NSNotFound) {
                [resources addObject:path];
            }
        }
    }
    
    return resources;
}

@end
