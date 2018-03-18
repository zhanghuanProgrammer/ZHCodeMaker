#import "HelpViewController.h"

#import "HelpTableViewCell.h"


#import "DetailViewController.h"

@interface HelpViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end


@implementation HelpViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSArray *titles=@[@"StroyBoard生成Masonry简介",@"Xib生成Masonry简介",@"快速生成代码简介",@"JSON转模型简介",@"为什么代码里全是View1,label2之类的?",@"生成property outlet怎么用?",@"将非纯手写工程转换成纯手写简介",@"去除代码注释简介",@"查看工程总代码行数简介",@"修改类文件名简介",@"存储Cell简介"];
        
        for (NSInteger i=0; i<titles.count; i++) {
            HelpCellModel *HelpModel=[HelpCellModel new];
            HelpModel.title=titles[i];
            HelpModel.row=i+1;
            [_dataArr addObject:HelpModel];
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
    
    self.title=@"使用简介";
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"视频链接" TintColor:[UIColor blackColor] target:self action:@selector(videoLinkClick)];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoLinkClick{
    
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    
    NSString *text=@"GitHub:https://github.com/zhanghuanProgrammer/ZH\n\
    所有视频总链接:  //https://pan.baidu.com/s/1hsho3p6\n\
    \n\
    1.快速生成代码\n\
    1.1快速生成代码-简单tableView    网址://https://pan.baidu.com/s/1jHOn9jC\n\
    1.2快速生成代码-简单CollectionView    网址://https://pan.baidu.com/s/1hs0lsck\n\
    1.3快速生成代码-tableView嵌套tableView或者CollectionView    网址://https://pan.baidu.com/s/1jHYwSC2\n\
    1.4快速生成代码补充    网址://https://pan.baidu.com/s/1qXX4JtM\n\
    \n\
    2.生成property outlet不用自己拉线    网址://https://pan.baidu.com/s/1c131aNY\n\
    \n\
    3.JSON转模型(Model)    网址://https://pan.baidu.com/s/1kV0fkEF\n\
    \n\
    4.将非纯手写工程转换成纯手写    网址://https://pan.baidu.com/s/1qYhEegG\n\
    \n\
    5.StroyBoard Xib 生成Masonry纯手写代码    网址://https://pan.baidu.com/s/1nvEorep\n\
    6.StroyBoard Xib 生成非纯手写代码    网址://https://pan.baidu.com/s/1nvEorep\n\
    \n\
    7.去除代码注释    网址://https://pan.baidu.com/s/1eR3wV9w\n\
    \n\
    8.修改类文件名    网址://https://pan.baidu.com/s/1skHTDxj\n\
    \n\
    9.查看工程或文件总代码行数    网址://https://pan.baidu.com/s/1miB84Zm\n\
    \n\
    10.存储cell(首页)    网址://https://pan.baidu.com/s/1kUMP9IJ\n\
    \n\
    11.ReadMe    网址://https://pan.baidu.com/s/1bpfwLpP\n\n有什么新的需求或者BUG请邮件1141039693@qq.com\n\n@\"祝大家事业有成,身体健康,生活开开心心,笑口常开\"";
    
    BOOL reslut=[text writeToFile:macDesktopPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if (reslut) {
        [ZHAlertAction alertWithMsg:@"视频链接已经保存到MAC 桌面上 代码助手.m 文件中,请点击查看" addToViewController:self ActionSheet:NO];
    }
    
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
	if ([modelObjct isKindOfClass:[HelpCellModel class]]){
		HelpTableViewCell *HelpCell=[tableView dequeueReusableCellWithIdentifier:@"HelpTableViewCell"];
		HelpCellModel *model=modelObjct;
		[HelpCell refreshUI:model];
		return HelpCell;
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
    HelpCellModel *model=self.dataArr[indexPath.row];
    
    DetailViewController *vc=(DetailViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"DetailViewController"];
    vc.helpString=model.title;
    [TabBarAndNavagation pushViewControllerNoStroyBoard:vc toTarget:self pushHideTabBar:YES backShowTabBar:NO];
}

@end
