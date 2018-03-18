#import <Foundation/Foundation.h>

@interface ZHFuncNameAndAnnotation : NSObject
@property (nonatomic,copy)NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;
/**获取处理过的FuncName和Annotation,主要是去除干扰字符串*/
- (NSString *)removeImplementation;
- (NSInteger)getEndFuncIndex:(NSString *)text rangeLocation:(NSInteger)rangeLocation stopIndex:(NSInteger)stopIndex;
@end
