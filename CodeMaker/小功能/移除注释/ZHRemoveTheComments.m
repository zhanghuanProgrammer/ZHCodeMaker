#import "ZHRemoveTheComments.h"
#import "SAReader.h"
#import "SAAnnotation.h"

@implementation ZHRemoveTheComments

+ (NSString *)BeginWithFilePath:(NSString *)filePath type:(ZHRemoveTheCommentsType)type{
    
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
//                NSLog(@"😄处理前:%@",text);
                text=[self removeComments:text type:type];
//                NSLog(@"🙄处理后:%@",text);
                if ([filePath hasSuffix:@".h"]) {
                    text=[self lineBetweenLineSpace:text];
                }
                
                [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                return @"处理注释完成!";
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
//                NSLog(@"😄处理前:%@",text);
                text=[self removeComments:text type:type];
//                NSLog(@"🙄处理后:%@",text);
                
                if ([fileName hasSuffix:@".h"]) {
                    text=[self lineBetweenLineSpace:text];
                }
//
                [text writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
            }
            return @"处理注释完成!";
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

/**根据类型删除注释*/
+ (NSString *)removeComments:(NSString *)text type:(ZHRemoveTheCommentsType)type{
    
//    SAReader *reader = [[SAReader alloc]initWithCodeText:text];
//    SAAnnotation *annotation = [[SAAnnotation alloc]initWithReader:reader];
//    return [annotation.reader.splits componentsJoinedByString:@""];
    
    switch (type) {
        case ZHRemoveTheCommentsTypeAllComments://删除全部注释
        {
            return [self removeAllComments:text];
        }
            break;
        case ZHRemoveTheCommentsTypeFileInstructionsComments://删除文件说明注释
        {
            return [self removeFileInstructionsComments:text];
        }
            break;
        case ZHRemoveTheCommentsTypeEnglishComments://删除英文注释
        {
            return [self removeEnglishComments:text];
        }
            break;
        case ZHRemoveTheCommentsTypeDoubleSlashComments://删除//注释
        {
            return [self removeDoubleSlashComments:text noDeleteChineseComment:NO saveAnnotations:nil];
        }
            break;
        case ZHRemoveTheCommentsTypeFuncInstructionsComments://删除/ **\/或\/ ***\/注释
        {
            return [self removeFuncInstructionsComments:text noDeleteChineseComment:NO saveAnnotations:nil];
        }
            break;
    }
    return @"";
}

/**删除全部注释*/
+ (NSString *)removeAllComments:(NSString *)text{
    text=[self removeFileInstructionsComments:text];
    text=[self removeFuncInstructionsComments:text noDeleteChineseComment:NO saveAnnotations:nil];
    text=[self removeDoubleSlashComments:text noDeleteChineseComment:NO saveAnnotations:nil];
    return text;
}

/**删除文件说明注释*/
+ (NSString *)removeFileInstructionsComments:(NSString *)text{
    text=[text stringByReplacingOccurrencesOfString:@"//#import" withString:@"//"];
    if ([text rangeOfString:@"#import"].location!=NSNotFound) {
        NSString *fileInstructionsComments=[text substringToIndex:[text rangeOfString:@"#import"].location];
        if (fileInstructionsComments.length>0) {
            NSString *remianText=[text substringFromIndex:[text rangeOfString:@"#import"].location];
            fileInstructionsComments=[self removeDoubleSlashComments:fileInstructionsComments noDeleteChineseComment:NO saveAnnotations:nil];
            text =[fileInstructionsComments stringByAppendingString:remianText];
        }
    }
    return text;
}

/**删除英文注释*/
+ (NSString *)removeEnglishComments:(NSString *)text{
    text=[self removeFileInstructionsComments:text];
    text=[self removeFuncInstructionsComments:text noDeleteChineseComment:YES  saveAnnotations:nil];
    text=[self removeDoubleSlashComments:text noDeleteChineseComment:YES saveAnnotations:nil];
    return text;
}

/**    删除所有注释并且提取出注释   */
+ (NSString *)removeAllComments:(NSString *)text saveAnnotations:(NSMutableArray *)annotations{
    text=[self removeFuncInstructionsComments:text noDeleteChineseComment:NO saveAnnotations:annotations];
    return [self removeDoubleSlashComments:text noDeleteChineseComment:NO saveAnnotations:annotations];
}

/**获取//注释*/
+ (NSString *)removeDoubleSlashComments:(NSString *)text saveAnnotations:(NSMutableArray *)annotations{
    text=[self removeFuncInstructionsComments:text noDeleteChineseComment:NO saveAnnotations:annotations];
    [annotations removeAllObjects];
    return [self removeDoubleSlashComments:text noDeleteChineseComment:NO saveAnnotations:annotations];
}

/**删除//注释*/
+ (NSString *)removeDoubleSlashComments:(NSString *)text noDeleteChineseComment:(BOOL)noDeleteChineseComment saveAnnotations:(NSMutableArray *)annotations{
    
    NSArray *arrTemp=[text componentsSeparatedByString:@"\n"];
    
    NSMutableArray *arrM=[NSMutableArray array];
    
    BOOL priorHasSuffixSpecial=NO;
    
    for (NSInteger i=0; i<arrTemp.count; i++) {
        NSString *strTemp=arrTemp[i];
        strTemp=[ZHNSString removeSpacePrefix:strTemp];
        if ([strTemp hasPrefix:@"//"]==NO) {
            if([strTemp rangeOfString:@"//"].location!=NSNotFound){
                NSString *subStr=[arrTemp[i] substringFromIndex:[arrTemp[i] rangeOfString:@"//"].location+2];
                if ([self isDoubleSlashCommentsSpecial:subStr thisRowHasPrefixDoubleSlash:NO]||priorHasSuffixSpecial) {
                    [arrM addObject:arrTemp[i]];
                    
                }else{
                    if (noDeleteChineseComment&&[ZHNSString isContainChinese:subStr]) {
                        [arrM addObject:arrTemp[i]];
                    }else{
                        
                        [annotations addObject:[arrTemp[i] substringFromIndex:[arrTemp[i] rangeOfString:@"//"].location]];
                        [arrM addObject:[arrTemp[i] substringToIndex:[arrTemp[i] rangeOfString:@"//"].location]];
                    }
                }
            }else{
                [arrM addObject:arrTemp[i]];
            }
        }else{
            
            if (noDeleteChineseComment&&[ZHNSString isContainChinese:strTemp]) {
                [arrM addObject:arrTemp[i]];
            }else if ([self isDoubleSlashCommentsSpecial:strTemp thisRowHasPrefixDoubleSlash:YES]||priorHasSuffixSpecial) {
                [arrM addObject:arrTemp[i]];
            }else{
                [annotations addObject:arrTemp[i]];
            }
        }
        if ([[ZHNSString removeSpaceSuffix:arrTemp[i]] hasSuffix:@"\\"]) {
            priorHasSuffixSpecial=YES;
        }else{
            priorHasSuffixSpecial=NO;
        }
    }
    
    return [arrM componentsJoinedByString:@"\n"];
}

/**获取/ **\/或\/ ***\/注释*/
+ (NSString *)removeFuncInstructionsComments:(NSString *)text saveAnnotations:(NSMutableArray *)annotations{
    return [self removeFuncInstructionsComments:text noDeleteChineseComment:NO saveAnnotations:annotations];
}

/**删除/ **\/或\/ ***\/注释*/
+ (NSString *)removeFuncInstructionsComments:(NSString *)text noDeleteChineseComment:(BOOL)noDeleteChineseComment saveAnnotations:(NSMutableArray *)annotations{
    
    text=[text stringByReplacingOccurrencesOfString:@"//*" withString:@"/*"];//有人注释是这样写的    //*注释内容*/
    
    text=[text stringByReplacingOccurrencesOfString:@"\\\"" withString:@"##$$$%%"];
    text=[text stringByReplacingOccurrencesOfString:@"@\"" withString:@"##***%%"];
    NSInteger indexStart=[text rangeOfString:@"/*"].location;
    
    //如果/*在字符串中间
    while (indexStart!=NSNotFound&&[ZHNSString isBetweenLeftString:@"##***%%" RightString:@"\"" targetStringRange:NSMakeRange(indexStart, 2) inText:text]) {
        indexStart=[text rangeOfString:
                    @"/*" options:NSLiteralSearch
                                 range:NSMakeRange(indexStart+2, text.length-indexStart-2)].location;
    }
    
    NSInteger endStart;
    while (indexStart!=NSNotFound) {
        
        endStart=[text rangeOfString:@"*/" options:NSLiteralSearch range:NSMakeRange(indexStart+1, text.length-indexStart-1)].location;
        //如果*/在字符串中间
        while (endStart!=NSNotFound&&[ZHNSString isBetweenLeftString:@"##***%%" RightString:@"\"" targetStringRange:NSMakeRange(endStart, 2) inText:text]) {
            endStart=[text rangeOfString:@"*/" options:NSLiteralSearch range:NSMakeRange(endStart+1, text.length-endStart-1)].location;
        }
        if (endStart!=NSNotFound) {
            
            NSString *tempStr=[text substringWithRange:NSMakeRange(indexStart+2, endStart-indexStart-2)];
            
            if (!(noDeleteChineseComment&&[ZHNSString isContainChinese:tempStr])) {
                if ([tempStr rangeOfString:@"/*"].location==NSNotFound) {
                    [annotations addObject:[text substringWithRange:NSMakeRange(indexStart, endStart-indexStart+2)]];
                    text=[text stringByReplacingCharactersInRange:NSMakeRange(indexStart, endStart-indexStart+2) withString:@""];
                }
            }
            
            if (indexStart+2<text.length) {
                indexStart=[text rangeOfString:
                                 @"/*" options:NSLiteralSearch
                                         range:NSMakeRange(indexStart+2, text.length-indexStart-2)].location;
                //如果/*在字符串中间
                while (indexStart!=NSNotFound&&[ZHNSString isBetweenLeftString:@"##***%%" RightString:@"\"" targetStringRange:NSMakeRange(indexStart, 2) inText:text]) {
                    indexStart=[text rangeOfString:
                                @"/*" options:NSLiteralSearch
                                             range:NSMakeRange(indexStart+2, text.length-indexStart-2)].location;
                }
            }else break;
        }else{
            break;
        }
    }
    
    text=[text stringByReplacingOccurrencesOfString:@"##$$$%%" withString:@"\\\""];
    text=[text stringByReplacingOccurrencesOfString:@"##***%%" withString:@"@\""];
    
    return text;
}

+ (BOOL)isDoubleSlashCommentsSpecial:(NSString *)text thisRowHasPrefixDoubleSlash:(BOOL)thisRowHasPrefixDoubleSlash{
    //如果//后面带有*/,说明/**/中含有//,那么不能删除这个注释,否则/**/就只剩/*了
    if ([text rangeOfString:@"*/"].location!=NSNotFound) {
        return YES;
    }
    //如果//带有\结尾,说明很有可能是//在字符串里面
    if ([[ZHNSString removeSpacePrefix:text]hasSuffix:@"\\"]) {
        return YES;
    }
    if (thisRowHasPrefixDoubleSlash) {
        return NO;
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
