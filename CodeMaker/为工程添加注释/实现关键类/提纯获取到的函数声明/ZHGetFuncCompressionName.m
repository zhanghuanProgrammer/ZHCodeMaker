#import "ZHGetFuncCompressionName.h"

@implementation ZHGetFuncCompressionName
+ (NSString *)getFuncCompressionName:(NSString *)funName{
    funName=[ZHNSString removeSpacePrefix:funName];
    if ([funName hasPrefix:@"- ("]||[funName hasPrefix:@"+ ("]) {
        funName=[self removeNewLine:funName];
        funName=[self removeParentheses:funName];
        funName=[self removeVariableName:funName];
        funName=[self addBrackets:funName];
        funName=[self removeFuncDescribe:funName];
        
        //这里删除所有+或者-,也就是不管它是类方法还是实例方法,因为比较难以判断调用者是实例还是类
        if([funName hasPrefix:@"-"])funName=[funName substringFromIndex:1];
        if([funName hasPrefix:@"+"])funName=[funName substringFromIndex:1];
        return funName;
    }
    return @"";
}

//1.去除\n
+ (NSString *)removeNewLine:(NSString *)text{
    text=[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return [text stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];
}
//2.去除()
+ (NSString *)removeParentheses:(NSString *)text{
    NSInteger countLeft=[ZHNSString getCountTargetString:@"(" inText:text];
    NSInteger countRight=[ZHNSString getCountTargetString:@")" inText:text];
    if (countLeft==0||countRight==0||countLeft!=countRight) {
//        NSLog(@"%@不是函数声明",text);
        return @"";
    }
    
    text=[self removeStrBetweenLeftString:'(' RightString:')' inText:text isContainLeftAndRight:YES];
    return text;
}
//3.去除:parameters
+ (NSString *)removeVariableName:(NSString *)text{
    if ([text rangeOfString:@":"].location==NSNotFound) {
        return text;
    }
    text=[text stringByReplacingOccurrencesOfString:@";" withString:@" ;"];
    text=[self removeVariableName_Help:text];
    text=[self removeStrBetweenLeftString:':' RightString:' ' inText:text isContainLeftAndRight:NO];
    return text;
}
+ (NSString *)removeVariableName_Help:(NSString *)text{
    if ([text rangeOfString:@"  "].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        return [self removeVariableName_Help:text];
    }
    if ([text rangeOfString:@": "].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@": " withString:@":"];
        return [self removeVariableName_Help:text];
    }
    return text;
}

//4.添加[]
+ (NSString *)addBrackets:(NSString *)text{
    text=[self addBrackets_Help:text];
    if ([text hasPrefix:@"-"]) {
        text=[text stringByReplacingOccurrencesOfString:@"-" withString:@"-["];
    }
    if ([text hasPrefix:@"+"]) {
        text=[text stringByReplacingOccurrencesOfString:@"+" withString:@"+["];
    }
    text=[text stringByReplacingOccurrencesOfString:@";" withString:@"]"];
    return text;
}
+ (NSString *)addBrackets_Help:(NSString *)text{
    if ([text rangeOfString:@"- "].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@"- " withString:@"-"];
        return [self addBrackets_Help:text];
    }
    if ([text rangeOfString:@"+ "].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@"+ " withString:@"+"];
        return [self addBrackets_Help:text];
    }
    if ([text rangeOfString:@" ;"].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@" ;" withString:@";"];
        return [self addBrackets_Help:text];
    }
    return text;
}
//5.做最后的判断,因为有些函数后面会写 DEPRECATED_ATTRIBUTE 等一些描述词
+ (NSString *)removeFuncDescribe:(NSString *)text{
    if ([text hasSuffix:@":]"]||([ZHNSString getCountTargetString:@":" inText:text]==0)) return text;
    
    NSInteger endIndex=[text rangeOfString:@":" options:NSBackwardsSearch].location;
    if (endIndex!=NSNotFound) {
        text=[text substringToIndex:endIndex+1];
        text=[text stringByAppendingString:@"]"];
    }
    return text;
}

/**删除某两个字符串之间的字符串,以最大范围,包括这两个字符串*/
+ (NSString *)removeStrBetweenLeftString:(unichar)leftString RightString:(unichar)rightString inText:(NSString *)text isContainLeftAndRight:(BOOL)isContainLeftAndRight{
    NSInteger leftStart=[text rangeOfString:[NSString stringWithFormat:@"%C",leftString]].location;
    NSString *leftStr=@"";
    NSString *input=text;
    if (leftStart!=NSNotFound) {
        leftStr=[text substringToIndex:leftStart];
        input=[text substringFromIndex:leftStart];
    }
    
    unichar ch;
    NSInteger start=-1,end=-1;
    NSInteger count=0;
    for (NSInteger i=0;i<input.length; i++) {
        ch=[input characterAtIndex:i];
        if (ch==leftString) {
            if (start==-1) {
                start=i;
            }
            count++;
        }else if (ch==rightString){
            count--;
            if (count==0) {
                end=i;
                
                if (isContainLeftAndRight) {
                    input=[input stringByReplacingCharactersInRange:NSMakeRange(start, end-start+1) withString:@""];
                    i-=(end-start+1);
                }else{
                    if (start+1<=(end-1)) {
                        input=[input stringByReplacingCharactersInRange:NSMakeRange(start+1, end-start-1) withString:@""];
                        i-=(end-start-1);
                    }
                }
                start=-1,end=-1;
            }
        }
    }
    return [leftStr stringByAppendingString:input];
}

@end
