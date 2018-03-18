#import "CodeCounter.h"

/**此文件从Java代码中翻译而来*/

@interface CodeCounter ()

@property (nonatomic,assign)NSInteger commentLine;
@property (nonatomic,assign)NSInteger whiteLine;
@property (nonatomic,assign)NSInteger normalLine;
@property (nonatomic,assign)NSInteger totalLine;
@property (nonatomic,assign)BOOL comment;

@end

@implementation CodeCounter

- (instancetype)init{
    self = [super init];
    if (self) {
        self.commentLine=self.whiteLine=self.normalLine=self.totalLine=0;
        self.comment=NO;
    }
    return self;
}

- (NSString *)codeCounter:(NSString *)path{
    NSString *filePath=path;
    switch ([ZHFileManager getFileType:filePath]) {
        case FileTypeNotExsit:
        {
            return @"路劲不存在";
        }
            break;
        case FileTypeFile:
        {
            if ([filePath hasSuffix:@".m"]||[filePath hasSuffix:@".h"]) {
                [self statistical:filePath];
                return [NSString stringWithFormat:@"有效代码行数: %zd\n注释行数: %zd\n空白行数: %zd\n总代码行数: %zd\n",self.normalLine,self.commentLine,self.whiteLine,self.totalLine];
            }else{
                return @"不是OC编程文件";
            }
        }
            break;
        case FileTypeDirectory:
        {
            NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m"]];
            for (NSString *subFilePath in fileArr) {
                [self statistical:subFilePath];
            }
            return [NSString stringWithFormat:@"有效代码行数: %zd\n注释行数: %zd\n空白行数: %zd\n总代码行数: %zd\n",self.normalLine,self.commentLine,self.whiteLine,self.totalLine];
        }
            break;
        case FileTypeUnkown:
        {
            return @"文件类型未知";
        }
            break;
    }
}


- (void)statistical:(NSString *)filePath{
    NSString *content=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *arr=[content componentsSeparatedByString:@"\n"];
    for (NSString *line in arr) {
        [self parse:line];
    }
}

- (void)parse:(NSString *)line{
    line=[ZHNSString removeSpaceBeforeAndAfterWithString:line];
    line=[ZHNSString removeSpacePrefix:line];
    line=[ZHNSString removeSpaceSuffix:line];
    self.totalLine++;
    if (line.length == 0) {
        self.whiteLine++;
    } else if (self.comment) {
        self.commentLine++;
        if ([line hasSuffix:@"*/"]) {
            self.comment = false;
        } else if ([ZHNSString matches:@".*\\*/.+" text:line]) {
            self.normalLine++;
            self.comment = false;
        }
    } else if ([line hasPrefix:@"//"]) {
        self.commentLine++;
    } else if ([ZHNSString matches:@".+//.*" text:line]) {
        self.commentLine++;
        self.normalLine++;
    } else if ([line hasPrefix:@"/*"] &&[ZHNSString matches:@".+\\*/.+" text:line]) {
        self.commentLine++;
        self.normalLine++;
        if ([self findPair:line]) {
            self.comment = false;
        } else {
            self.comment = true;
        }
    } else if ([line hasPrefix:@"/*"] && ![line hasSuffix:@"*/"]) {
        self.commentLine++;
        self.comment = true;
    } else if ([line hasPrefix:@"/*"] && [line hasSuffix:@"*/"]) {
        self.commentLine++;
        self.comment = false;
    } else if ([ZHNSString matches:@".+/\\*.*" text:line] && ![line hasSuffix:@"*/"]) {
        self.commentLine++;
        self.normalLine++;
        if ([self findPair:line]) {
            self.comment = false;
        } else {
            self.comment = true;
        }
    } else if ([ZHNSString matches:@".+/\\*.*" text:line] && [line hasSuffix:@"*/"]) {
        self.commentLine++;
        self.normalLine++;
        self.comment = false;
    } else {
        self.normalLine++;
    }
}

- (BOOL)findPair:(NSString *)line{// 查找一行中/*与*/是否成对出现
    NSInteger count1 = [ZHNSString getCountTargetString:@"/*" inText:line];
    NSInteger count2 = [ZHNSString getCountTargetString:@"*/" inText:line];
    return (count1 == count2);
}

@end
