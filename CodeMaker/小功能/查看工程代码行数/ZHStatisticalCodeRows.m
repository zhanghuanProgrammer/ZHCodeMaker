#import "ZHStatisticalCodeRows.h"

@implementation ZHStatisticalCodeRows

+ (NSString *)Begin:(NSString *)path{
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
                return [NSString stringWithFormat:@"总行数:%ld(不包空行)",[self fileRows:filePath]];
            }else{
                return @"不是OC编程文件";
            }
        }
            break;
        case FileTypeDirectory:
        {
            NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m"]];
            NSUInteger sum=0;
            for (NSString *fileName in fileArr) {
                sum+=[self fileRows:fileName];
            }
            return [NSString stringWithFormat:@"总行数:%ld(不包空行)",sum];
        }
            break;
        case FileTypeUnkown:
        {
            return @"文件类型未知";
        }
            break;
    }
}

+ (NSInteger)fileRows:(NSString *)filePath{
    NSString *content=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *arr=[content componentsSeparatedByString:@"\n"];
    NSInteger count=0;
    for (NSString *str in arr) {
        if (str.length>0) {
            count++;
        }
    }
    return count;
}

@end
