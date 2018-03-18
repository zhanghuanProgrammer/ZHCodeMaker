#import "ZHConditionsToRegex.h"

@implementation ZHConditionsToRegex

/**
*  将路径数组变成正则表达式
*
*  @param paths   要匹配的路径集合,这里的路径不是文件路径,而是字符串顺序集合  比如@"abc 1 sdas 2 gd 3 hja 4 sgdk 5 jgashj"  就存在  @[@"1",@"2",@"3",@"4",@"5"]; 的路径集合
*  @param isGreed (是否贪婪) 是否最大匹配,如果是,那么 eg @"abc 1 sdas 2 gd 3 hja 4 sgdk 5 jgashj 12345" 匹配 路径集合@[@"1",@"2",@"3",@"4",@"5"]; 得到的结果是 @"1 sdas 2 gd 3 hja 4 sgdk 5 jgashj 12345" 否则 得到的结果是 结果1 @"1 sdas 2 gd 3 hja 4 sgdk 5" 和结果2 @"12345"
*
*  @return 返回正则表达式字符串
*/
+ (NSString *)transformToRegexWithPaths:(NSArray *)paths isGreed:(BOOL)isGreed{
    
    NSMutableString *regexStrM=[NSMutableString string];
    
    for (NSString *path in paths) {
        if (path.length>0) {
            [regexStrM appendFormat:@"%@[\\w\\W]*",path];
            if (isGreed==NO)  [regexStrM appendString:@"?"];
        }
    }
    
    return regexStrM;
}


+ (NSString *)transformToRegexWithPaths:(NSArray *)paths{
    return [self transformToRegexWithPaths:paths isGreed:NO];
}
+ (NSString *)transformToRegexWithPaths_Greed:(NSArray *)paths{
    return [self transformToRegexWithPaths:paths isGreed:YES];
}


@end
