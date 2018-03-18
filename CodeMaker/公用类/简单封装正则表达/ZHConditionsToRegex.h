#import <Foundation/Foundation.h>

@interface ZHConditionsToRegex : NSObject

/**将路径数组变成正则表达式*/
+ (NSString *)transformToRegexWithPaths:(NSArray *)paths;
+ (NSString *)transformToRegexWithPaths_Greed:(NSArray *)paths;

@end
