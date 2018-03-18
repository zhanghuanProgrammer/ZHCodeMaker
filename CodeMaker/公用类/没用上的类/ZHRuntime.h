#import <Foundation/Foundation.h>

@interface ZHRuntime : NSObject

// 获取所有的属性名
+(NSArray *)allPropertiesFromClass:(Class)cls;
// 获取所有的属性名和Value
+ (NSDictionary *)allPropertyNamesAndValuesFromObject:(id)object;
// 获取所有的方法名
+ (NSArray *)allMethodsFromClass:(Class)cls;
// 获取所有的方法详细信息
+ (NSArray *)allMethodsDetailInfoFromClass:(Class)cls;
// 获取所有的成员变量名
+ (NSArray *)allMemberVariablesFromClass:(Class)cls;
// 获取所有的属性类型
+ (NSArray *)allAtributesFromClass:(Class)cls;
// 获取所有的属性名和对应的类型
+ (NSDictionary *)allNameAndAtributesFromClass:(Class)cls;
/**返回所有协议名*/
+ (NSArray *)allProtocolFromClass:(Class)cls;
//打印指定某个类的所有成员变量
+ (void)printAllMemberVariablesFromObject:(id)object;
@end
