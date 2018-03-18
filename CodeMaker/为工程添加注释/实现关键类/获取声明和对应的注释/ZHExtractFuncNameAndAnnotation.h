#import <Foundation/Foundation.h>

@interface ZHExtractFuncNameAndAnnotation : NSObject
@property (nonatomic,copy)NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;
- (NSDictionary *)getFuncNameAndAnnotationByRegex;
- (NSArray *)getFuncNamesSortByRange;
- (NSString *)filterText;
- (NSMutableDictionary *)annotationDicM;
- (void)removeNoAnnotationFuncName;
@end
