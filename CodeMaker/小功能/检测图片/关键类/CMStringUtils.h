
#import <Foundation/Foundation.h>

@interface CMStringUtils : NSObject

+ (NSArray *)images:(NSString *)project;
/**导出所有切图*/
+ (void)emportAllImageFile:(NSString *)project;
/**批量分类哪些可导入,哪些不能*/
+ (void)emportCategoryImageFile:(NSString *)project;

@end
