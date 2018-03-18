#import <Foundation/Foundation.h>

@interface ZHFilterAnnotation : NSObject

@property (nonatomic,strong)NSMutableDictionary *annotationDicM;
- (void)saveAndeFilterAnnotation:(NSString *)annotation forFuncName:(NSString *)funcName;

@end
