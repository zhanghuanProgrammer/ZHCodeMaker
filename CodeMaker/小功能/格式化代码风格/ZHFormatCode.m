#import "ZHFormatCode.h"

@implementation ZHFormatCode
+ (NSString *)formatCodeFilePath:(NSString *)filePath{
    switch ([ZHFileManager getFileType:filePath]) {
        case FileTypeNotExsit:
        {
            return @"路劲不存在";
        }
            break;
        case FileTypeFile:
        {
            if ([filePath hasSuffix:@".m"]||[filePath hasSuffix:@".h"]||[filePath hasSuffix:@".pch"]||[filePath hasSuffix:@".mm"]||[filePath hasSuffix:@".cpp"]) {
                
                NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                text=[self formatCode:text];
                text=[self formatCode_If_Else:text];
//                text=[self wordWrapCode:text];
                
                if ([filePath hasSuffix:@".h"]) {
                    text=[self lineBetweenLineSpace:text];
                }
                
                [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                return @"格式化代码风格完成!";
            }else{
                return @"不是OC编程文件";
            }
        }
            break;
        case FileTypeDirectory:
        {
            NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m",@".pch",@".mm",@".cpp"]];
            for (NSString *fileName in fileArr) {
                
                NSString *text=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
                text=[self formatCode:text];
                text=[self formatCode_If_Else:text];
//                text=[self wordWrapCode:text];
                
                if ([fileName hasSuffix:@".h"]) {
                    text=[self lineBetweenLineSpace:text];
                }
                [text writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
            }
            return @"格式化代码风格完成!";
        }
            break;
        case FileTypeUnkown:
        {
            return @"文件类型未知";
        }
            break;
    }
    return @"";
}

+ (NSString *)wordWrapCode:(NSString *)text{
    if ([[ZHWordWrap new] isCanRightfulWrapText:text]) {
        text=[[ZHWordWrap new] wordWrapText:text];
    }
    return text;
}
/**格式化{,(的问题*/
+ (NSString *)formatCode:(NSString *)text{
    NSArray *arrTemp=[text componentsSeparatedByString:@"\n"];
    
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSInteger i=0; i<arrTemp.count; i++) {
        if (i+1<arrTemp.count) {
            NSString *strTemp=arrTemp[i+1];
            strTemp=[ZHNSString removeSpacePrefix:strTemp];
            if (([strTemp hasPrefix:@"("]||[strTemp hasPrefix:@"{"])&&[arrTemp[i] isKindOfClass:[NSString class]]&&[self isSpecial:arrTemp[i]]==NO) {
                if ([strTemp hasPrefix:@"{"]) {
                    [arrM addObject:[arrTemp[i] stringByAppendingString:@" {"]];
                    [arrM addObject:[ZHNSString removeFirstStr:@"{" withText:arrTemp[i+1]]];
                }else if ([strTemp hasPrefix:@"("]) {
                    [arrM addObject:[arrTemp[i] stringByAppendingString:@"("]];
                    [arrM addObject:[ZHNSString removeFirstStr:@"(" withText:arrTemp[i+1]]];
                }
                i++;
            }else{
                [arrM addObject:arrTemp[i]];
            }
        }else{
            [arrM addObject:arrTemp[i]];
        }
    }
    
    return [arrM componentsJoinedByString:@"\n"];
}

/**格式化 if else 的问题*/
+ (NSString *)formatCode_If_Else:(NSString *)text{
    NSArray *arrTemp=[text componentsSeparatedByString:@"\n"];
    
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSInteger i=0; i<arrTemp.count; i++) {
        if (i+1<arrTemp.count) {
            NSString *strTemp=arrTemp[i+1];
            strTemp=[ZHNSString removeSpacePrefix:strTemp];
            if ([strTemp hasPrefix:@"else"]&&[arrTemp[i] isKindOfClass:[NSString class]]&&[self isSpecial:arrTemp[i]]==NO) {
                [arrM addObject:[arrTemp[i] stringByAppendingString:strTemp]];
                i++;
            }else{
                [arrM addObject:arrTemp[i]];
            }
        }else{
            [arrM addObject:arrTemp[i]];
        }
    }
    
    return [arrM componentsJoinedByString:@"\n"];
}

+ (BOOL)isSpecial:(NSString *)text{
    //如果//带有\结尾,说明很有可能是//在字符串里面
    if ([[ZHNSString removeSpacePrefix:text]hasSuffix:@"\\"]) {
        return YES;
    }
    if ([[ZHNSString removeSpacePrefix:text]hasSuffix:@";"]) {
        return YES;
    }
    if ([ZHNSString getCountTargetString:@"//" inText:text]>0) {
        return YES;
    }
    
    text=[text stringByReplacingOccurrencesOfString:@"%@" withString:@""];
    NSInteger stringStart,stringEnd;//这里的stringStart是指@"在字符串中的位置 stringEnd是指"在字符串中的位置
    stringStart=[text rangeOfString:@"@\""].location;
    stringEnd=[text rangeOfString:@"\""].location;
    if (stringEnd!=NSNotFound) {
        if (stringStart==NSNotFound) {
            return YES;
        }
        if (stringStart!=NSNotFound&&stringEnd<stringStart) {
            return YES;
        }
        return NO;
    }
    return NO;
}
/**.h中函数声明隔一行*/
+ (NSString *)lineBetweenLineSpace:(NSString *)text{
    text=[text stringByReplacingOccurrencesOfString:@";\n" withString:@";\n\n"];
    text=[text stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
    text=[text stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
    return text;
}

@end
