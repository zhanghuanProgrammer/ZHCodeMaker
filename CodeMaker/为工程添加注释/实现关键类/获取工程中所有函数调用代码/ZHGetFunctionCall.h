#import <Foundation/Foundation.h>
#import "ZHRepearDictionary.h"

@interface ZHGetFunctionCall : NSObject

@property (nonatomic,copy)NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;

/**往某个文件里添加注释*/
- (ZHRepearDictionary *)addAnnotation;

@end
