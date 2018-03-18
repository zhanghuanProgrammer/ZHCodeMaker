#import "MyFunctionViewController.h"

#import "MyFunctionTableViewCell.h"

#import "ZHRemoveTheComments.h"

#import "ZHStatisticalCodeRows.h"
#import "ZHSelfHabit.h"
#import "ZHCodeSnippetLibraryBackUp.h"
#import "ZHPerformFuncition.h"

@interface MyFunctionViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *AKeyDealWithBtn;
@property (nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation MyFunctionViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSArray *arr=@[@"添加或修改自己的习惯注释",@"备份Code Snippet Library到文稿"];
        
        for (NSInteger i=0; i<arr.count; i++) {
            @autoreleasepool {
                MyFunctionCellModel *SmallFunctionModel=[MyFunctionCellModel new];
                SmallFunctionModel.title=arr[i];
                [_dataArr addObject:SmallFunctionModel];
            }
        }
	}
	return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
    
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
    self.tableView.tableFooterView=[UIView new];
    [self.AKeyDealWithBtn cornerRadiusWithFloat:5];
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    //设置NavagationBar (Left和Right) Title
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(leftBarClick)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"默认工程" TintColor:[UIColor blackColor] target:self action:@selector(rightBarClick)];
    self.title=@"自己的代码习惯管理";
}
- (void)leftBarClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBarClick{
    [TabBarAndNavagation pushViewController:@"SetDeaultProjectViewController" toTarget:self pushHideTabBar:NO backShowTabBar:NO];
}
- (IBAction)AKeyDealWithAction:(id)sender {
    NSString *result=[[ZHPerformFuncition new] performFuncitionAuto];
    [MBProgressHUD showHUDAddedToView:self.view withText:result withDuration:1 animated:YES];
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
	if ([modelObjct isKindOfClass:[MyFunctionCellModel class]]){
		MyFunctionTableViewCell *smallFunctionCell=[tableView dequeueReusableCellWithIdentifier:@"MyFunctionTableViewCell"];
		MyFunctionCellModel *model=modelObjct;
		[smallFunctionCell refreshUI:model];
		return smallFunctionCell;
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
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    if (indexPath.row==0) {//自己的习惯注释
        [ZHSelfHabit selfHabitAnnotationForVC:self];
    }else if (indexPath.row==1){//备份Code Snippet Library到文稿
        BOOL result=[ZHCodeSnippetLibraryBackUp codeSnippetLibraryBackUp];
        if(result){
            [MBProgressHUD showHUDAddedToView:self.view withText:@"备份成功!" withDuration:1 animated:YES];
        }else{
            [MBProgressHUD showHUDAddedToView:self.view withText:@"备份失败!" withDuration:1 animated:YES];
        }
    }else if (indexPath.row==2){
        
    }else if (indexPath.row==3){
        
    }
}

@end
