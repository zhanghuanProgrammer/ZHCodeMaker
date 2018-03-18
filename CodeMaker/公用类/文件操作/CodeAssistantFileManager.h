//这个类其实就是单纯的处理桌面上的 代码助手.m 文件

#import <Foundation/Foundation.h>

@interface CodeAssistantFileManager : NSObject

/**删除*/
+ (void)removeFile;
/**清空*/
+ (void)clearnFileContent;
/**读取里面的内容,不作任何处理*/
+ (NSString *)getFileContent;
/**存入内容*/
+ (void)saveContent:(NSString *)content;
/**读取里面的数据,返回Json转换成的NSDictionary*/
+ (NSDictionary *)getJsonDicFromFile;
/**保存其数据到Log日志里去*/
+ (void)saveFileContentToLog;
/**获取文件路径*/
+ (NSString *)getPath;
/**获取文件里所有文件路径*/
+ (NSArray *)getFilePaths;
/**读取其它文件里面的内容,不作任何处理*/
+ (NSString *)getOtherFileContent:(NSString *)filePath;
/**保存其它文件里面的内容*/
+ (void)saveOtherFileContent:(NSString *)content toFilePath:(NSString *)filePath;
@end
