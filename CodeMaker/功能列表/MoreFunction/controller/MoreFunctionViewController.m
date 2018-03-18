#import "MoreFunctionViewController.h"
#import "MoreFunctionTableViewCell.h"
#import "GetSBViewController.h"
#import "CollectViewController.h"
#import "SaveLayoutLibriaryIndexViewController.h"
#import "DrawUIViewController.h"

#import "ZHRuntime.h"

@interface MoreFunctionViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *dataArr1;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation MoreFunctionViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSArray *titles=@[@"快速生成代码(常用)",@"存储Cell布局库",@"绘制界面",@"生成property outlet,不用自己拉线",@"JSON转模型(Model)",@"为工程添加注释",@"小功能",@"自己的代码习惯",@"将非纯手写工程转换成masonry纯手写工程",@"将非纯手写工程转换成Frame纯手写工程",@"StroyBoard xib生成masonry纯代码",@"StroyBoard xib生成Frame纯手写代码",@"StroyBoard xib生成非纯手写代码",@"ios集合收集",@"andriod集合收集"];
        
        for (NSInteger i=0; i<titles.count; i++) {
            @autoreleasepool {
                MoreFunctionCellModel *MoreFunctionModel=[MoreFunctionCellModel new];
                MoreFunctionModel.title=titles[i];
                [_dataArr addObject:MoreFunctionModel];
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
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.title=@"CodeRobert";
    [TabBarAndNavagation setRightBarButtonItemTitle:@"使用简介" TintColor:[UIColor blackColor] target:self action:@selector(helpAction)];
}

- (void)helpAction{
    [TabBarAndNavagation pushViewController:@"HelpViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
}
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
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
	if ([modelObjct isKindOfClass:[MoreFunctionCellModel class]]){
		MoreFunctionTableViewCell *MoreFunctionCell=[tableView dequeueReusableCellWithIdentifier:@"MoreFunctionTableViewCell"];
		MoreFunctionCellModel *model=modelObjct;
		[MoreFunctionCell refreshUI:model];
		return MoreFunctionCell;
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
    MoreFunctionCellModel *model=self.dataArr[indexPath.row];
    
    if ([model.title isEqualToString:@"快速生成代码(常用)"]) {
        [TabBarAndNavagation pushViewController:@"QuickCreatCodeTypeViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"JSON转模型(Model)"]) {
        [TabBarAndNavagation pushViewController:@"JSONViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"生成property outlet,不用自己拉线"]) {
        [TabBarAndNavagation pushViewController:@"StroyBoardCreatePropertyViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"将非纯手写工程转换成masonry纯手写工程"]) {
        [TabBarAndNavagation pushViewController:@"PureHandProjectViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"将非纯手写工程转换成Frame纯手写工程"]) {
        [TabBarAndNavagation pushViewController:@"ZHFrameProjectViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"小功能"]) {
        [TabBarAndNavagation pushViewController:@"SmallFunctionViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"StroyBoard xib生成masonry纯代码"]) {
        GetSBViewController *vc=(GetSBViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"GetSBViewController"];
        vc.type=GetSBViewControllerTypePureHand;
        [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"StroyBoard xib生成Frame纯手写代码"]) {
        GetSBViewController *vc=(GetSBViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"GetSBViewController"];
        vc.type=GetSBViewControllerTypeFrame;
        [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"StroyBoard xib生成非纯手写代码"]) {
        GetSBViewController *vc=(GetSBViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"GetSBViewController"];
        vc.type=GetSBViewControllerTypeMVC;
        [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"ios集合收集"]) {
        CollectViewController *vc=(CollectViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"CollectViewController"];
        vc.type=@"ios";
        [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"andriod集合收集"]) {
        CollectViewController *vc=(CollectViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"CollectViewController"];
        vc.type=@"andriod";
        [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"插入固定格式代码"]) {
        [TabBarAndNavagation pushViewController:@"InsertFixedViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if([model.title isEqualToString:@"为工程添加注释"]){
        [TabBarAndNavagation pushViewController:@"ZHFuncNameAndAnnotationViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if([model.title isEqualToString:@"自己的代码习惯"]){
        [TabBarAndNavagation pushViewController:@"MyFunctionViewController" toTarget:self pushHideTabBar:NO backShowTabBar:NO];
    }else if([model.title isEqualToString:@"存储Cell布局库"]){
        [TabBarAndNavagation pushViewControllerNoStroyBoard:[SaveLayoutLibriaryIndexViewController new] toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if([model.title isEqualToString:@"绘制界面"]){
        [TabBarAndNavagation pushViewControllerNoStroyBoard:[DrawUIViewController new] toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }
    
}

@end
