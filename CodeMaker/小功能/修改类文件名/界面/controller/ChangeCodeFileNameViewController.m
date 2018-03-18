#import "ChangeCodeFileNameViewController.h"

#import "ChangeCodeFileNameTableViewCell.h"

#import "CreatFatherFile.h"

#import "SearchChangeFileViewController.h"

@interface ChangeCodeFileNameViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation ChangeCodeFileNameViewController
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
        [_dataArr addObjectsFromArray:[ZHSaveDataToFMDB selectDataWithIdentity:@"ChangeCodeFileNameCellModel"]];
    }
    return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.title=@"修改编程文件名";
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"添加(文件夹/工程)" TintColor:[UIColor blackColor] target:self action:@selector(addProjectAction)];
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
                [ZHAlertAction alertWithMsg:@"你填的路径为单个文件,请选择列表中 \"修改单个文件\" !" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        if ([ZHFileManager getFileType:path]==FileTypeUnkown) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"类型未知!" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:path];
        
        BOOL needAdd=YES;
        for (ChangeCodeFileNameCellModel *model in self.dataArr) {
            if ([model.title isEqualToString:fileName]&&[model.subTitle isEqualToString:path]) {
                needAdd=NO;
                break;
            }
        }
        
        if(needAdd){
            ChangeCodeFileNameCellModel *changeCodeFileNameModel=[ChangeCodeFileNameCellModel new];
            changeCodeFileNameModel.title=fileName;
            changeCodeFileNameModel.subTitle=path;
            [self.dataArr addObject:changeCodeFileNameModel];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"已经存在,不能重复添加!" addToViewController:self ActionSheet:NO];
            });
        }
        
        [self.tableView reloadData];
        
        if (self.dataArr.count>0) {
            [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:@"ChangeCodeFileNameCellModel"];
        }
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写好,添加新工程" ActionSheet:NO];
}

/**修改单个文件*/
- (void)changeSingleFile{
    CreatFatherFile *tempObj=[CreatFatherFile new];
    [tempObj creatFatherFile:@"代码助手" andData:@[@"旧文件路径",@"新文件路径,请修改文件名"]];
    NSString *Msg=@"文件已经生成在桌面,名字为\"代码助手.m\",请填写旧文件路径和新文件路径";
    
    [ZHAlertAction alertWithTitle:nil withMsg:Msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSDictionary *dic=[tempObj getDicFromFileName:@"代码助手"];
        NSString *oldName=dic[@"旧文件路径"];
        NSString *newName=dic[@"新文件路径,请修改文件名"];
        if ([tempObj judge:oldName]==NO) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"没有填写 旧文件路径 !" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        if ([ZHFileManager fileExistsAtPath:oldName]==NO) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"旧文件路径不存在 !" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        if ([tempObj judge:newName]==NO) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"没有填写 新文件路径 !" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        if ([oldName isEqualToString:newName]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"旧文件路径 和 新文件路径 一样!" addToViewController:self ActionSheet:NO];
            });
            return ;
        }
        
        NSString *result=[ZHChangeCodeFileName changeSingleFile:oldName newPath:newName];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZHAlertAction alertWithMsg:result addToViewController:self ActionSheet:NO];
        });
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写好,开始修改" ActionSheet:NO];
}

#pragma mark - TableViewDelegate实现的方法:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.dataArr.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        ChangeCodeFileNameCellModel *changeCodeFileNameModel=[ChangeCodeFileNameCellModel new];
        changeCodeFileNameModel.title=@"修改单个文件";
        
        ChangeCodeFileNameTableViewCell *changeCodeFileNameCell=[tableView dequeueReusableCellWithIdentifier:@"ChangeCodeFileNameTableViewCell"];
        ChangeCodeFileNameCellModel *model=changeCodeFileNameModel;
        [changeCodeFileNameCell refreshUI:model];
        return changeCodeFileNameCell;
    }else{
        id modelObjct=self.dataArr[indexPath.row-1];
        if ([modelObjct isKindOfClass:[ChangeCodeFileNameCellModel class]]){
            ChangeCodeFileNameTableViewCell *changeCodeFileNameCell=[tableView dequeueReusableCellWithIdentifier:@"ChangeCodeFileNameTableViewCell"];
            ChangeCodeFileNameCellModel *model=modelObjct;
            [changeCodeFileNameCell refreshUI:model];
            return changeCodeFileNameCell;
        }
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
    
    if (indexPath.row==0) {//修改单个文件
        [self changeSingleFile];
    }else{
        id modelObjct=self.dataArr[indexPath.row-1];
        if ([modelObjct isKindOfClass:[ChangeCodeFileNameCellModel class]]){
            ChangeCodeFileNameCellModel *model=modelObjct;
            //进入另外一个界面
            
            MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
            
            hud.label.text = @"加载中...";
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                SearchChangeFileViewController *vc=(SearchChangeFileViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"SearchChangeFileViewController"];
                vc.filePath=model.subTitle;
                [vc.dataBase addObjectsFromArray:[ZHChangeCodeFileName getChangeNamesFromFilePath:model.subTitle]];
                
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([ZHFileManager fileExistsAtPath:vc.filePath]==NO) {
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
}

/**是否可以编辑*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return NO;
    }
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
        [self.dataArr removeObjectAtIndex:indexPath.row-1];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:@"ChangeCodeFileNameCellModel"];
    }];
    return  @[deleteRowAction];
}
@end
