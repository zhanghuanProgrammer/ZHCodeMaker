#import "DrawViewOpenHistroyViewController.h"

#import "DrawViewOpenHistroyTableViewCell.h"

@interface DrawViewOpenHistroyViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;

@end


@implementation DrawViewOpenHistroyViewController

- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSMutableArray *dataArrM = [ZHSaveDataToFMDB selectDataWithIdentity:@"DrawViews"];
        for (NSDictionary *dic in dataArrM) {
            DrawViewOpenHistroyCellModel *drawViewOpenHistroyModel=[DrawViewOpenHistroyCellModel new];
            drawViewOpenHistroyModel.title=dic[@"time"];
            drawViewOpenHistroyModel.iconImageName=dic[@"filePath"];
            drawViewOpenHistroyModel.height=[dic[@"height"] floatValue];
            [_dataArr addObject:drawViewOpenHistroyModel];
        }
	}
	return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.tableView.tableFooterView=[UIView new];
    self.edgesForExtendedLayout=UIRectEdgeNone;
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
	if ([modelObjct isKindOfClass:[DrawViewOpenHistroyCellModel class]]){
		DrawViewOpenHistroyTableViewCell *drawViewOpenHistroyCell=[tableView dequeueReusableCellWithIdentifier:@"DrawViewOpenHistroyTableViewCell"];
		DrawViewOpenHistroyCellModel *model=modelObjct;
		[drawViewOpenHistroyCell refreshUI:model];
		return drawViewOpenHistroyCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.dataArr[indexPath.row];
	if ([modelObjct isKindOfClass:[DrawViewOpenHistroyCellModel class]]){
        DrawViewOpenHistroyCellModel *model=modelObjct;
		return model.height;
	}
	return 44.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    DrawViewOpenHistroyCellModel * modelObjct=self.dataArr[indexPath.row];
    NSMutableArray *dataArrM = [ZHSaveDataToFMDB selectDataWithIdentity:@"DrawViews"];
    for (NSDictionary *dic in dataArrM) {
        if ([dic[@"time"] isEqualToString:modelObjct.title]) {
            [ZHBlockSingleCategroy runBlockNSArrayIdentity:@"DrawUIViewControllerOpenModels" Array1:dic[@"models"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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
        DrawViewOpenHistroyCellModel * modelObjct=self.dataArr[indexPath.row];
        
        id targst = nil;
        NSMutableArray *dataArrM = [ZHSaveDataToFMDB selectDataWithIdentity:@"DrawViews"];
        for (NSDictionary *dic in dataArrM) {
            if ([dic[@"time"] isEqualToString:modelObjct.title]) {
                targst = dic;
            }
        }
        if(targst){
            [dataArrM removeObject:targst];
            [ZHSaveDataToFMDB insertDataWithData:dataArrM WithIdentity:@"DrawViews"];
        }
        
		[self.dataArr removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
	}];
	return  @[deleteRowAction];
}

@end
