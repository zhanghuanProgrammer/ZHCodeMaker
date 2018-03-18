//用来计算两个字符串的相似度
#import <Foundation/Foundation.h>

@interface StringSimilarity : NSObject
+ (NSInteger)similarity:(NSString *)stringA :(NSString *)stringB;
@end
