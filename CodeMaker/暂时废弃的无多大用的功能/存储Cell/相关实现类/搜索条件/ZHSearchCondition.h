#import <Foundation/Foundation.h>

@interface ZHSearchCondition : NSObject

singleton_interface(ZHSearchCondition)

/**判断是否符合条件*/
- (BOOL)isFitCondition:(NSDictionary *)viewTypeAndCount;

- (NSInteger)countForCategoryView:(NSString *)categoryView;

/**更新条件*/
- (void)updateCondition:(NSDictionary *)viewTypeAndCount;

- (void)clear;

@end
