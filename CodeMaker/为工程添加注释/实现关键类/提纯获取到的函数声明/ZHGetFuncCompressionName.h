#import <Foundation/Foundation.h>

@interface ZHGetFuncCompressionName : NSObject
+ (NSString *)getFuncCompressionName:(NSString *)funName;
/**删除某两个字符串之间的字符串,包括这两个字符串*/
+ (NSString *)removeStrBetweenLeftString:(unichar)leftString RightString:(unichar)rightString inText:(NSString *)text isContainLeftAndRight:(BOOL)isContainLeftAndRight;
@end
