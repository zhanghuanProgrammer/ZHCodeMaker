#import "ZHJsonPath.h"

@implementation ZHJsonPath

- (instancetype)initWithJsonDic:(NSDictionary *)jsonDic
{
    self = [super init];
    if (self) {
        self.jsonDic=jsonDic;
    }
    return self;
}

- (void)getTarget:(NSMutableArray *)targets forStrictPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonDic:(NSDictionary *)jsonDic{
    
    if (curIndex>=paths.count){
        [targets addObject:jsonDic];
        return;
    }
    if (![jsonDic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"- (void)getTarget:(NSMutableArray *)targets forPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonDic:(NSDictionary *)jsonDic 函数中的参数jsonDic 不是NSDictionary类型的,请检查.....");
        return;
    }
    
    NSString *key=paths[curIndex];
    id obj=jsonDic[key];
    if (obj!=nil) {
        [self getTarget:targets forStrictPath:paths withCurIndex:curIndex+1 withJsonDic:obj];
    }
}

/**获取目标,根据给予的字符串数组路径*/
- (id)getTargetsForStrictPath:(NSArray <NSString *>*)paths{
    NSMutableArray *target=[NSMutableArray array];
    [self getTarget:target forStrictPath:paths withCurIndex:0 withJsonDic:self.jsonDic];
    if (target.count>=1) {
        return target[0];
    }
    return nil;
}

- (void)getTarget:(NSMutableArray *)targets forStrictPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonObj:(id)jsonObj{
    
    if (curIndex>=paths.count){
        [targets addObject:jsonObj];
        return;
    }
    NSString *key=paths[curIndex];
    if (key.length>0) {
        if([ZHNSString isValidateNumber:key]&&[ZHNSString isPureInt:key]){
            //搜索下标
            if (![jsonObj isKindOfClass:[NSArray class]]) {
                NSLog(@"- (void)getTarget:(NSMutableArray *)targets forPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonObj:(id)jsonObj 函数中的参数jsonDic 搜索下标对应的搜索对象不是NSArray类型的,请检查.....");
                return;
            }else{
                NSInteger index=[key integerValue];
                if (index<[jsonObj count]) {
                    id obj=jsonObj[index];
                    [self getTarget:targets forStrictPath:paths withCurIndex:curIndex+1 withJsonObj:obj];
                }else{
                    NSLog(@"- (void)getTarget:(NSMutableArray *)targets forPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonObj:(id)jsonObj 函数中的参数jsonDic 搜索下标对应的搜索对象NSArray数组越界,请检查.....");
                    return;
                }
            }
        }else{
            //搜索字典的key
            if (![jsonObj isKindOfClass:[NSDictionary class]]) {
                NSLog(@"- (void)getTarget:(NSMutableArray *)targets forPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonObj:(id)jsonObj 函数中的参数jsonDic 搜索字典的key对应的搜索对象不是NSDictionary类型的,请检查.....");
                return;
            }else{
                id obj=jsonObj[key];
                if (obj!=nil) {
                    [self getTarget:targets forStrictPath:paths withCurIndex:curIndex+1 withJsonObj:obj];
                }
            }
        }
    }
}

/**获取目标,根据给予的字符串路径,里面可包含数字下标索引,可以根据动态生成字符串路径来获取目标,注意,用","号隔开表示多个路径*/
- (id)getTargetsForStrictStringPath:(NSString *)paths{
    NSMutableArray *target=[NSMutableArray array];
    [self getTarget:target forStrictPath:[paths componentsSeparatedByString:@","] withCurIndex:0 withJsonObj:self.jsonDic];
    if (target.count>=1) {
        return target[0];
    }
    return nil;
}

- (void)getTarget:(NSMutableArray *)targets forPath:(NSArray <NSString *>*)paths withCurIndex:(NSInteger)curIndex withJsonObj:(id)jsonObj{
    
    if (curIndex>=paths.count){
        [targets addObject:jsonObj];
        return;
    }
    NSString *key=paths[curIndex];
    if (key.length>0) {
        
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            id obj=jsonObj[key];
            if (obj!=nil) {
                [self getTarget:targets forPath:paths withCurIndex:curIndex+1 withJsonObj:obj];
            }else{
                for (NSString *subKey in jsonObj) {
                    [self getTarget:targets forPath:paths withCurIndex:curIndex withJsonObj:jsonObj[subKey]];
                }
            }
        }
        
        //搜索下标
        if ([jsonObj isKindOfClass:[NSArray class]]) {
            for (id subObj in jsonObj) {
                [self getTarget:targets forPath:paths withCurIndex:curIndex withJsonObj:subObj];
            }
        }
    }
}

/**获取目标(如果有多个,返回数组),根据给予的字符串数组路径(不用严格按照路径来,最大努力往里面寻找,并且找到的结果可能不一定在同一层)*/
- (NSArray *)getTargetsForPath:(NSArray <NSString *>*)paths{
    NSMutableArray *target=[NSMutableArray array];
    [self getTarget:target forPath:paths withCurIndex:0 withJsonObj:self.jsonDic];
    return target;
}

/**如果有多个XML节点是并排的,转换成字典会被放在一个数组里面,因为这样的特性,所以在这里进行统一收集数组里面的字典,而不是获取数组*/
+ (NSArray *)getDictionarysFromTargrtArr:(NSArray *)targrtArr{
    NSMutableArray *arrM=[NSMutableArray array];
    for (id subObj in targrtArr) {
        if ([subObj isKindOfClass:[NSArray class]]) {
            for (NSDictionary *subDic in subObj) {
                if ([subDic isKindOfClass:[NSDictionary class]]) {
                    [arrM addObject:subDic];
                }
            }
        }else if ([subObj isKindOfClass:[NSDictionary class]]) {
            [arrM addObject:subObj];
        }
    }
    return arrM;
}

/**获取所有value值(是字符串),对应的key*/
- (void)getAllStringValue:(NSMutableArray *)values forKey:(NSString *)key withJsonDic:(NSDictionary *)jsonDic noContainKeys:(NSArray *)noContainKeys{
    
    if (key.length>0) {
        
        if ([jsonDic isKindOfClass:[NSDictionary class]]) {
            
            id value=jsonDic[key];
            if (value!=nil) {
                if ([value isKindOfClass:[NSString class]]&&[value length]>0) {
                    if([values containsObject:value]==NO)[values addObject:value];
                }else{
                    [self getAllStringValue:values forKey:key withJsonDic:value noContainKeys:noContainKeys];
                }
            }
            
            for (NSString *subKey in jsonDic) {
                if([noContainKeys containsObject:subKey])continue;
                id value=jsonDic[subKey];
                if ([value isKindOfClass:[NSDictionary class]]||[value isKindOfClass:[NSArray class]]) {
                    [self getAllStringValue:values forKey:key withJsonDic:value noContainKeys:noContainKeys];
                }
            }
        }
        
        //搜索下标
        if ([jsonDic isKindOfClass:[NSArray class]]) {
            for (id subObj in jsonDic) {
                [self getAllStringValue:values forKey:key withJsonDic:subObj noContainKeys:noContainKeys];
            }
        }
    }
}

@end
