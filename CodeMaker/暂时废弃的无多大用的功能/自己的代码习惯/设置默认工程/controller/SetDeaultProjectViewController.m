#import "SetDeaultProjectViewController.h"
#import "SetDeaultProjectTableViewCell.h"

@interface SetDeaultProjectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArr;
@end

@implementation SetDeaultProjectViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        [_dataArr addObjectsFromArray:[ZHSaveDataToFMDB selectDataWithIdentity:@"SetDeaultProjectCellModel"]];
        NSString *FastCodeCurProject=[ZHSaveDataToFMDB selectDataWithIdentity:@"FastCodeCurProject"];
        for (SetDeaultProjectCellModel *model in _dataArr) {
            if ([model.subTitle isEqualToString:FastCodeCurProject]) {
                model.isSelect=YES;
            }else{
                model.isSelect=NO;
            }
        }
	}
	return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
    self.tableView.tableFooterView=[UIView new];
    self.title=@"设置默认工程路径";
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"添加(文件夹/工程)" TintColor:[UIColor blackColor] target:self action:@selector(addProjectAction)];
    
    __weak typeof(self)weakSelf=self;
    [ZHBlockSingleCategroy addBlockWithNSString:^(NSString *str1) {
        [ZHSaveDataToFMDB insertDataWithData:str1 WithIdentity:@"FastCodeCurProject"];
        for (SetDeaultProjectCellModel *model in weakSelf.dataArr) {
            if ([model.subTitle isEqualToString:str1]) {
                model.isSelect=YES;
            }else{
                model.isSelect=NO;
            }
        }
        [weakSelf.tableView reloadData];
    } WithIdentity:@"SetDeaultProjectViewControllerSwitch"];
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
                [ZHAlertAction alertWithMsg:@"你填的路径为单个文件,请添加工程路径!" addToViewController:self ActionSheet:NO];
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
        for (SetDeaultProjectCellModel *model in self.dataArr) {
            if ([model.title isEqualToString:fileName]&&[model.subTitle isEqualToString:path]) {
                needAdd=NO;
                break;
            }
        }
        
        if(needAdd){
            SetDeaultProjectCellModel *deaultProjectCellModel=[SetDeaultProjectCellModel new];
            deaultProjectCellModel.title=fileName;
            deaultProjectCellModel.subTitle=path;
            [self.dataArr addObject:deaultProjectCellModel];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZHAlertAction alertWithMsg:@"已经存在,不能重复添加!" addToViewController:self ActionSheet:NO];
            });
        }
        
        [self.tableView reloadData];
        
        if (self.dataArr.count>0) {
            [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:@"SetDeaultProjectCellModel"];
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
	if ([modelObjct isKindOfClass:[SetDeaultProjectCellModel class]]){
		SetDeaultProjectTableViewCell *showPublicSwitchCell=[tableView dequeueReusableCellWithIdentifier:@"SetDeaultProjectTableViewCell"];
		SetDeaultProjectCellModel *model=modelObjct;
		[showPublicSwitchCell refreshUI:model];
		return showPublicSwitchCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return 44.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        SetDeaultProjectCellModel *model=self.dataArr[indexPath.row];
        NSString *FastCodeCurProject=[ZHSaveDataToFMDB selectDataWithIdentity:@"FastCodeCurProject"];
        if ([FastCodeCurProject isEqualToString:model.subTitle]) {
            [ZHSaveDataToFMDB insertDataWithData:nil WithIdentity:@"FastCodeCurProject"];
        }
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        [ZHSaveDataToFMDB insertDataWithData:self.dataArr WithIdentity:@"SetDeaultProjectCellModel"];
    }];
    return  @[deleteRowAction];
}
@end
