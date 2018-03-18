#import "ZHPerformFuncition.h"

@interface ZHPerformFuncition ()
@property (nonatomic,strong)NSMutableArray *shouldChangeFiles;
@end

@implementation ZHPerformFuncition

/**一键处理*/
- (NSString *)performFuncitionAuto{
    if (![self checkDefaultProject])return @"请先选择默认工程";
    [self.shouldChangeFiles removeAllObjects];
    [self collectShouldChangeFiles];
    if (![self checkHaveChangeFiles])return @"没有检测到工程需要处理";
    [self performFuncitionForFile];
    return @"处理完成";
}

/**检测默认工程是否存在*/
- (BOOL)checkDefaultProject{
    NSString *FastCodeCurProject=[ZHSaveDataToFMDB selectDataWithIdentity:@"FastCodeCurProject"];
    if (FastCodeCurProject.length>0) {
        if ([ZHFileManager fileExistsAtPath:FastCodeCurProject]) {
            return YES;
        }
    }
    return NO;
}

/**检测并获取哪些文件是需要作出修改和处理的*/
- (void)collectShouldChangeFiles{
    NSString *FastCodeCurProject=[ZHSaveDataToFMDB selectDataWithIdentity:@"FastCodeCurProject"];
    
    NSArray *files=[ZHFileManager subPathFileArrInDirector:FastCodeCurProject hasPathExtension:@[@".h",@".m",@".mm",@".cpp"]];
    
    for (NSString *filePath in files) {
        NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSInteger beginCount=[ZHNSString getCountTargetString:@"/**<CodeBegin>*/" inText:text];
        NSInteger endCount=[ZHNSString getCountTargetString:@"/**<CodeEnd>*/" inText:text];
        if (beginCount>0&&endCount>0&&beginCount==endCount) {
            [self.shouldChangeFiles addObject:filePath];
        }
    }
}

/**检测工程是否存在有需要处理的文件*/
- (BOOL)checkHaveChangeFiles{
    return self.shouldChangeFiles.count>0;
}

/**开始真正的循环每个需要处理的文件进行处理*/
- (void)performFuncitionForFile{
    for (NSString *filePath in self.shouldChangeFiles) {
        NSMutableString *text=[NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *performFuncitionCodes=[self getPerformFuncitionCodesFromText:text];
        for (NSString *performFuncitionCode in performFuncitionCodes) {
            [self dealWithPerformFuncitionCode:performFuncitionCode forText:text forFilePath:filePath];
        }
        [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

/**获取需要处理的代码块*/
- (NSArray *)getPerformFuncitionCodesFromText:(NSString *)text{
    NSMutableArray *performFuncitionCodes=[NSMutableArray array];
    NSArray *midStrings=[ZHNSString getMidStringBetweenLeftString:@"/**<CodeBegin>*/" RightString:@"/**<CodeEnd>*/" withText:text getOne:NO withIndexStart:0 stopString:nil];
    for (NSString *str in midStrings) {
        if (str.length>0) {
            [performFuncitionCodes addObject:[NSString stringWithFormat:@"%@%@%@",@"/**<CodeBegin>*/",str,@"/**<CodeEnd>*/"]];
        }
    }
    return performFuncitionCodes;
}

- (void)dealWithPerformFuncitionCode:(NSString *)performFuncitionCode forText:(NSMutableString *)text forFilePath:(NSString *)filePath{
    //获取功能实现类名
    NSString *classFuncName=[self getClassFuncName:performFuncitionCode];
    NSString *parameterContent=[self getParameterContent:performFuncitionCode];
    NSString *outCome=[self performFuncition:classFuncName parameterContent:parameterContent];
    if ([ZHNSString getCountTargetString:@"不存在Begin方法" inText:outCome]>0) {
        NSString *performFuncitionCodeTemp=[performFuncitionCode stringByReplacingOccurrencesOfString:parameterContent withString:outCome];
        [text replaceOccurrencesOfString:performFuncitionCode withString:performFuncitionCodeTemp options:(NSLiteralSearch) range:NSMakeRange(0, text.length)];
    }else{
        if(outCome.length==0){
            NSString *temptext=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            [text setString:temptext];
        }
        [text replaceOccurrencesOfString:performFuncitionCode withString:outCome options:(NSLiteralSearch) range:NSMakeRange(0, text.length)];
    }
}

/**获取功能实现类名*/
- (NSString *)getClassFuncName:(NSString *)performFuncitionCode{
    NSArray *classFuncNames=[ZHNSString getMidStringBetweenLeftString:@"/**<实现类:" RightString:@">*/" withText:performFuncitionCode getOne:YES withIndexStart:0 stopString:nil];
    if (classFuncNames.count>0) {
        NSString *classFuncName=classFuncNames[0];
        if (classFuncName.length>0) {
            return classFuncName;
        }
    }
    return @"";
}

/**获取参数内容*/
- (NSString *)getParameterContent:(NSString *)performFuncitionCode{
    NSMutableArray *parameterContent=[NSMutableArray array];
    NSArray *arr=[performFuncitionCode componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpacePrefix:str];
        tempStr=[ZHNSString removeSpaceSuffix:tempStr];
        if ([tempStr hasPrefix:@"/**<"]&&[tempStr hasSuffix:@">*/"]) {
            continue;
        }
        [parameterContent addObject:str];
    }
    if(parameterContent.count>0)
        return [parameterContent componentsJoinedByString:@"\n"];
    return @"";
}

- (NSString *)performFuncition:(NSString *)className parameterContent:(NSString *)parameterContent{
    
    Class class = NSClassFromString(className);
    id myClass=[[class alloc] init];
    if([myClass respondsToSelector:@selector(Begin:)]){
        [myClass performSelector:@selector(Begin:) withObject:parameterContent];
        NSString *outCome=[ZHBlockSingleCategroy defaultMyblock][@"value"];
        if (outCome.length>0) {
            return outCome;
        }
    }else{
        return [NSString stringWithFormat:@"%@不存在Begin方法",className];
    }
    return @"";
}

/**懒加载*/
- (NSMutableArray *)shouldChangeFiles{
    if (!_shouldChangeFiles) {
        _shouldChangeFiles=[NSMutableArray array];
    }
    return _shouldChangeFiles;
}

@end
