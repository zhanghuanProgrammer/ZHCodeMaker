#import <Foundation/Foundation.h>

@interface ZHBackUp : NSObject
+ (void)backUpProject:(NSString *)project asyncBlock:(NSString*  (^)(void))asyncBlock forVC:(UIViewController *)vc;
@end
