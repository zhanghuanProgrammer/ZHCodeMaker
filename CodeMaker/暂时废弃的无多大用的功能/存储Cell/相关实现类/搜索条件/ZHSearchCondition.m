#import "ZHSearchCondition.h"

static NSMutableDictionary *searchCondition;

@implementation ZHSearchCondition

singleton_implementation(ZHSearchCondition)

- (void)loadSearchCondition{
    if (!searchCondition) {
        searchCondition=[NSMutableDictionary dictionary];
    }
}

/**判断是否符合条件*/
- (BOOL)isFitCondition:(NSDictionary *)viewTypeAndCount{
    if (searchCondition.count>0) {
        for (NSString *key in searchCondition) {
            if (viewTypeAndCount[key]!=nil) {
                NSInteger needCount=[searchCondition[key] integerValue];
                NSInteger exsitCount=[viewTypeAndCount[key] integerValue];
                if (exsitCount>=needCount) {
                    continue;
                }else{
                    return NO;
                }
            }else{
                return NO;
            }
        }
        return YES;
    }
    //如果搜索条件为空,就返回所有数据
    return YES;
}

- (NSInteger)countForCategoryView:(NSString *)categoryView{
    if (searchCondition.count>0) {
        NSNumber *num=searchCondition[categoryView];
        if (num) {
            return [num integerValue];
        }
    }
    return 0;
}

/**更新条件*/
- (void)updateCondition:(NSDictionary *)viewTypeAndCount{
    [self loadSearchCondition];
    [self clear];
    [searchCondition setDictionary:viewTypeAndCount];
}

- (void)clear{
    [searchCondition removeAllObjects];
}

@end
