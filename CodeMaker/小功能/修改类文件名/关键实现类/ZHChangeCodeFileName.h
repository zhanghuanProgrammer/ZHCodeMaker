#import <Foundation/Foundation.h>

@interface ZHChangeCodeFileName : NSObject

/**从路径中获取可修改的文件名*/
+ (NSArray *)getChangeNamesFromFilePath:(NSString *)filePath;

/**分析并拿取就文件名字和设置新名字的json字符串*/
+ (NSString *)getOldNameAndSetString:(NSString *)filePath;

/**给具体路径拿取就文件名字和设置新名字的json字符串*/
+ (NSString *)getOldNameAndSetStringByPathArr:(NSArray *)pathArr;

/**修改多个文件*/
+ (NSString *)changeMultipleCodeFileName:(NSString *)path;

/**修改单个文件*/
+ (NSString *)changeSingleFile:(NSString *)oldPath newPath:(NSString *)newPath;
@end
