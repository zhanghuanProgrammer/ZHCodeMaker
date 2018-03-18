
#import "ZHOutPutLayoutLibriary.h"
#import "ZHStoryboardManager.h"
#import "ZHStroyBoardToFrameMVC.h"
#import "ZHStroyBoardToMVC.h"
#import "ZHStroyBoardToFrameProject.h"
#import "ZHStroyBoardToPureHandProject.h"

@implementation ZHOutPutLayoutLibriary

/**纯手写模式-marsony*/
+ (NSString *)outPut_PureHand_marsonyCodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filesPath=[self outPut_noPureHandCodePath_TableViewCell:xmlCodePath withCellName: cellName fileAddress:fileAddress modelAddress:modelAddress];
    
    [[ZHStroyBoardToPureHandProject new] transformProjectToPureHandProject:filesPath];
    
    return filesPath;
}

/**纯手写模式-frame*/
+ (NSString *)outPut_PureHand_frameCodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filesPath=[self outPut_noPureHandCodePath_TableViewCell:xmlCodePath withCellName: cellName fileAddress:fileAddress modelAddress:modelAddress];
    
    [[ZHStroyBoardToFrameProject new] transformProjectToFrameProject:filesPath];
    
    return filesPath;
}

/**非纯手写模式  TableViewCell*/
+ (NSString *)outPut_noPureHandCodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filePath=[ZHHelp creatCurDataDirectorToMacDocuments];
    
    //生成StoryBoard到桌面
    NSString *storyBoardPath=[self createStoryBoard_outPut_PureHand_CodePath_TableViewCell:xmlCodePath withCellName: cellName filePath:filePath];
    
    //生成model,view,viewController到桌面
    NSString *filesPath=[[ZHStroyBoardToMVC new] StroyBoard_To_MVC:storyBoardPath];
    [ZHFileManager moveItemAtPath:storyBoardPath toPath:[filesPath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:storyBoardPath]]];
    
    //删除StoryBoard
    if([ZHFileManager fileExistsAtPath:filePath])
        [ZHFileManager removeItemAtPath:filePath];
    
    [self saveCodeCellFileWithFilesPath:filesPath fileAddress:fileAddress];
    [self saveCodeModelFileWithFilesPath:filesPath modelAddress:modelAddress];
    
    return filesPath;
}

/**纯手写模式 生成StoryBoard到桌面 TableViewCell*/
+ (NSString *)createStoryBoard_outPut_PureHand_CodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName filePath:(NSString *)filePath{
    
    NSString *xmlCode=[NSString stringWithContentsOfFile:xmlCodePath encoding:NSUTF8StringEncoding error:nil];
    CGFloat height=[ZHHelp getCellHeight:xmlCode];
    if(height<=0)height=200;
    xmlCode=[ZHHelp getTableCellsInsertCells:@[xmlCode]];
    xmlCode=[xmlCode stringByReplacingOccurrencesOfString:@"$$###$$" withString:[NSString stringWithFormat:@"%ld",(NSInteger)height]];
    filePath=[filePath stringByAppendingPathComponent:[@"Main" stringByAppendingString:@".storyboard"]];
    [xmlCode writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return filePath;
}

/**纯手写模式-marsony  CollectionViewCell*/
+ (NSString *)outPut_PureHand_marsonyCodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filesPath=[self outPut_noPureHandCodePath_CollectionViewCell:xmlCodePath withCellName: cellName fileAddress:fileAddress modelAddress:modelAddress];
    
    [[ZHStroyBoardToPureHandProject new] transformProjectToPureHandProject:filesPath];
    
    return filesPath;
}

/**纯手写模式-frame  CollectionViewCell*/
+ (NSString *)outPut_PureHand_frameCodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filesPath=[self outPut_noPureHandCodePath_CollectionViewCell:xmlCodePath withCellName: cellName fileAddress:fileAddress modelAddress:modelAddress];
    
    [[ZHStroyBoardToFrameProject new] transformProjectToFrameProject:filesPath];
    
    return filesPath;
}

/**非纯手写模式  CollectionViewCell*/
+ (NSString *)outPut_noPureHandCodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filePath=[ZHHelp creatCurDataDirectorToMacDocuments];
    
    //生成StoryBoard到桌面
    NSString *storyBoardPath=[self createStoryBoard_outPut_PureHand_CodePath_CollectionViewCell:xmlCodePath withCellName: cellName filePath:filePath];
    
    //生成model,view,viewController到桌面
    NSString *filesPath=[[ZHStroyBoardToMVC new] StroyBoard_To_MVC:storyBoardPath];
    [ZHFileManager moveItemAtPath:storyBoardPath toPath:[filesPath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:storyBoardPath]]];
    
    //删除StoryBoard
    if([ZHFileManager fileExistsAtPath:filePath])
        [ZHFileManager removeItemAtPath:filePath];
    
    [self saveCodeCellFileWithFilesPath:filesPath fileAddress:fileAddress];
    [self saveCodeModelFileWithFilesPath:filesPath modelAddress:modelAddress];
    
    return filesPath;
    
}

+ (void)saveCodeCellFileWithFilesPath:(NSString *)filesPath fileAddress:(NSString *)fileAddress{
    NSString *cellsDirector=[filesPath stringByAppendingPathComponent:@"ViewController/view"];
    NSArray *cells=[ZHFileManager subPathFileArrInDirector:cellsDirector];
    for (NSString *cellPath in cells) {
        
        if([ZHFileManager fileExistsAtPath:cellPath])
            [ZHFileManager removeItemAtPath:cellPath];
    }
    cells=[NSArray arrayWithJsonString:fileAddress];
    
    for (NSString *cellPath in cells) {
        if([ZHFileManager fileExistsAtPath:cellPath])
            [ZHFileManager copyItemAtPath:cellPath toPath:[cellsDirector stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:cellPath]]];
    }
}
+ (void)saveCodeModelFileWithFilesPath:(NSString *)filesPath modelAddress:(NSString *)modelAddress{
    NSArray *modelsOrginal=[NSArray arrayWithJsonString:modelAddress];
    NSString *orginalModelName,*oldModelName;
    if (modelsOrginal.count>0) {
        NSString *modelsDirector=[filesPath stringByAppendingPathComponent:@"ViewController/model"];
        NSArray *models=[ZHFileManager subPathFileArrInDirector:modelsDirector];
        
        for (NSString *modelPath in models) {
            if([ZHFileManager fileExistsAtPath:modelPath]){
                [ZHFileManager removeItemAtPath:modelPath];
                oldModelName=[ZHFileManager getFileNameNoPathComponentFromFilePath:modelPath];
            }
        }
        
        for (NSString *modelPath in modelsOrginal) {
            if([ZHFileManager fileExistsAtPath:modelPath]){
                orginalModelName=[ZHFileManager getFileNameNoPathComponentFromFilePath:modelPath];
                [ZHFileManager copyItemAtPath:modelPath toPath:[modelsDirector stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:modelPath]]];
            }
        }
        
        if (![oldModelName isEqualToString:orginalModelName]) {
            //修改viewcontroller的代码
            NSString *controllersDirector=[filesPath stringByAppendingPathComponent:@"ViewController/controller"];
            
            NSDictionary *fileChangeDic=@{oldModelName:orginalModelName};
            NSString *jsonString=[fileChangeDic jsonPrettyStringEncoded];
            NSString *macDesktopPath=[ZHFileManager getMacDesktop];
            macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
            [jsonString writeToFile:macDesktopPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [ZHChangeCodeFileName changeMultipleCodeFileName:controllersDirector];
        }
    }
}

/**纯手写模式 生成StoryBoard到桌面  CollectionViewCell*/
+ (NSString *)createStoryBoard_outPut_PureHand_CodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName filePath:(NSString *)filePath{
    
    NSString *xmlCode=[NSString stringWithContentsOfFile:xmlCodePath encoding:NSUTF8StringEncoding error:nil];
    CGFloat height=[ZHHelp getCellHeight:xmlCode];
    CGFloat width=[ZHHelp getCellWidth:xmlCode];
    if(height<=0)height=200;
    if(width<=0)width=200;
    
    xmlCode=[ZHHelp getCollectionCellsInsertCells:@[xmlCode]];
    xmlCode=[xmlCode stringByReplacingOccurrencesOfString:@"$$$###$$$" withString:[NSString stringWithFormat:@"%ld",(NSInteger)width]];
    xmlCode=[xmlCode stringByReplacingOccurrencesOfString:@"###$$$###" withString:[NSString stringWithFormat:@"%ld",(NSInteger)height]];
    filePath=[filePath stringByAppendingPathComponent:[@"Main" stringByAppendingString:@".storyboard"]];
    [xmlCode writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return filePath;
}

+ (void)changeFileNameWithFilesPath:(NSString *)filesPath showAlertToViewController:(UIViewController *)vc{

    NSArray *fileArr=[ZHChangeCodeFileName getChangeNamesFromFilePath:filesPath];
    NSString *jsonString=[ZHChangeCodeFileName getOldNameAndSetStringByPathArr:fileArr];
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    [jsonString writeToFile:macDesktopPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZHAlertAction alertWithTitle:@"请在mac桌面上的代码助手.m,重新修改MVC文件名,请命名不要以数字开头" withMsg:@"修改好了,再点击下面的生成代码选项" addToViewController:vc ActionSheet:NO otherButtonBlocks:@[^{
            [ZHChangeCodeFileName changeMultipleCodeFileName:filesPath];
            [MBProgressHUD showHUDAddedToView:vc.view withText:@"已生成代码在桌面" withDuration:1 animated:YES];
        },^{
            [MBProgressHUD showHUDAddedToView:vc.view withText:@"已生成代码在桌面" withDuration:1 animated:YES];
        }] otherButtonTitles:@[@"已修改填写好,生成代码到桌面",@"不想修改"]];
    });
}

@end
