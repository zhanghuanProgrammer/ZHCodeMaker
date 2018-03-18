#import "ZHRepeatNSArray.h"

@implementation ZHRepeatNSArray

- (NSMutableArray *)arrM{
    if (!_arrM) {
        _arrM=[NSMutableArray array];
    }
    return _arrM;
}

- (void)addObject:(NSString *)key{
    if ([self.arrM containsObject:key]) {
        //说明已经存在这个key值
        [self.arrM addObject:[self getNewKey:key]];
    }else{
        [self.arrM addObject:key];
    }
}

- (NSInteger)hasKeyCount:(NSString *)key{
    NSArray *keys=self.arrM;
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

- (NSString *)getNewKey:(NSString *)key{
    return [NSString stringWithFormat:@"%@_index_%zd",key,[self hasKeyCount:key]+1];
}

@end
