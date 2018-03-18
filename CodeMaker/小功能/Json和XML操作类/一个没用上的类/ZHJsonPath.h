
#import <Foundation/Foundation.h>

@interface ZHJsonPath : NSObject

@property (nonatomic,strong)NSDictionary *jsonDic;

- (instancetype)initWithJsonDic:(NSDictionary *)jsonDic;

/**获取目标(如果有多个,返回数组),根据给予的字符串数组路径(严格按照路径来,否则就获取不到目标)*/
- (id)getTargetsForStrictPath:(NSArray <NSString *>*)paths;
/**获取目标(如果有多个,返回数组),根据给予的字符串路径(严格按照路径来,否则就获取不到目标),里面可包含数字下标索引,可以根据动态生成字符串路径来获取目标,注意,用","号隔开表示多个路径*/
- (id)getTargetsForStrictStringPath:(NSString *)paths;

/**获取目标(如果有多个,返回数组),根据给予的字符串数组路径(不用严格按照路径来,最大努力往里面寻找,并且找到的结果可能不一定在同一层)*/
- (NSArray *)getTargetsForPath:(NSArray <NSString *>*)paths;

/**如果有多个XML节点是并排的,转换成字典会被放在一个数组里面,因为这样的特性,所以在这里进行统一收集数组里面的字典,而不是获取数组*/
+ (NSArray *)getDictionarysFromTargrtArr:(NSArray *)targrtArr;

/**获取所有value值(是字符串),对应的key*/
- (void)getAllStringValue:(NSMutableArray *)values forKey:(NSString *)key withJsonDic:(NSDictionary *)jsonDic noContainKeys:(NSArray *)noContainKeys;
@end
