#import "StroyBoardCreatePropertyViewController.h"

#import "StroyBoardCreatePropertyTableViewCell.h"

@interface StroyBoardCreatePropertyViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end


@implementation StroyBoardCreatePropertyViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        [_dataArr addObjectsFromArray:[ZHSaveDataToFMDB selectDataWithIdentity:@"StroyBoardCreatePropertyCellModel"]];
	}
	return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.title=@"生成outlet";
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"添加工程" TintColor:[UIColor blackColor] target:self action:@selector(addProjectAction)];
}
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addProjectAction{
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    [ZHFileManager createFileAtPath:macDesktopPath];
    NSString *Msg=@"文件已经生成在桌面,名字为\"代码助手.m\",请填写新的工程路径,会自动识别你的StroyBoard文件";
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
        
        NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:path hasPathExtension:@[@".storyboard",@".xib"]];
        
        if(fileArr.count==0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"工程路径不存在storyboard文件!请重新填写!" addToViewController:self ActionSheet:NO];
            });
            return;
        }
        
        BOOL isRepeat=NO;
        for (NSString *fileName in fileArr) {
            NSString *tempStr=[ZHFileManager getFileNameNoPathComponentFromFilePath:fileName];
            if ([tempStr rangeOfString:@"备份"].location!=NSNotFound||[tempStr isEqualToString:@"LaunchScreen"]) {
                continue;
            }
            
            BOOL needAdd=YES;
            for (StroyBoardCreatePropertyCellModel *model in self.dataArr) {
                if ([model.title isEqualToString:fileName]&&[model.subTitle isEqualToString:path]) {
                    needAdd=NO;
                    isRepeat=YES;
                    break;
                }
            }
            if (needAdd==YES) {
                StroyBoardCreatePropertyCellModel *StroyBoardCreatePropertyModel=[StroyBoardCreatePropertyCellModel new];
                StroyBoardCreatePropertyModel.title=fileName;
                StroyBoardCreatePropertyModel.subTitle=path;
                [self.dataArr addObject:StroyBoardCreatePropertyModel];
            }
        }
        if(isRepeat){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"已经存在,不能重复添加!" addToViewController:self ActionSheet:NO];
            });
        }
       
        [self.tableView reloadData];
        
        if (fileArr.count>0) {
            [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:@"StroyBoardCreatePropertyCellModel"];
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
	if ([modelObjct isKindOfClass:[StroyBoardCreatePropertyCellModel class]]){
		StroyBoardCreatePropertyTableViewCell *StroyBoardCreatePropertyCell=[tableView dequeueReusableCellWithIdentifier:@"StroyBoardCreatePropertyTableViewCell"];
		StroyBoardCreatePropertyCellModel *model=modelObjct;
		[StroyBoardCreatePropertyCell refreshUI:model];
		return StroyBoardCreatePropertyCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 80.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**是否可以编辑*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
	if (indexPath.row==self.dataArr.count) {
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
		[self.dataArr removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:@"StroyBoardCreatePropertyCellModel"];
	}];
	return  @[deleteRowAction];
}

@end
