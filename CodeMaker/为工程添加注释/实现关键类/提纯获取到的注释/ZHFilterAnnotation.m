#import "ZHFilterAnnotation.h"
#import "ZHRemoveTheComments.h"
#import "StringSimilarity.h"

@implementation ZHFilterAnnotation

- (NSMutableDictionary *)annotationDicM{
    if (!_annotationDicM) {
        _annotationDicM=[NSMutableDictionary dictionary];
    }
    return _annotationDicM;
}

- (void)saveAndeFilterAnnotation:(NSString *)annotation forFuncName:(NSString *)funcName{
    //1.一定要有中文
    if ([ZHNSString isContainChinese:annotation]) {
        
        NSInteger result=[self isContainFuncInstructionsAndDoubleSlash:annotation];
        if (result!=0) {//返回0 代表这段注释有问题,不处理
            
            if ([annotation rangeOfString:@"\n"].location==NSNotFound) {
                [self saveAnnotationToDictionary:annotation forFuncName:funcName];
                return;
            }
            
            switch (result) {
                case -1:
                {
                    annotation=[self getLastOneContainChinese:annotation];
                }break;
                case 1:
                {
                    annotation=[self getFirstOneContainChinese:annotation];
                }break;
                case 2:
                {
                    annotation=[self getBestOneContainChinese:annotation];
                }break;
            }
            
            annotation=[self removeNewLine:annotation];
            
            [self saveAnnotationToDictionary:annotation forFuncName:funcName];
            
        }
    }
}

//2.在多行//时,倒数第一个有中文的
- (NSString *)getLastOneContainChinese:(NSString *)annotation{
    NSMutableArray *annotations=[NSMutableArray array];
    [ZHRemoveTheComments removeDoubleSlashComments:annotation saveAnnotations:annotations];
    [annotations reverse];
    for (NSString *text in annotations) {
        if ([ZHNSString isContainChinese:text]) {
            return text;
        }
    }
    NSLog(@"竟然//注释中没有中文");
    return @"";
}

//3.在/**/时,第一个有中文的
- (NSString *)getFirstOneContainChinese:(NSString *)annotation{
    NSMutableArray *annotations=[NSMutableArray array];
    [ZHRemoveTheComments removeFuncInstructionsComments:annotation saveAnnotations:annotations];
    
    if (annotations.count>1) {
        for (NSInteger i=annotations.count-1; i>=0; i--) {
            NSString *getAnnotation=annotations[i];
            if ([ZHNSString isContainChinese:getAnnotation]) {
                for (NSString *text in [getAnnotation componentsSeparatedByString:@"\n"]) {
                    if ([ZHNSString isContainChinese:text]) {
                        if ([text hasPrefix:@"/*"]){
                            if ([text hasSuffix:@"*/"]) {
                                return text;
                            }else{
                                return [text stringByAppendingString:@"*/"];
                            }
                        }else
                            return [@"//" stringByAppendingString:text];
                    }
                }
            }
        }
    }else if (annotations.count==1){
        NSString *getAnnotation=annotations[0];
        for (NSString *text in [getAnnotation componentsSeparatedByString:@"\n"]) {
            if ([ZHNSString isContainChinese:text]) {
                return [@"//" stringByAppendingString:text];
            }
        }
    }
    
//    NSLog(@"竟然/**/注释中没有中文");
    return @"";
}
//4.同时存在//和/**/时,这里我们默认/**/才是正宗的函数名注释
- (NSString *)getBestOneContainChinese:(NSString *)annotation{
    return [self getFirstOneContainChinese:annotation];
}

//5.不能存在\n
- (NSString *)removeNewLine:(NSString *)annotation{
    return [annotation stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

//6.如果存在同名函数,比较相似性,如果相似性<=最短字符串的长度/2,取最长,否则,不变
- (void)saveAnnotationToDictionary:(NSString *)annotation forFuncName:(NSString *)funcName{
    if (self.annotationDicM[funcName]==nil) {
        [self.annotationDicM setValue:annotation forKey:funcName];
    }else{
        NSString *oringal=self.annotationDicM[funcName];
        NSInteger similarity=[StringSimilarity similarity:oringal :annotation];
        
        if (similarity>=(ZHMIN(oringal.length, annotation.length)/2)) {
            if (oringal.length<annotation.length)
                [self.annotationDicM setValue:annotation forKey:funcName];
        }
    }
}

/**如果是-1,代表只有// 如果是1代表只有/ * * /  如果是2代表两个都有 否则返回0 代表这段注释有问题,不处理*/
- (NSInteger)isContainFuncInstructionsAndDoubleSlash:(NSString *)annotation{
    
    NSInteger funcInstructionsLeftCount=[ZHNSString getCountTargetString:@"/*" inText:annotation];
    NSInteger funcInstructionsRightCount=[ZHNSString getCountTargetString:@"*/" inText:annotation];
    NSInteger doubleSlashCount=[ZHNSString getCountTargetString:@"//" inText:annotation];
    if (funcInstructionsLeftCount>0&&funcInstructionsRightCount>0&&doubleSlashCount>0) {
        return 2;
    }
    else if (funcInstructionsLeftCount>0&&funcInstructionsRightCount>0) {
        return 1;
    }
    else if (doubleSlashCount>0) {
        return -1;
    }
    return 0;
}

@end
