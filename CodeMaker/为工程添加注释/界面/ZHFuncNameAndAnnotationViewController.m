#import "ZHFuncNameAndAnnotationViewController.h"
#import "ZHInsertFuncNameAndAnnotation.h"

@interface ZHFuncNameAndAnnotationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *importButton;

@property (weak, nonatomic) IBOutlet UIButton *OkButton;

@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)NSMutableArray *viewControllerArrM;

@property (weak, nonatomic) IBOutlet UILabel *promoteLabel;

@property (nonatomic,copy)NSString *path;
@property (weak, nonatomic) IBOutlet UILabel *showCountLabel;

@end


@implementation ZHFuncNameAndAnnotationViewController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showCountLabel.text=@"";
    [self.OkButton cornerRadius];
    [self.importButton cornerRadiusWithFloat:25];
    self.promoteLabel.numberOfLines=0;
    self.promoteLabel.text=@"温馨提示:添加注释期间可能要花一定的时间(正常1分钟之内,请等待......)";
    
    [self.importButton addTarget:self action:@selector(importAction) forControlEvents:1<<6];
    [self.OkButton addTarget:self action:@selector(OkAction) forControlEvents:1<<6];
    
    self.OkButton.enabled=NO;
    self.OkButton.backgroundColor=[UIColor grayColor];
    
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(leftBarClick)];
    self.title=@"为工程添加注释";
}

- (void)leftBarClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)filter:(NSString *)fileName{
    NSArray *arr=@[@"main",@"_______Tests",@"project",@"_______UITests",@""];
    if ([arr containsObject:fileName]) {
        return YES;
    }else{
        return NO;
    }
}
/**从路径中获取可修改的文件名*/
- (NSArray *)getChangeNamesFromFilePath:(NSString *)filePath{
    NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m",@".mm"]];
    NSMutableArray *arrM=[NSMutableArray array];
    
    for (NSString *filePath in fileArr) {
        
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        if ([self filter:fileName]==NO) {
            [arrM addObject:filePath];
        }
    }
    
    return arrM;
}

- (void)OkAction{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
    
    hud.label.text = [NSString stringWithFormat:@"正在备份(%@)...",[ZHFileManager fileSizeString:self.path]];
    self.showCountLabel.text=@"";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //备份工程
        //有后缀的文件名
        NSString *tempFileName=[ZHFileManager getFileNameFromFilePath:self.path];
        
        //无后缀的文件名
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:self.path];
        
        //获取无文件名的路径
        NSString *newFilePath=[self.path stringByReplacingOccurrencesOfString:tempFileName withString:@""];
        //拿到新的有后缀的文件名
        tempFileName=[tempFileName stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@备份",fileName]];
        
        newFilePath = [newFilePath stringByAppendingPathComponent:tempFileName];
        
        if([ZHFileManager fileExistsAtPath:newFilePath]){
            [ZHFileManager removeItemAtPath:newFilePath];
        }
        
        BOOL result=[ZHFileManager copyItemAtPath:self.path toPath:newFilePath];
        if (result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"备份成功,正在添加注释...";
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"备份失败!请先关闭工程(XCode)";
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
            return ;
        }
        
        // 处理耗时操作的代码块...
        NSInteger countInsert=[[ZHInsertFuncNameAndAnnotation new]insertFuncNameAndAnnotation:[self getChangeNamesFromFilePath:self.path]];
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.label.text=[NSString stringWithFormat:@"添加成功,添加了%ld个",countInsert];
            
            [self.OkButton setTitle:@"添加成功" forState:(UIControlStateNormal)];
            self.showCountLabel.text=[NSString stringWithFormat:@"添加成功,添加了%ld个",countInsert];
            self.OkButton.enabled=NO;
            self.OkButton.backgroundColor=[UIColor grayColor];
            
            //回调或者说是通知主线程刷新，
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        });
    });
}

- (void)importAction{
    [self.dataArr removeAllObjects];
    
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    [ZHFileManager createFileAtPath:macDesktopPath];
    NSString *Msg=@"文件已经生成在桌面,名字为\"代码助手.m\",请填写要转换的工程路径";
    [ZHAlertAction alertWithTitle:@"导入工程" withMsg:Msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        
        NSString *path=[NSString stringWithContentsOfFile:macDesktopPath encoding:NSUTF8StringEncoding error:nil];
        if ([path rangeOfString:@"\n"].location!=NSNotFound) {
            path=[path stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        if ([ZHFileManager fileExistsAtPath:path]==NO) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"路径不存在!请重新填写!" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:path hasPathExtension:@[@".storyboard"]];
        
        if(fileArr.count==0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"工程路径不存在storyboard文件!请重新填写工程路径!" addToViewController:self ActionSheet:NO];
            });
            return;
        }
        
        for (NSString *fileName in fileArr) {
            NSString *tempStr=[ZHFileManager getFileNameNoPathComponentFromFilePath:fileName];
            if ([tempStr rangeOfString:@"备份"].location!=NSNotFound||[tempStr isEqualToString:@"LaunchScreen"]) {
                continue;
            }
            
            [self.dataArr addObject:fileName];
        }
        
        if (self.dataArr.count>0) {
            self.path=path;
            [self.importButton setTitle:[ZHFileManager getFileNameNoPathComponentFromFilePath:path] forState:(UIControlStateNormal)];
            
            [self.OkButton setTitle:@"开始转换" forState:(UIControlStateNormal)];
            self.OkButton.enabled=YES;
            self.OkButton.backgroundColor=[UIColor blackColor];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"工程路径不存在相关的storyboard文件!请重新填写工程路径!" addToViewController:self ActionSheet:NO];
            });
        }
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写好,添加新工程" ActionSheet:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
