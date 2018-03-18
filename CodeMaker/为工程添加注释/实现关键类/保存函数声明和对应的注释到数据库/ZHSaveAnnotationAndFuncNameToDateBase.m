#import "ZHSaveAnnotationAndFuncNameToDateBase.h"
#import "ZHExtractFuncNameAndAnnotation.h"
#import "ZHFilterAnnotation.h"
#import "ZHFuncNameAndAnnotationModel.h"

@implementation ZHSaveAnnotationAndFuncNameToDateBase

- (NSDictionary *)saveToDataBase:(NSArray *)projectFilePaths{
    
    //提取注释保存到数据库
    NSDictionary *filterAnnotation=[self getFilterAnnotation:projectFilePaths];
    if (filterAnnotation.count>0) {
        NSMutableArray *models=[NSMutableArray array];
        for (NSString *funcName in filterAnnotation) {
            ZHFuncNameAndAnnotationModel *model=[ZHFuncNameAndAnnotationModel new];
            model.funcName=funcName;
            model.annotation=filterAnnotation[funcName];
            [models addObject:model];
        }
        [ZHFuncNameAndAnnotationModel saveObjects:models directoryName:@""];
    }
    return filterAnnotation;
}

- (NSDictionary *)getFilterAnnotation:(NSArray *)projectFilePaths{
    ZHFilterAnnotation *filterAnnotation=[ZHFilterAnnotation new];
    for (NSString *filePath in projectFilePaths) {
        
        ZHExtractFuncNameAndAnnotation *funcNameAndAnnotation=[[ZHExtractFuncNameAndAnnotation alloc]initWithFilePath:filePath];
        [funcNameAndAnnotation removeNoAnnotationFuncName];
        
        if (funcNameAndAnnotation.annotationDicM.count>0) {
            for (NSString *funcName in funcNameAndAnnotation.annotationDicM) {
                [filterAnnotation saveAndeFilterAnnotation:funcNameAndAnnotation.annotationDicM[funcName] forFuncName:funcName];
            }
        }
    }
    return filterAnnotation.annotationDicM;
}

@end
