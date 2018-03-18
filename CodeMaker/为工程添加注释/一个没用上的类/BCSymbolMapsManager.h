#import <Foundation/Foundation.h>

@interface BCSymbolMapsManager : NSObject

@property (nonatomic,copy)NSString *filePath;
@property (nonatomic,strong)NSArray *allFuncNames;
@property (nonatomic,strong)NSArray *allPropertys;

- (instancetype)initWithFilePath:(NSString *)filePath;
/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和类方法*/
- (NSDictionary *)getClassCompressionFuncNameAndRelatedFilePath;
/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和实例方法*/
- (NSDictionary *)getObjectCompressionFuncNameAndRelatedFilePath;
/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和实例方法(除去成员变量的getter和setter)*/
- (NSDictionary *)getObjectCompressionFuncNameNoContainGetterAndSetterAndRelatedFilePath;
/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和成员变量名*/
- (NSDictionary *)getPropertyAndRelatedFilePath;


//以下的代码可以获取到某个工程下BCSymbolMaps文件中的所有基本信息
//BCSymbolMapsManager *manager=[[BCSymbolMapsManager alloc]initWithFilePath:@"/Users/mac/Desktop/project.txt"];
//NSDictionary *classFuncNameDic=[manager getClassCompressionFuncNameAndRelatedFilePath];
//NSDictionary *objectFuncNameDic=[manager getObjectCompressionFuncNameAndRelatedFilePath];
//NSDictionary *objectFuncNameDicNoContainGetter=[manager getObjectCompressionFuncNameNoContainGetterAndSetterAndRelatedFilePath];
//NSDictionary *propertyDic=[manager getPropertyAndRelatedFilePath];
//[[classFuncNameDic jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/classFuncNameDic.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//[[objectFuncNameDic jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/objectFuncNameDic.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//[[objectFuncNameDicNoContainGetter jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/objectFuncNameDicNoContainGetter.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//[[propertyDic jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/propertyDic.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];

//- (void)getBCSymbolMaps{
//    BCSymbolMapsManager *manager=[[BCSymbolMapsManager alloc]initWithFilePath:@"/Users/mac/Desktop/project.txt"];
//    NSDictionary *classFuncNameDic=[manager getClassCompressionFuncNameAndRelatedFilePath];
//    NSDictionary *objectFuncNameDicNoContainGetter=[manager getObjectCompressionFuncNameNoContainGetterAndSetterAndRelatedFilePath];
//    NSMutableArray *arrM=[NSMutableArray array];
//    for (NSString *path in classFuncNameDic) {
//        NSArray *funcNames=classFuncNameDic[path];
//        for (NSString *funcName in funcNames) {
//            if (![arrM containsObject:funcName]) {
//                [arrM addObject:funcName];
//            }
//        }
//    }
//    for (NSString *path in objectFuncNameDicNoContainGetter) {
//        NSArray *funcNames=classFuncNameDic[path];
//        for (NSString *funcName in funcNames) {
//            if (![arrM containsObject:funcName]) {
//                [arrM addObject:funcName];
//            }
//        }
//    }
//    [[arrM jsonPrettyStringEncoded] writeToFile:@"/Users/mac/Desktop/code2.m" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//}
@end
