#import <Foundation/Foundation.h>

@interface ZHJson : NSObject
/**将json字符串格式化或者压缩化 isCompression:是否压缩*/
- (NSString *)jsonFormat:(NSString *)text isCompression:(BOOL)compression;

/**将Dictionary转换成MutableDictionary*/
- (NSMutableDictionary *)copyMutableDicFromDictionary:(NSDictionary *)dic;
/**将NSArray转换成MutableNSArray*/
- (NSMutableArray *)copyMutableArrFromArray:(NSArray *)arr;

/**压缩Json,使得里面不再有重复的数据,目标是为了用来生成好编辑的json数据,这样就可以用工具来生成自己想要的字段model了*/
- (NSString *)compressionJson:(NSString *)json;

/**移除掉Value通过key值*/
- (NSDictionary *)removeValueForKeys:(NSArray *)keys FromDictionary:(NSDictionary *)dic;
@end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
