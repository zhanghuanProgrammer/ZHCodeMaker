#import "ZHRepearDictionary.h"

@implementation ZHRepearDictionary

- (NSMutableDictionary *)dicM{
    if (!_dicM) {
        _dicM=[NSMutableDictionary dictionary];
    }
    return _dicM;
}
- (void)setValue:(id)value forKey:(NSString *)key{
    if (self.dicM[key]!=nil) {
        //说明已经存在这个key值
        [self.dicM setValue:value forKey:[self getNewKey:key]];
    }else{
        [self.dicM setValue:value forKey:key];
    }
}

- (NSInteger)hasKeyCount:(NSString *)key{
    NSArray *keys=[self.dicM allKeys];
    NSInteger maxCount=0;
    for (NSString *str in keys) {
        if ([str hasPrefix:key]) {
            //取出最后的数字
            NSString *subStr=[str substringFromIndex:key.length];
            if ([subStr hasPrefix:@"_index_"]) {
                subStr=[subStr substringFromIndex:@"_index_".length];
                if ([ZHNSString isValidateNumber:subStr]&&[ZHNSString isPureInt:subStr]) {
                    NSInteger count=[subStr integerValue];
                    if (count>maxCount) {
                        maxCount=count;
                    }
                }
            }
        }
    }
    return maxCount;
}

+ (NSString *)getKeyForKey:(NSString *)key{
    NSInteger index=[key rangeOfString:@"_index_"].location;
    if (index!=NSNotFound) {
        key=[key substringToIndex:index];
    }
    return key;
}

- (NSString *)getNewKey:(NSString *)key{
    return [NSString stringWithFormat:@"%@_index_%zd",key,[self hasKeyCount:key]+1];
}

@end
