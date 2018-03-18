#import "ZHBackUp.h"

@implementation ZHBackUp
+ (void)backUpProject:(NSString *)project asyncBlock:(NSString* (^)(void))asyncBlock forVC:(UIViewController *)vc{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:vc.view animated:YES];
    
    if (project.length<=0) {
        hud.label.text = @"路径为空!";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
        });
        return;
    }
    hud.label.text = [NSString stringWithFormat:@"正在备份(%@)...",[ZHFileManager fileSizeString:project]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //备份工程
        //有后缀的文件名
        NSString *tempFileName=[ZHFileManager getFileNameFromFilePath:project];
        
        //无后缀的文件名
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:project];
        
        //获取无文件名的路径
        NSString *newFilePath=[project stringByReplacingOccurrencesOfString:tempFileName withString:@""];
        //拿到新的有后缀的文件名
        tempFileName=[tempFileName stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@备份",fileName]];
        
        newFilePath = [newFilePath stringByAppendingPathComponent:tempFileName];
        
        if([ZHFileManager fileExistsAtPath:newFilePath]){
            [ZHFileManager removeItemAtPath:newFilePath];
        }
        
        BOOL result=[ZHFileManager copyItemAtPath:project toPath:newFilePath];
        
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"备份成功,正在处理注释...";
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"备份失败!请先关闭工程(XCode)";
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
            });
            return ;
        }
        
        NSString *resultString=@"";
        // 处理耗时操作的代码块...
        if (asyncBlock) {
            resultString =asyncBlock();
        }
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.label.text=resultString;
            //回调或者说是通知主线程刷新，
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
            });
        });
    });
}
@end
