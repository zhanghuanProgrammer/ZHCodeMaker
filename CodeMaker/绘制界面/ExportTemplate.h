#import <Foundation/Foundation.h>

@interface ExportTemplate : NSObject
+ (BOOL)exportTemplateForStoryboardWithParameter:(NSDictionary *)parameter fileName:(NSString *)fileName;
@end
