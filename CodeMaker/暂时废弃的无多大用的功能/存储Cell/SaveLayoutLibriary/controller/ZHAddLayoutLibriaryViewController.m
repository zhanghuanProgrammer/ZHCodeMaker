#import "ZHAddLayoutLibriaryViewController.h"
#import "ZHAddTableViewCellLayoutLibriary.h"
#import "ZHAddCollectionViewCellLayoutLibriary.h"

@interface ZHAddLayoutLibriaryViewController ()

@property (weak, nonatomic) IBOutlet UIButton *importButton;

@property (weak, nonatomic) IBOutlet UIButton *OkButton;

@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)NSMutableArray *codeFileArr;

@property (weak, nonatomic) IBOutlet UILabel *promoteLabel;

@property (nonatomic,copy)NSString *path;
@property (weak, nonatomic) IBOutlet UILabel *showCountLabel;

@end


@implementation ZHAddLayoutLibriaryViewController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showCountLabel.text=@"";
    self.showCountLabel.numberOfLines=0;
    [self.OkButton cornerRadius];
    [self.importButton cornerRadiusWithFloat:25];
    self.promoteLabel.numberOfLines=0;
    self.promoteLabel.text=@"温馨提示:添加现成布局期间可能要花一定的时间(正常1分钟之内,请等待......)";
    
    [self.importButton addTarget:self action:@selector(importAction) forControlEvents:1<<6];
    [self.OkButton addTarget:self action:@selector(OkAction) forControlEvents:1<<6];
    
    self.OkButton.enabled=NO;
    self.OkButton.backgroundColor=[UIColor grayColor];
    
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(leftBarClick)];
    self.title=@"添加现成布局";
}

- (void)leftBarClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)importAction{
    [self.dataArr removeAllObjects];
    
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    [ZHFileManager createFileAtPath:macDesktopPath];
    NSString *Msg=@"文件已经生成在桌面,名字为\"代码助手.m\",请填写要添加已有布局的工程路径";
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
                [ZHAlertAction alertWithMsg:@"工程路径不存在 storyboard 或 xib 文件!请重新填写工程路径!" addToViewController:self ActionSheet:NO];
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
            
            [self.OkButton setTitle:@"开始添加" forState:(UIControlStateNormal)];
            self.OkButton.enabled=YES;
            self.OkButton.backgroundColor=[UIColor blackColor];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"工程路径不存在 storyboard 或 xib 文件!请重新填写工程路径!" addToViewController:self ActionSheet:NO];
            });
        }
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写好,添加新工程" ActionSheet:NO];
}

- (void)OkAction{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
    self.showCountLabel.text=@"";
    hud.label.text = @"正在添加...";
    [self performSelector:@selector(addCellLayoutLibriary) withObject:nil afterDelay:0.2];
}

- (void)addCellLayoutLibriary{
    NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:self.path hasPathExtension:@[@".m",@".h"]];
    
    NSInteger allTableViewCellCount=0,addTableViewCellCount=0,allCollectionViewCellCount=0,addCollectionViewCellCount=0;
    for (NSString *sbOrxib in self.dataArr) {
        //添加TableViewCell
        ZHAddTableViewCellLayoutLibriary *addTableViewCellLayoutLibriary=[ZHAddTableViewCellLayoutLibriary new];
        addTableViewCellLayoutLibriary.filePath=sbOrxib;
        addTableViewCellLayoutLibriary.codeFilePath=fileArr;
        NSArray *tempResultArr=[addTableViewCellLayoutLibriary saveTableViewCellSubViewDraw];
        if (tempResultArr.count==2) {
            allTableViewCellCount+=[tempResultArr[0] integerValue];
            addTableViewCellCount+=[tempResultArr[1] integerValue];
        }
        
        //添加CollectionViewCell
        ZHAddCollectionViewCellLayoutLibriary *addCollectionViewCellLayoutLibriary=[ZHAddCollectionViewCellLayoutLibriary new];
        addCollectionViewCellLayoutLibriary.filePath=sbOrxib;
        addCollectionViewCellLayoutLibriary.codeFilePath=fileArr;
        tempResultArr=[addCollectionViewCellLayoutLibriary saveCollectionViewCellSubViewDraw];
        if (tempResultArr.count==2) {
            allCollectionViewCellCount+=[tempResultArr[0] integerValue];
            addCollectionViewCellCount+=[tempResultArr[1] integerValue];
        }
    }
    
    NSMutableString *resultStringTableViewCell=[NSMutableString string];
    if (allTableViewCellCount>0) {
        [resultStringTableViewCell setString:[NSString stringWithFormat:@"一共找到了%zd个TableViewCell",allTableViewCellCount]];
        if (addTableViewCellCount==allTableViewCellCount) {
            [resultStringTableViewCell appendString:@"已经全部添加入数据库"];
        }else{
            [resultStringTableViewCell appendFormat:@",%zd个曾经已经加过,这次只添加了%zd个新的TableViewCell到数据库",allTableViewCellCount-addTableViewCellCount,addTableViewCellCount];
        }
    }else{
        [resultStringTableViewCell setString:@"没有找到TableViewCell"];
    }
    
    NSMutableString *resultStringCollectionViewCell=[NSMutableString string];
    if (allCollectionViewCellCount>0) {
        [resultStringCollectionViewCell setString:[NSString stringWithFormat:@"一共找到了%zd个CollectionViewCell",allCollectionViewCellCount]];
        if (addCollectionViewCellCount==allCollectionViewCellCount) {
            [resultStringCollectionViewCell appendString:@"已经全部添加入数据库"];
        }else{
            [resultStringCollectionViewCell appendFormat:@",%zd个曾经已经加过,这次只添加了%zd个新的CollectionViewCell到数据库",allCollectionViewCellCount-addCollectionViewCellCount,addCollectionViewCellCount];
        }
    }else{
        [resultStringCollectionViewCell setString:@"没有找到CollectionViewCell"];
    }
    
    [self.OkButton setTitle:@"添加成功" forState:(UIControlStateNormal)];
    self.showCountLabel.text=[NSString stringWithFormat:@"%@\n%@",resultStringTableViewCell,resultStringCollectionViewCell];
    self.OkButton.enabled=NO;
    self.OkButton.backgroundColor=[UIColor grayColor];
    
    //回调或者说是通知主线程刷新，
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

@end
