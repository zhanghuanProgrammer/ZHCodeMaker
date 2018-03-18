#import "ZHInsertFuncNameAndAnnotation.h"
#import "ZHGetFunctionCall.h"
#import "ZHRepearDictionary.h"
#import "ZHDealWithFunctionCall.h"
#import "ZHSaveAnnotationAndFuncNameToDateBase.h"

@interface ZHInsertFuncNameAndAnnotation ()
@property (nonatomic,assign)NSInteger countInsert;
@end
@implementation ZHInsertFuncNameAndAnnotation

- (NSInteger)insertFuncNameAndAnnotation:(NSArray *)projectFilePaths{
    
    NSLog(@"%@",@"开始");
    
    //删除以前已经自动生成的注释,要不然会重复
    for (NSString *filePath in projectFilePaths) {
        NSString *textContent=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        textContent=[self deleteBeforeAnnotation:textContent];
        [textContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    self.countInsert=0;
    
    //提取注释保存到数据库
    ZHSaveAnnotationAndFuncNameToDateBase *zhSaveToDataBase=[ZHSaveAnnotationAndFuncNameToDateBase new];
    NSDictionary *annotationDic=[zhSaveToDataBase saveToDataBase:projectFilePaths];
    [[annotationDic jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/code.m" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    //从工程文件里读取内容,获取注释和对应的range
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *filePath in projectFilePaths) {
        ZHGetFunctionCall *zh=[[ZHGetFunctionCall alloc]initWithFilePath:filePath];
        ZHRepearDictionary *dic=[zh addAnnotation];
        if (dic.dicM.count>0) {
            [arrM addObjectsFromArray:[dic.dicM allKeys]];
            NSMutableDictionary *functionCalDicM=[NSMutableDictionary dictionary];
            [functionCalDicM addEntriesFromDictionary:dic.dicM];

            //开始匹配并插入注释(从后往前插入,所以先要排序)
            NSMutableArray *arrMSort=[NSMutableArray array];
            for (NSString *key in functionCalDicM) {
                [arrMSort addObject:[NSDictionary dictionaryWithObject:functionCalDicM[key] forKey:key]];
            }
            [arrMSort sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSDictionary *dic1=obj1,*dic2=obj2;
                NSRange range1=NSMakeRange(0, 0),range2=NSMakeRange(0, 0);
                if ([dic1 allKeys].count>0) range1=[[dic1 allValues][0] rangeValue];
                if ([dic2 allKeys].count>0) range2=[[dic2 allValues][0] rangeValue];
                return range1.location<range2.location;
            }];

            NSString *textContent=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

            for (NSDictionary *dic in arrMSort) {
                NSRange range=[[dic allValues][0] rangeValue];
                NSString *functionCal=[dic allKeys][0];
                NSArray *subFunctionCal=[ZHDealWithFunctionCall dealWithFunctionCall:functionCal];
                
                NSString *spaceStr=[self getSpaceStrInsertRange:range toTextContent:textContent];
                NSString *annotation=[self getAnnotationByFunctionCal:subFunctionCal andAnnotationTableDic:annotationDic spaceStr:spaceStr];

                textContent=[self insertAnnotationToText:annotation byRange:range toTextContent:textContent];
            }

            [textContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    NSLog(@"%@",@"结束");
    return self.countInsert;
}

/**首先根据调用方法获取所有的注释*/
- (NSString *)getAnnotationByFunctionCal:(NSArray *)functionCal andAnnotationTableDic:(NSDictionary *)annotationTableDic spaceStr:(NSString *)spaceStr{
    NSInteger targetCount=0;
    NSMutableString *annotation=[NSMutableString string];
    for (NSString *funCall in functionCal) {
        NSString *target=annotationTableDic[funCall];
        if (target!=nil&&target.length>0) {
            targetCount++;
            self.countInsert++;
            target=[target stringByReplacingOccurrencesOfString:@"/*" withString:@""];
            target=[target stringByReplacingOccurrencesOfString:@"*/" withString:@""];
            if ([target hasPrefix:@"//"]==NO) {
                if ([target hasPrefix:@"*"]) target=[target substringFromIndex:1];
                [annotation appendFormat:@"%@// %@<自动生成>\n",spaceStr,target];
            }else{
                [annotation appendFormat:@"%@%@<自动生成>\n",spaceStr,target];
            }
        }
    }
    if (targetCount==0) {
        return @"";
    }
    return annotation;
}

- (NSString *)deleteBeforeAnnotation:(NSString *)text{
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *splits=[text componentsSeparatedByString:@"\n"];
    
    for (NSString *str in splits) {
        if (![[ZHNSString removeSpaceSuffix:str] hasSuffix:@"<自动生成>"]) {
            [arrM addObject:str];
        }
    }
    return [arrM componentsJoinedByString:@"\n"];
}

- (NSString *)insertAnnotationToText:(NSString *)annotation byRange:(NSRange)range toTextContent:(NSString *)textContent{
    if (annotation.length<=0) {
        return textContent;
    }
    annotation=[@"\n\n" stringByAppendingString:annotation];
    NSInteger endIndex=[textContent rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, range.location)].location;
    if (endIndex!=NSNotFound) {
        if(endIndex>1){
            NSString *preStr=[textContent substringWithRange:NSMakeRange(endIndex-1, 1)];
            //可能出现在宏定义里面或者字符串里面,并且用\来做换行处理
            if (![preStr isEqualToString:@"\\"]) {
                textContent=[textContent stringByReplacingCharactersInRange:NSMakeRange(endIndex, 1) withString:annotation];
            }
        }
    }
    return textContent;
}

- (NSString *)getSpaceStrInsertRange:(NSRange)range toTextContent:(NSString *)textContent{
    NSInteger endIndex=[textContent rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, range.location)].location;
    if (endIndex!=NSNotFound) {
        NSString *str=[textContent substringWithRange:NSMakeRange(endIndex, range.location-endIndex)];
        
        NSMutableString *spaceStrM=[NSMutableString string];
        
        unichar ch;
        for (NSInteger i=0;i<str.length; i++) {
            ch=[str characterAtIndex:i];
            if (ch==' '||ch=='\t') {
                [spaceStrM appendFormat:@"%C",ch];
            }
        }
        return spaceStrM;
    }
    return @"";
}

@end
