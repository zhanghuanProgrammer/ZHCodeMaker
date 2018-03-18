#import "CodeAssistantFileManager.h"

@implementation CodeAssistantFileManager

/**删除*/
+ (void)removeFile{
    [ZHFileManager removeItemAtPath:[self getPath]];
}

/**清空*/
+ (void)clearnFileContent{
    [@"" writeToFile:[self getPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

/**读取里面的内容,不作任何处理*/
+ (NSString *)getFileContent{
    NSString *text=[NSString stringWithContentsOfFile:[self getPath] encoding:NSUTF8StringEncoding error:nil];
    if ([text hasSuffix:@"\n"]) {
        text=[text substringToIndex:text.length-1];
    }
    if (StringIsEmpty(text)) text=@"";
    return text;
}

/**存入内容*/
+ (void)saveContent:(NSString *)content{
    [content writeToFile:[self getPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

/**读取里面的数据,返回Json转换成的NSDictionary*/
+ (NSDictionary *)getJsonDicFromFile{
    NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:[[self getFileContent] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    return jsonDic;
}

/**保存其数据到Log日志里去*/
+ (void)saveFileContentToLog{
    NSString *text=[self getFileContent];
    
    NSString *filePath=[[ZHFileManager getMacDesktop] stringByAppendingPathComponent:@"Log.m"];
    if ([ZHFileManager fileExistsAtPath:filePath]==NO) {
        [ZHFileManager createFileAtPath:filePath];
    }
    NSString *content=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *curTime=[DateTools getDateString:[NSDate date]];
    curTime=[@"#pragma mark -----------"stringByAppendingString:curTime];
    curTime=[curTime stringByAppendingString:@"-----------\n"];
    text=[curTime stringByAppendingString:text];
    text=[text stringByAppendingString:@"\n"];
    content=[text stringByAppendingString:content];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self saveTheLatestCode];
}

/**如果日志里的行数已经超过10000行,只保留最新的10000行代码*/
+ (void)saveTheLatestCode{
    NSString *content=[self getFileContent];
    NSArray *arr=[content componentsSeparatedByString:@"\n"];
    if (arr.count<10000) {
        return;
    }
    NSMutableArray *arrM=[NSMutableArray array];
    NSInteger count=0;
    for (NSString *str in arr) {
        count++;
        if (count<=10000) {
            [arrM addObject:str];
        }else{
            break;
        }
    }
    [self saveContent:[arrM componentsJoinedByString:@"\n"]];
}

/**获取文件路径*/
+ (NSString *)getPath{
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    if (![ZHFileManager fileExistsAtPath:macDesktopPath]) {
        [@"" writeToFile:macDesktopPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    return macDesktopPath;
}

/**获取文件里所有文件路径*/
+ (NSArray *)getFilePaths{
    NSString *text=[self getFileContent];
    NSMutableArray *filePaths=[NSMutableArray array];
    for (NSString *filePath in [text componentsSeparatedByString:@"\n"]) {
        if (filePath.length>0&&[ZHFileManager fileExistsAtPath:filePath]) {
            [filePaths addObject:filePath];
        }
    }
    return filePaths;
}

/**读取其它文件里面的内容,不作任何处理*/
+ (NSString *)getOtherFileContent:(NSString *)filePath{
    NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if ([text hasSuffix:@"\n"]) {
        text=[text substringToIndex:text.length-1];
    }
    if (StringIsEmpty(text)) text=@"";
    return text;
}

/**保存其它文件里面的内容*/
+ (void)saveOtherFileContent:(NSString *)content toFilePath:(NSString *)filePath{
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
