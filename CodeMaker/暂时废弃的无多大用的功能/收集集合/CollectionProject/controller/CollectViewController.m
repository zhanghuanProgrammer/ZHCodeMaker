#import "CollectViewController.h"

#import "CollectTableViewCell.h"

#import "CreatFatherFile.h"

#import "SearchChangeFileViewController.h"

#import "WaterPhotoViewController.h"

@interface CollectViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation CollectViewController
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
        [_dataArr addObjectsFromArray:[ZHSaveDataToFMDB selectDataWithIdentity:[self.type stringByAppendingString:@"CollectCellModel"]]];
    }
    return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.title=@"收集集合";
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"添加(集合文件夹)" TintColor:[UIColor blackColor] target:self action:@selector(addProjectAction)];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addProjectAction{
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    [ZHFileManager createFileAtPath:macDesktopPath];
    NSString *Msg=@"文件已经生成在桌面,名字为\"代码助手.m\",请填写新的工程路径";
    [ZHAlertAction alertWithTitle:@"添加新的工程" withMsg:Msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        
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
        
        if ([ZHFileManager getFileType:path]==FileTypeFile) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"你填的路径为单个文件,请添加文件夹 !" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        if ([ZHFileManager getFileType:path]==FileTypeUnkown) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"类型未知!" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        NSArray *subDirectors=[ZHFileManager contentsDirectorArrInDirector:path];
        if (subDirectors.count==0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"为了分类管理,请为其分类到各个一级文件夹中!" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        for (NSString *director in subDirectors) {
            NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:director];
            
            BOOL repeat=NO;
            for (CollectCellModel *model in self.dataArr) {
                
                if ([model.title isEqualToString:fileName]&&[model.subTitle isEqualToString:director]) {
                    repeat=YES;
                    break;
                }
            }
            
            if (repeat==NO) {
                CollectCellModel *changeCodeFileNameModel=[CollectCellModel new];
                changeCodeFileNameModel.title=fileName;
                changeCodeFileNameModel.subTitle=director;
                [self.dataArr addObject:changeCodeFileNameModel];
            }
        }
        
        [self.tableView reloadData];
        
        if (self.dataArr.count>0) {
            [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:[self.type stringByAppendingString:@"CollectCellModel"]];
        }
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写好,添加新工程" ActionSheet:NO];
}

#pragma mark - TableViewDelegate实现的方法:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id modelObjct=self.dataArr[indexPath.row];
    if ([modelObjct isKindOfClass:[CollectCellModel class]]){
        CollectTableViewCell *changeCodeFileNameCell=[tableView dequeueReusableCellWithIdentifier:@"CollectTableViewCell"];
        CollectCellModel *model=modelObjct;
        [changeCodeFileNameCell refreshUI:model];
        return changeCodeFileNameCell;
    }
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id modelObjct=self.dataArr[indexPath.row];
    if ([modelObjct isKindOfClass:[CollectCellModel class]]){
        CollectCellModel *model=modelObjct;
        //进入另外一个界面
        
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
        
        hud.label.text = @"加载中...";
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            WaterPhotoViewController *vc=[WaterPhotoViewController new];
            vc.director=model.subTitle;
            
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([ZHFileManager fileExistsAtPath:vc.director]==NO) {
                    hud.label.text = @"路径不存在!请删除";
                    dispatch_async(dispatch_get_main_queue(), ^{
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    });
                }else{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
                }
            });
        });
    }
}

/**是否可以编辑*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return YES;
}
/**编辑风格*/
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
/**设置编辑的控件  删除,置顶,收藏*/
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //设置删除按钮
    UITableViewRowAction *deleteRowAction=[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:[self.type stringByAppendingString:@"CollectCellModel"]];
    }];
    return  @[deleteRowAction];
}
@end
