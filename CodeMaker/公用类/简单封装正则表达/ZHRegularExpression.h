#import <Foundation/Foundation.h>

@interface ZHRegularExpression : NSObject

/**查询所有满足条件的目标字符串在主字符串中所有的位置NSRange*/
- (NSArray<NSValue *> *)getAllTargetRangeInMainString:(NSString *)mainString withRegex:(NSString*)regexStr;

/**查询所有满足条件的目标字符串在主字符串中所有的目标字符串*/
- (NSArray<NSString *> *)getAllTargetStringInMainString:(NSString *)mainString withRegex:(NSString*)regexStr;

@end
