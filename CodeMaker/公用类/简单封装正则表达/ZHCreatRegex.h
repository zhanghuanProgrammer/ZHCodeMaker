#import <Foundation/Foundation.h>

@interface ZHCreatRegex : NSObject

/**最终生成的正则表达式字符串*/
@property (nonatomic,copy)NSString *regexString;//最终生成的正则表达式字符串


#pragma mark --------制作正则表达式字符串
/**以某个字符串为前缀*/
- (ZHCreatRegex * (^)(NSString *prefix))hasPrefix;//以某个字符串为前缀
/**以某个字符串为后缀*/
- (ZHCreatRegex * (^)(NSString *suffix))hasSuffix;//以某个字符串为后缀
/**包含某个字符串*/
- (ZHCreatRegex * (^)(NSString *contain))containStr;//包含某个字符串


/**最多有一个字符*/
- (ZHCreatRegex * (^)(unichar mostOne))mostOneCharacter;//最多有一个字符
/**最多有一个字符串*/
- (ZHCreatRegex * (^)(NSString *string))mostOneString;//最多有一个字符串
/**至少有一个字符*/
- (ZHCreatRegex * (^)(unichar atLeastOne))atLeastOneCharacter;//至少有一个字符
/**至少有一个字符串*/
- (ZHCreatRegex * (^)(NSString *string))atLeastOneString;//至少有一个字符串
/**可能有一个或多个字符*/
- (ZHCreatRegex * (^)(unichar may))mayHasCharacter;//可能有一个或多个字符
/**可能有一个或多个字符串*/
- (ZHCreatRegex * (^)(NSString *string))mayHasString;//可能有一个或多个字符串


/**有n个相同字符ch*/
- (ZHCreatRegex * (^)(unichar ch,NSUInteger count))countMultipleCharacter;//有n个相同字符ch
/**有n个相同字符串*/
- (ZHCreatRegex * (^)(NSString *string,NSUInteger count))countMultipleString;//有n个相同字符串
/**有m-n个相同字符ch*/
- (ZHCreatRegex * (^)(unichar ch,NSUInteger m,NSUInteger n))between_m_n_MultipleCharacter;//有m-n个相同字符ch
/**有m-n个相同字符串*/
- (ZHCreatRegex * (^)(NSString *string,NSUInteger m,NSUInteger n))between_m_n_MultipleString;//有m-n个相同字符串


/**一个字符串中的一个*/
- (ZHCreatRegex * (^)(NSString *String))enumOneInString;//一个字符串中的一个
/**多个字符串中的一个*/
- (ZHCreatRegex * (^)(NSArray *multipleString))orOneInMultipleString;//多个字符串中的一个
/**某个范围内的一个字符*/
- (ZHCreatRegex * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character;//某个范围内的一个字符
/**不是某个范围内的任何一个字符*/
- (ZHCreatRegex * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character_NO;//不是某个范围内的任何一个字符

/**是一个数字*/
- (ZHCreatRegex *)number;//是一个数字
/**不是一个数字*/
- (ZHCreatRegex *)number_No;//不是一个数字
/**是一个字母*/
- (ZHCreatRegex *)a_z_Or_A_Z;//是一个字母
/**不是一个字母*/
- (ZHCreatRegex *)a_z_Or_A_Z_NO;//不是一个字母



#pragma mark --------获取简短的正则表达式字符串
/**以某个字符串为前缀*/
- (NSString * (^)(NSString *prefix))hasPrefix_Get;//以某个字符串为前缀
/**以某个字符串为后缀*/
- (NSString * (^)(NSString *suffix))hasSuffix_Get;//以某个字符串为后缀


/**最多有一个字符*/
- (NSString * (^)(unichar mostOne))mostOneCharacter_Get;//最多有一个字符
/**最多有一个字符串*/
- (NSString * (^)(NSString *string))mostOneString_Get;//最多有一个字符串
/**至少有一个字符*/
- (NSString * (^)(unichar atLeastOne))atLeastOneCharacter_Get;//至少有一个字符
/**至少有一个字符串*/
- (NSString * (^)(NSString *string))atLeastOneString_Get;//至少有一个字符串
/**可能有一个或多个字符*/
- (NSString * (^)(unichar may))mayHasCharacter_Get;//可能有一个或多个字符
/**可能有一个或多个字符串*/
- (NSString * (^)(NSString *string))mayHasString_Get;//可能有一个或多个字符串


/**有n个相同字符ch*/
- (NSString * (^)(unichar ch,NSUInteger count))countMultipleCharacter_Get;//有n个相同字符ch
/**有n个相同字符串*/
- (NSString * (^)(NSString *string,NSUInteger count))countMultipleString_Get;//有n个相同字符串
/**有m-n个相同字符ch*/
- (NSString * (^)(unichar ch,NSUInteger m,NSUInteger n))between_m_n_MultipleCharacter_Get;//有m-n个相同字符ch
/**有m-n个相同字符串*/
- (NSString * (^)(NSString *string,NSUInteger m,NSUInteger n))between_m_n_MultipleString_Get;//有m-n个相同字符串


/**一个字符串中的一个*/
- (NSString * (^)(NSString *String))enumOneInString_Get;//一个字符串中的一个
/**多个字符串中的一个*/
- (NSString * (^)(NSArray *multipleString))orOneInMultipleString_Get;//多个字符串中的一个
/**某个范围内的一个字符*/
- (NSString * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character_Get;//某个范围内的一个字符
/**不是某个范围内的任何一个字符*/
- (NSString * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character_NO_Get;//不是某个范围内的任何一个字符

/**是一个数字*/
- (NSString *)number_Get;//是一个数字
/**不是一个数字*/
- (NSString *)number_No_Get;//不是一个数字
/**是一个字母*/
- (NSString *)a_z_Or_A_Z_Get;//是一个字母
/**不是一个字母*/
- (NSString *)a_z_Or_A_Z_NO_Get;//不是一个字母
@end