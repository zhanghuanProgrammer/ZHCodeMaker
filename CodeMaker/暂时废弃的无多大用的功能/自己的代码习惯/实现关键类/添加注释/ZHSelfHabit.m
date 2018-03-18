#import "ZHSelfHabit.h"

@implementation ZHSelfHabit

- (void)Begin:(NSString *)str{
    str=[ZHNSString removeSpacePrefix:str];
    str=[ZHNSString removeSpaceSuffix:str];
    if ([ZHFileManager fileExistsAtPath:str]) {
        NSDictionary *dic=[ZHSaveDataToFMDB selectDataWithIdentity:@"SelfHabitAnnotation"];
        [ZHSelfHabit addSelfHabitAnnotation:str withHabitAnnotation:dic];
    }
    [self saveData:@""];
}

/**自己的习惯注释*/
+ (void)selfHabitAnnotationForVC:(UIViewController *)vc{
    [CodeAssistantFileManager clearnFileContent];
    
    NSDictionary *dic=[ZHSaveDataToFMDB selectDataWithIdentity:@"SelfHabitAnnotation"];
    NSMutableDictionary *dicM;
    if (dic==nil) dicM=[NSMutableDictionary dictionary];
    else dicM=[[ZHJson new] copyMutableDicFromDictionary:dic];
    [dicM setValue:@"<#要添加的函数注释#>" forKey:@"<#要添加的函数声明#>"];
    [CodeAssistantFileManager saveContent:[dicM jsonPrettyStringEncoded]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZHAlertAction alertWithTitle:@"请把要添加或修改的 \"习惯注释\" 填写在桌面的\"代码助手.m\"中" withMsg:nil addToViewController:vc withCancleBlock:nil withOkBlock:^{
            NSDictionary *dic=[CodeAssistantFileManager getJsonDicFromFile];
            NSMutableDictionary *dicM;
            if (dic==nil) dicM=[NSMutableDictionary dictionary];
            else dicM=[[ZHJson new] copyMutableDicFromDictionary:dic];
            [dicM removeObjectForKey:@"<#要添加的函数声明#>"];
            [ZHSaveDataToFMDB insertDataWithData:dic WithIdentity:@"SelfHabitAnnotation"];
            [MBProgressHUD showHUDAddedToView:[UIApplication sharedApplication].keyWindow withText:@"添加或修改完成" withDuration:0.5 animated:YES];
            [CodeAssistantFileManager saveFileContentToLog];
        } cancelButtonTitle:@"取消" OkButtonTitle:@"已修改完成,保存" ActionSheet:NO];
    });
}

/**添加习惯注释到代码文件中*/
+ (void)addSelfHabitAnnotation:(NSString *)filePath{
    NSDictionary *dic=[ZHSaveDataToFMDB selectDataWithIdentity:@"SelfHabitAnnotation"];
    NSArray *filePaths=[CodeAssistantFileManager getFilePaths];
    for (NSString *filePath in filePaths) {
        [self addSelfHabitAnnotation:filePath withHabitAnnotation:dic];
    }
}

/**添加习惯注释到代码文件中*/
+ (void)addSelfHabitAnnotation:(NSString *)filePath withHabitAnnotation:(NSDictionary *)HabitAnnotation{
    if (HabitAnnotation.count<=0) return;
    NSString *text=[CodeAssistantFileManager getOtherFileContent:filePath];
    for (NSString *funcName in HabitAnnotation) {
        if ([text rangeOfString:funcName].location!=NSNotFound) {
            text=[text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n%@",HabitAnnotation[funcName],funcName] withString:[@"\n" stringByAppendingString:funcName]];
            text=[text stringByReplacingOccurrencesOfString:[@"\n" stringByAppendingString:funcName] withString:[NSString stringWithFormat:@"\n%@\n%@",HabitAnnotation[funcName],funcName]];
        }
    }
    [CodeAssistantFileManager saveOtherFileContent:text toFilePath:filePath];
}

@end
