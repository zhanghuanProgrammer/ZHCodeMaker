#import "SaveTVCLayoutLibriaryViewController.h"
#import "SaveTVCLayoutLibriaryTableViewCell.h"
#import "ZHLayoutLibriaryTableViewCellModel.h"
#import "ZHImage.h"
#import "ZHCreatXibHelp.h"
#import "ZHOutPutLayoutLibriary.h"
#import "ZHSearchCondition.h"

@interface SaveTVCLayoutLibriaryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)NSMutableArray *searchDataArr;
@end

@implementation SaveTVCLayoutLibriaryViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchDataArr removeAllObjects];
    for (NSArray *arr in self.dataArr) {
        if (arr.count>0) {
            ZHLayoutLibriaryTableViewCellModel *model=arr[0];
            if ([[ZHSearchCondition sharedZHSearchCondition] isFitCondition:[NSDictionary dictionaryWithJsonString:model.viewTypeAndCountJosn]]) {
                [self.searchDataArr addObject:@[model]];
            }
        }
    }
    [self.tableView reloadData];
    if (self.searchDataArr.count<=0) {
        if (self.dataArr.count>0) {
            [MBProgressHUD showHUDAddedToView:self.view withText:@"无匹配数据" withDuration:1 animated:YES];
        }
    }
}

- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        NSArray *models=[ZHLayoutLibriaryTableViewCellModel findAll];
        
        for (ZHLayoutLibriaryTableViewCellModel *model in models) {
            if(model.isDelete==0){
                [_dataArr addObject:@[model]];
            }
        }
        if(_dataArr.count>0){
            [_dataArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                ZHLayoutLibriaryTableViewCellModel *model1=obj1[0],*model2=obj2[0];
                return model1.useCount<model2.useCount;
            }];
        }
	}
	return _dataArr;
}

- (NSMutableArray *)searchDataArr{
    if (!_searchDataArr) {
        _searchDataArr=[NSMutableArray array];
    }
    return _searchDataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.tableView.tableFooterView=[UIView new];
	self.edgesForExtendedLayout=UIRectEdgeNone;
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    //tableViewCell 列表快照
    __weak typeof(self)weakSef=self;
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        if (weakSef.dataArr.count>0) {
            [MBProgressHUD showHUDAddedToView:weakSef.view animated:YES];
            [weakSef performSelector:@selector(getImageFromTableView) withObject:nil afterDelay:0.1];
        }else{
            [MBProgressHUD showHUDAddedToView:weakSef.view withText:@"无数据" withDuration:1 animated:YES];
        }
    } WithIdentity:@"tableViewCell-picture-taking"];
}

- (void)getImageFromTableView{
    NSString *saveFilePath=[[ZHFileManager getMacDesktop] stringByAppendingPathComponent:[NSString stringWithFormat:@"tableViewCell-picture-taking.png"]];
    [ZHImage saveImage_PNG:[ZHImage getImageFromTableView:self.tableView] toFile:saveFilePath];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - TableViewDelegate实现的方法:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return self.searchDataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.searchDataArr[indexPath.section][indexPath.row];
	if ([modelObjct isKindOfClass:[ZHLayoutLibriaryTableViewCellModel class]]){
		SaveTVCLayoutLibriaryTableViewCell *saveLayoutLibriaryCell=[tableView dequeueReusableCellWithIdentifier:@"SaveTVCLayoutLibriaryTableViewCell"];
		ZHLayoutLibriaryTableViewCellModel *model=modelObjct;
		[saveLayoutLibriaryCell refreshUI:model];
        UIColor *color=[UIColor redColor];
        switch (indexPath.section%3) {
            case 0:color=[UIColor redColor];break;
            case 1:color=[UIColor greenColor];break;
            case 2:color=[UIColor blueColor];break;
        }
        [saveLayoutLibriaryCell cornerRadiusWithFloat:5 borderColor:color borderWidth:1];
		return saveLayoutLibriaryCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.searchDataArr[indexPath.section][indexPath.row];
	if ([modelObjct isKindOfClass:[ZHLayoutLibriaryTableViewCellModel class]]){
        ZHLayoutLibriaryTableViewCellModel *model=modelObjct;
		return tableView.width*model.imageHeigh/model.imageWidth;
	}
	return 44.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZHLayoutLibriaryTableViewCellModel *model=self.searchDataArr[indexPath.section][indexPath.row];
    SaveTVCLayoutLibriaryTableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    [cell addShakerWithDuration:0.5];
    
    [ZHAlertAction alertWithTitle:nil withMsg:nil addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
        [self GoToPhotoBrowser:0 srcImageView:cell.iconImageView dataArr:@[cell.dataModel.drawViewAddress,cell.dataModel.drawRectAddress]];
    },^{//导出到桌面
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [ZHAlertAction alertWithTitle:nil withMsg:nil addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
                NSString *filesPath=[ZHOutPutLayoutLibriary outPut_PureHand_marsonyCodePath_TableViewCell:model.cellFileAddress withCellName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
                [ZHOutPutLayoutLibriary changeFileNameWithFilesPath:filesPath showAlertToViewController:self];
                model.useCount++;[model update];
            },^{
                NSString *filesPath=[ZHOutPutLayoutLibriary outPut_PureHand_frameCodePath_TableViewCell:model.cellFileAddress withCellName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
                [ZHOutPutLayoutLibriary changeFileNameWithFilesPath:filesPath showAlertToViewController:self];
                model.useCount++;[model update];
            },^{
                NSString *filesPath=[ZHOutPutLayoutLibriary outPut_noPureHandCodePath_TableViewCell:model.cellFileAddress withCellName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
                [ZHOutPutLayoutLibriary changeFileNameWithFilesPath:filesPath showAlertToViewController:self];
                model.useCount++;[model update];
            },^{}] otherButtonTitles:@[@"纯手写模式-marsony",@"纯手写模式-frame",@"非纯手写模式",@"取消"]];
            
        });
    },^{//导出xib
        [ZHCreatXibHelp saveTableViewCellXmlCodePath:model.cellFileAddress withXibName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
        model.useCount++;[model update];
        [MBProgressHUD showHUDAddedToView:self.view withText:@"已生成xib在桌面" withDuration:1 animated:YES];
    },^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZHAlertAction alertWithTitle:@"确定删除" withMsg:nil addToViewController:self withCancleBlock:nil withOkBlock:^{
                cell.dataModel.isDelete=1;
                [cell.dataModel saveOrUpdate];
                [self.dataArr removeObject:cell.dataModel];
                [self.searchDataArr removeObjectAtIndex:indexPath.section];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            } ActionSheet:NO];
        });
    },^{}] otherButtonTitles:@[@"查看大图",@"导出到桌面",@"转成Xib",@"删除",@"取消"]];
}

/**图片查看*/
- (void)GoToPhotoBrowser:(NSInteger)index srcImageView:(UIImageView *)srcImageView dataArr:(NSArray *)dataArr{
    
    ZHPhotosViewController *vc=[ZHPhotosViewController new];
    [vc.imageNames addObjectsFromArray:dataArr];
    [vc addRectWithImageView:srcImageView];
    [vc addRectWithImageView:srcImageView];
    vc.indexCur=index;
    vc.srcImageView=srcImageView;
    [vc show];
}

/**是否可以编辑*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
	if (indexPath.row==self.searchDataArr.count) {
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
        [ZHAlertAction alertWithTitle:@"确定删除" withMsg:nil addToViewController:self withCancleBlock:nil withOkBlock:^{
            ZHLayoutLibriaryTableViewCellModel *dataModel=self.searchDataArr[indexPath.section][indexPath.row];
            dataModel.isDelete=1;
            [dataModel saveOrUpdate];
            [self.dataArr removeObject:dataModel];
            [self.searchDataArr removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        } ActionSheet:NO];
	}];
	return  @[deleteRowAction];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"%zd",section+1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==self.searchDataArr.count-1) {
        return 30.0f;
    }
    return 0.001;
}

@end
