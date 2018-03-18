#import "ZHDealWithFunctionCall.h"
#import "ZHRemoveTheComments.h"
#import "ZHGetFuncCompressionName.h"

@implementation ZHDealWithFunctionCall
+ (NSArray *)dealWithFunctionCall:(NSString *)functionCall{
    functionCall=[self filter:functionCall];
    functionCall=[self remove_index_Str:functionCall];
    functionCall=[self removeAnnotation:functionCall];
    NSArray *arr=[self getTargetContent:functionCall];
    return arr;
}

//1.筛选,如果没有[ 或者没有 ]就默认为不符合规则,返回空
+ (NSString *)filter:(NSString *)functionCall{
    functionCall = [functionCall stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    functionCall = [functionCall stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    NSInteger leftCount=[ZHNSString getCountTargetString:@"[" inText:functionCall];
    if (leftCount<=0) return @"";
    NSInteger rightCount=[ZHNSString getCountTargetString:@"]" inText:functionCall];
    if (rightCount<=0) return @"";
    return functionCall;
}

//2.去除_index_
+ (NSString *)remove_index_Str:(NSString *)functionCall{
    NSInteger index=[functionCall rangeOfString:@"_index_"].location;
    if (index!=NSNotFound) {
        functionCall=[functionCall substringToIndex:index];
    }
    return functionCall;
}

//3.去除注释
+ (NSString *)removeAnnotation:(NSString *)functionCall{
    functionCall=[ZHRemoveTheComments removeAllComments:functionCall saveAnnotations:[NSMutableArray array]];
    return functionCall;
}

//4.获取[]中的内容,返回所有获取结果(坐下小处理)
+ (NSArray *)getTargetContent:(NSString *)functionCall{
    NSArray *arr=[self getStrBetweenLeftString:'[' RightString:']' inText:functionCall];
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *text in arr) {
        NSString *strTemp=[self removeBlock:text];
        if (strTemp.length>0)strTemp=[self removeBlock:strTemp];
        if (strTemp.length>0)strTemp=[self removeParentheses:strTemp];
        if (strTemp.length>0)strTemp=[self removeCaller:strTemp];
        if (strTemp.length>0)strTemp=[self removeString:strTemp];
        if (strTemp.length>0)strTemp=[self removeTernaryOperator:strTemp];
        if (strTemp.length>0)strTemp=[self removeParameterNames:strTemp];
        if (strTemp.length>0)strTemp=[self getComeOut:strTemp];
        if (strTemp.length>0) [arrM addObject:strTemp];
    }
    return arrM;
}

//5.处理调用者
+ (NSString *)removeCaller:(NSString *)functionCall{
    functionCall=[functionCall stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    NSInteger index=[functionCall rangeOfString:@" "].location;
    if (index==NSNotFound) {
        return @"";
    }
    functionCall=[functionCall substringFromIndex:index+1];
    return [@"[" stringByAppendingString:functionCall];
}

//6.处理block
+ (NSString *)removeBlock:(NSString *)functionCall{
    if ([functionCall rangeOfString:@"{"].location==NSNotFound) {
        return functionCall;
    }
    return [ZHGetFuncCompressionName removeStrBetweenLeftString:'{' RightString:'}' inText:functionCall isContainLeftAndRight:YES];
}

//7.处理圆括号()
+ (NSString *)removeParentheses:(NSString *)functionCall{
    if ([functionCall rangeOfString:@"("].location==NSNotFound) {
        return functionCall;
    }
    return [ZHGetFuncCompressionName removeStrBetweenLeftString:'(' RightString:')' inText:functionCall isContainLeftAndRight:YES];
}

//8.处理字符串
+ (NSString *)removeString:(NSString *)functionCall{
    unichar ch;
    NSInteger start=-1,end=-1;
    for (NSInteger i=0;i<functionCall.length; i++) {
        ch=[functionCall characterAtIndex:i];
        if (ch=='"') {
            if (start==-1) start=i;
            else{
                end=i;
                functionCall=[functionCall stringByReplacingCharactersInRange:NSMakeRange(start, end-start+1) withString:@""];
                i-=(end-start+1);
                start=-1,end=-1;
            }
        }
    }
    return functionCall;
}

//9.处理:后面参数名的问题
+ (NSString *)removeParameterNames:(NSString *)functionCall{
    if ([functionCall hasSuffix:@" ]"]==NO) {
        functionCall=[functionCall stringByReplacingOccurrencesOfString:@"]" withString:@" ]"];
    }
    unichar ch;
    NSInteger start=-1,end=-1;
    for (NSInteger i=0;i<functionCall.length; i++) {
        ch=[functionCall characterAtIndex:i];
        if (ch==':') {
            start=i;
        }else if (ch==' '){
            if (start!=-1) {
                end=i;
                //往后面更多包容空格
                while (functionCall.length>end) {
                    NSString *afterStr=[functionCall substringFromIndex:end+1];
                    NSInteger leftIndex=[afterStr rangeOfString:@":"].location;
                    NSInteger rightIndex=[afterStr rangeOfString:@" "].location;
                    if (leftIndex!=NSNotFound&&rightIndex!=NSNotFound) {
                        if (leftIndex>rightIndex) end+=(rightIndex+1);
                        else break;
                    }else if (rightIndex!=NSNotFound){
                        end+=(rightIndex+1);
                    }else break;
                }
                i=end;
                if (start+1<=(end-1)) {
                    functionCall=[functionCall stringByReplacingCharactersInRange:NSMakeRange(start+1, end-start-1) withString:@""];
                    i-=(end-start-1);
                }
                start=-1,end=-1;
            }
        }
    }
    return functionCall;
}

//10.去除三目运算符
+ (NSString *)removeTernaryOperator:(NSString *)functionCall{
    if ([functionCall rangeOfString:@"?"].location!=NSNotFound) {
        functionCall=[self removeStrBetweenLeftString_NoMaxContain:'?' RightString:':' inText:functionCall isContainLeftAndRight:YES];
    }
    return functionCall;
}

//11.做最后的处理
+ (NSString *)getComeOut:(NSString *)functionCall{
    if ([functionCall hasPrefix:@"["]) functionCall=[functionCall substringFromIndex:1];
    if ([functionCall hasSuffix:@"]"]) functionCall=[functionCall substringToIndex:functionCall.length-1];
    functionCall=[ZHNSString removeSpaceSuffix:[ZHNSString removeSpacePrefix:functionCall]];
    return [NSString stringWithFormat:@"[%@]",functionCall];
}

+ (NSArray *)getStrBetweenLeftString:(unichar)leftString RightString:(unichar)rightString inText:(NSString *)text{
    NSMutableArray *arrM=[NSMutableArray array];
    unichar ch;
    NSInteger start=-1,end=-1;
    for (NSInteger i=0;i<text.length; i++) {
        ch=[text characterAtIndex:i];
        if (ch==leftString) {
            start=i;
        }else if (ch==rightString){
            if (start!=-1) {
                end=i;
                [arrM addObject:[text substringWithRange:NSMakeRange(start, end-start+1)]];
                text=[text stringByReplacingCharactersInRange:NSMakeRange(start, end-start+1) withString:@" "];
                NSArray *arr=[self getStrBetweenLeftString:leftString RightString:rightString inText:text];
                if (arr.count>0) [arrM addObjectsFromArray:arr];
                return arrM;
            }
        }
    }
    return arrM;
}

/**删除某两个字符串之间的字符串,以最大范围,包括这两个字符串*/
+ (NSString *)removeStrBetweenLeftString_NoMaxContain:(unichar)leftString RightString:(unichar)rightString inText:(NSString *)text isContainLeftAndRight:(BOOL)isContainLeftAndRight{
    NSInteger leftStart=[text rangeOfString:[NSString stringWithFormat:@"%C",leftString]].location;
    NSString *leftStr=@"";
    NSString *input=text;
    if (leftStart!=NSNotFound) {
        leftStr=[text substringToIndex:leftStart];
        input=[text substringFromIndex:leftStart];
    }
    
    unichar ch;
    NSInteger start=-1,end=-1;
    for (NSInteger i=0;i<input.length; i++) {
        ch=[input characterAtIndex:i];
        if (ch==leftString) {
            start=i;
        }else if (ch==rightString){
            if (start!=-1) {
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
