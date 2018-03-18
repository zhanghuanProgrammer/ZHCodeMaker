#import "QuickCreatCodeTypeViewController.h"

#import "QuickCreatCodeTypeTableViewCell.h"

#import "ZHTableView.h"
#import "ZHCollectionView.h"
#import "tableViewContainColloectionView.h"
#import "ZHCreatXib.h"
#import "ZHRecycleView.h"
#import "LayoutCreatID.h"
#import "ZHTableView_Template.h"

@interface QuickCreatCodeTypeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end


@implementation QuickCreatCodeTypeViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSArray *arr=@[@"简单tableView",@"简单collectionView",@"tableView嵌套tableView或者collectionView",@"简单xib",@"安卓-RecycleView",@"安卓-layout生成id",@"简单tableView_用模板"];
        
        for (NSInteger i=0; i<arr.count; i++) {
            @autoreleasepool {
                QuickCreatCodeTypeCellModel *QuickCreatCodeTypeModel=[QuickCreatCodeTypeCellModel new];
                QuickCreatCodeTypeModel.title=arr[i];
                [_dataArr addObject:QuickCreatCodeTypeModel];
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
    
    //设置NavagationBar (Left和Right) Title
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(leftBarClick)];
    self.title=@"快速生成代码";
}

- (void)leftBarClick{
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
	if ([modelObjct isKindOfClass:[QuickCreatCodeTypeCellModel class]]){
		QuickCreatCodeTypeTableViewCell *QuickCreatCodeTypeCell=[tableView dequeueReusableCellWithIdentifier:@"QuickCreatCodeTypeTableViewCell"];
		QuickCreatCodeTypeCellModel *model=modelObjct;
		[QuickCreatCodeTypeCell refreshUI:model];
		return QuickCreatCodeTypeCell;
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
    
    QuickCreatCodeTypeCellModel *model=self.dataArr[indexPath.row];
    NSString *Msg=@"文件已经生成在桌面,名字为\"代码助手.m\",请填写具体内容";
    
    ZHTableView *zhTableView;
    ZHCollectionView *zhCollectionView;
    tableViewContainColloectionView *tableViewContain;
    ZHCreatXib *zhCreatXib;
    ZHRecycleView *zhRecycleView;
    LayoutCreatID *zhLayoutCreatID;
    ZHTableView_Template *zhTableView_Template;
    
    if (indexPath.row==0) {
        zhTableView=[ZHTableView new];
        [zhTableView creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"ViewController的名字",@"自定义Cell,以逗号隔开",@"是否需要对应的Model 1:0 (不填写么默认为否)",@"是否需要对应的StroyBoard 1:0 (不填写么默认为否)",@"自定义cell可编辑(删除) 1:0 (不填写么默认为否)",@"是否分组 1:0 (不填写么默认为否)"]];
    }else if (indexPath.row==1) {
        zhCollectionView=[ZHCollectionView new];
        [zhCollectionView creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"ViewController的名字",@"自定义Cell,以逗号隔开",@"是否需要对应的Model 1:0 (不填写么默认为否)",@"是否需要对应的StroyBoard 1:0 (不填写么默认为否)"]];
    }else if (indexPath.row==2) {
        tableViewContain=[tableViewContainColloectionView new];
        [tableViewContain creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"ViewController的名字",@"自定义Cell,以逗号隔开",@"自定义Cell标识符:(无:0 TableView:1(子cell以;隔开) ColloectionView:2(子cell以;隔开)),以逗号隔开",@"例如cell有A,B  那么嵌套这一行为:1(A1;A2),2(B1;B2)",@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)",@"是否需要对应的Model 1:0 (不填写么默认为否)",@"是否需要对应的StroyBoard 1:0 (不填写么默认为否)",@"自定义cell可编辑(删除) 1:0 (不填写么默认为否)"]];
    }else if (indexPath.row==3) {//简单xib
        zhCreatXib=[ZHCreatXib new];
        [zhCreatXib creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"xib名字",@"xib类型 1:view-xib 2:tableViewCell-xib 3:collectionViewCell-xib"]];
    }else if (indexPath.row==4) {//@"安卓-RecycleView"
        zhRecycleView=[ZHRecycleView new];
        [zhRecycleView creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"package",@"Activity名字",@"自定义item,以逗号隔开",@"<#Item#>--:--{\n\"ImageView\":\"<#请填写#>\",\n\
                                                         \"TextView\":\"<#请填写#>\",\n\
                                                         \"Button\":\"<#请填写#>\",\n\
                                                         \"EditText\":\"<#请填写#>\"\n\
                                                         }"]];
    }else if (indexPath.row==5) {//@"安卓-layout生成id"
        zhLayoutCreatID=[LayoutCreatID new];
        Msg=@"请把安卓中的layout文件布局代码复制到桌面上名字为\"代码助手.m\"的文件中";
        [CodeAssistantFileManager clearnFileContent];
    }else if (indexPath.row==6) {//简单tableView_用模板
        zhTableView_Template=[ZHTableView_Template new];
        [zhTableView_Template creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"ViewController的名字",@"自定义Cell,以逗号隔开",@"自定义cell可编辑(删除) 1:0 (不填写么默认为否)"]];
    }
    
    
    [ZHAlertAction alertWithTitle:model.title withMsg:Msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        
        if (indexPath.row==0) {
            [zhTableView Begin:@"代码助手" toView:self.view];
        }else if (indexPath.row==1) {
            [zhCollectionView Begin:@"代码助手" toView:self.view];
        }else if (indexPath.row==2) {
            [tableViewContain Begin:@"代码助手" toView:self.view];
        }else if (indexPath.row==3) {//简单xib
            [zhCreatXib Begin:@"代码助手" toView:self.view];
        }else if (indexPath.row==4) {//@"安卓-RecycleView"
            [zhRecycleView Begin:@"代码助手" toView:self.view];
        }else if (indexPath.row==5) {//@"安卓-layout生成id"
            [CodeAssistantFileManager saveContent:[zhLayoutCreatID Begin:[CodeAssistantFileManager getFileContent] toView:self.view]];
        }else if (indexPath.row==6) {
            [zhTableView_Template Begin:@"代码助手" toView:self.view];
        }
        
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写好,生成代码" ActionSheet:NO];
}

@end
