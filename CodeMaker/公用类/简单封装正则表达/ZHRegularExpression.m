#import "ZHRegularExpression.h"

@implementation ZHRegularExpression

/**查询所有满足条件的目标字符串在主字符串中所有的位置NSRange*/
- (NSArray<NSValue *> *)getAllTargetRangeInMainString:(NSString *)mainString withRegex:(NSString*)regexStr{
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *arrResult=[regex matchesInString:mainString options:0 range:NSMakeRange(0, [mainString length])];
    
    NSMutableArray *ranges=[NSMutableArray array];
    for (NSTextCheckingResult *result in arrResult) {
        if (result) {
            [ranges addObject:[NSValue valueWithRange:result.range]];
        }
    }
    
    return ranges;
}

/**查询所有满足条件的目标字符串在主字符串中所有的目标字符串*/
- (NSArray<NSString *> *)getAllTargetStringInMainString:(NSString *)mainString withRegex:(NSString*)regexStr{
    NSArray *ranges=[self getAllTargetRangeInMainString:mainString withRegex:regexStr];
    NSMutableArray *strings=[NSMutableArray array];
    for (NSValue *value in ranges) {
        if (value) {
            [strings addObject:[mainString substringWithRange:[value rangeValue]]];
        }
    }
    
    return strings;
}

@end
