#import "ZHXMLWordWrap.h"

@implementation ZHXMLWordWrap
- (NSString *)description{
    return @"请将要整理的代码文件或者工程路径拖到这个输入框中";
}

- (void)Begin:(NSString *)str{
    NSString *filePath=str;
    switch ([ZHFileManager getFileType:filePath]) {
        case FileTypeNotExsit:
        {
            NSLog(@"%@",@"路劲不存在");
        }
            break;
        case FileTypeFile:
        {
            if ([filePath hasSuffix:@".m"]||[filePath hasSuffix:@".h"]) {
                [self wordWrapFile:filePath];
                NSLog(@"%@",@"整理代码完毕!");
            }else{
                NSLog(@"%@",@"文件不是.h或者.m文件,无法整理代码!");
            }
        }
            break;
        case FileTypeDirectory:
        {
            NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m",@".xml"]];
            NSUInteger sum=0;
            for (NSString *fileName in fileArr) {
                [self wordWrapFile:fileName];
                sum++;
            }
            NSLog(@"%@",[NSString stringWithFormat:@"共处理了:%ld个编程文件",sum]);
        }
            break;
        case FileTypeUnkown:
        {
            NSLog(@"%@",@"文件类型未知,无法整理代码");
        }
            break;
    }
}

- (void)wordWrap:(NSString *)path{
    [self Begin:path];
}

- (NSString *)wordWrapText:(NSString *)text{
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        if (str.length>0) {
            [arrM addObject:[ZHNSString removeSpacePrefix:str]];
        }else{
            [arrM addObject:@""];
        }
    }
    
    NSInteger count=0;
    
    NSString *tempStr;
    
    NSMutableArray *arrMText=[NSMutableArray array];
    
    for (NSString *str in arrM) {
        if ([str hasPrefix:@"<?"]) {//如果是注释,不做处理
            [arrMText addObject:[[self getIndentationWithCount:count] stringByAppendingString:str]];
        }else{
            if (str.length>0) {
                
                tempStr=[ZHNSString removeSpaceSuffix:str];
                
                if([self hasOutIndex:tempStr]==1){
                    [arrMText addObject:[[self getIndentationWithCount:count] stringByAppendingString:tempStr]];
                }
                
                if ([self hasOutIndex:tempStr]>0){
                    count--;
                    if (count==-1)count=0;
                }
                
                if([self hasOutIndex:tempStr]!=1){
                    [arrMText addObject:[[self getIndentationWithCount:count] stringByAppendingString:tempStr]];
                }
                
                if ([self hasInIndex:tempStr]) {
                    count++;
                }
                
            }else{
                [arrMText addObject:[self getIndentationWithCount:count]];
            }
        }
    }
    
    text=[arrMText componentsJoinedByString:@"\n"];
    return text;
}

- (void)wordWrapFile:(NSString *)fileName{
    NSString *text=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    text=[self wordWrapText:text];
    [text writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (int)hasOutIndex:(NSString *)text{
    NSArray *arr=@[@"/>"];
    for (NSString *str in arr) {
        if ([text hasSuffix:str]) {
            return 1;
        }
    }
    
    NSArray *arrPrefix=@[@"</"];
    for (NSString *str in arrPrefix) {
        if ([text hasPrefix:str]) {
            return 2;
        }
    }
    
    return 0;
}
- (BOOL)hasInIndex:(NSString *)text{
    NSArray *arr=@[@"<"];
    for (NSString *str in arr) {
        if ([text hasPrefix:str]&&![text hasPrefix:@"</"]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getIndentationWithCount:(NSInteger)count{
    NSMutableString *strM=[NSMutableString string];
    for (NSInteger i=0; i<count; i++) {
        [strM appendString:@"\t"];
    }
    return strM;
}
@end
