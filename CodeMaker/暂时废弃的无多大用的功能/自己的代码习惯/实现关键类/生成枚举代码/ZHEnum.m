#import "ZHEnum.h"

@implementation ZHEnum

- (void)Begin:(NSString *)str{
    [self saveData:[self fun1:str]];
}
- (NSString *)creatCase:(NSString *)enumStr annotation:(NSString *)annotation{
    
    if ([annotation hasPrefix:@"//"]==NO) {
        annotation = [@"//" stringByAppendingString:annotation];
    }
    
    NSString *text=[NSString stringWithFormat:@"case %@:%@\n\
                    {\n\
                    \n\
                    }\nbreak;\n",enumStr,annotation];
    return text;
}
- (NSString *)fun1:(NSString *)input{
    
    NSMutableString *strM=[NSMutableString string];
    
    [strM appendString:@"switch (<##>) {\n"];
    
    NSArray *arr=[input componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        NSString *temp=[self removeSpace:str];
        if ([temp rangeOfString:@","].location!=NSNotFound) {
            NSArray *subArr=[temp componentsSeparatedByString:@","];
            [strM appendString:[self creatCase:subArr[0] annotation:subArr[1]]];
        }else{
            if ([temp rangeOfString:@"//"].location!=NSNotFound) {
                NSArray *subArr=[temp componentsSeparatedByString:@"//"];
                [strM appendString:[self creatCase:subArr[0] annotation:subArr[1]]];
            }else{
                [strM appendString:[self creatCase:temp annotation:@""]];
            }
        }
    }
    
    
    [strM appendString:@"\n}"];
    return strM;
}
- (NSString *)removeSpace:(NSString *)text{
    if ([text hasPrefix:@" "]) {
        text=[text substringFromIndex:1];
        return [self removeSpace:text];
    }
    if ([text hasSuffix:@" "]) {
        text=[text substringToIndex:text.length-1];
        return [self removeSpace:text];
    }
    if ([text rangeOfString:@"\t"].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        return [self removeSpace:text];
    }
    if ([text hasSuffix:@"*"]) {
        text=[text substringToIndex:text.length-1];
        return [self removeSpace:text];
    }
    return text;
}
@end
