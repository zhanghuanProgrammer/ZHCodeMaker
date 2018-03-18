
#import "SaveLayoutLibriaryIndexViewController.h"
#import "SaveTVCLayoutLibriaryViewController.h"
#import "SaveCVCLayoutLibriaryViewController.h"
#import "GBPopMenuButtonView.h"
#import "ZHLayoutLibriaryCollectionViewCellModel.h"
#import "ZHLayoutLibriaryTableViewCellModel.h"
#import "ZHAddLayoutLibriaryHelp.h"

@interface SaveLayoutLibriaryIndexViewController ()<GBMenuButtonDelegate>
@property (strong, nonatomic) UILabel *addLabel;
@property (nonatomic,strong)GBPopMenuButtonView *popMenuButtonView;
@end

@implementation SaveLayoutLibriaryIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加所有子控制器
    [self setUpAllViewController];
    
    self.titleScrollViewSplitLineColor=RGB(0, 78, 162);
    self.titleScrollViewColor=[UIColor whiteColor];
    
    self.isShowUnderLine=YES;
    
    self.norColor=RGB(153, 153, 153);
    self.selColor=RGB(0, 78, 162);
    
    self.needAverageTitleWidth=YES;
    self.averageTitleWidth=60;
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.title=@"存储Cell布局库";
    [TabBarAndNavagation setRightBarButtonItemTitle:@"搜索" TintColor:[UIColor redColor] target:self action:@selector(gotoSearchVC)];
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    
    GBPopMenuButtonView *popMenuButtonView = [[GBPopMenuButtonView alloc] initWithItems:@[@"add",@"picture-taking"] size:CGSizeMake(50, 50) type:GBMenuButtonTypeLineLeft isMove:NO];
    self.popMenuButtonView=popMenuButtonView;
    self.popMenuButtonView.delegate=self;
    popMenuButtonView.frame = CGRectMake(self.view.width-90, self.view.height-64-90, 50, 50);
    [self.view addSubview:popMenuButtonView];
    
    [self loadBackUpData];
}

- (void)loadBackUpData{
    BOOL haveData=[ZHLayoutLibriaryTableViewCellModel haveData];
    if (!haveData) {
        haveData=[ZHLayoutLibriaryCollectionViewCellModel haveData];
    }
    if (!haveData) {
        NSString *dataBasePath=[ZHLayoutLibriaryTableViewCellModel dbPath:nil];
        NSString *backUpPath=[[ZHAddLayoutLibriaryHelp new].backUpDataBasePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:dataBasePath]];
        if ([ZHFileManager fileExistsAtPath:backUpPath]) {
            [ZHLayoutLibriaryTableViewCellModel close];
            if ([ZHFileManager fileExistsAtPath:dataBasePath]) {
                [ZHFileManager removeItemAtPath:dataBasePath];
                [ZHFileManager copyItemAtPath:backUpPath toPath:dataBasePath];
            }
        }
    }
}

- (void)menuButtonSelectedAtIdex:(NSInteger)index{
    if (index==0) {//添加
        [TabBarAndNavagation pushViewController:@"ZHAddLayoutLibriaryViewController" toTarget:self pushHideTabBar:NO backShowTabBar:NO];
    }
    if (index==1){//快照
        //判断是将tableViewCell 列表快照 还是 CollectionViewCell 列表快照
        if (self.contentScrollView.contentOffset.x==0) {//tableViewCell 列表快照
            [ZHBlockSingleCategroy runBlockNULLIdentity:@"tableViewCell-picture-taking"];
        }else{//CollectionViewCell 列表快照
            [ZHBlockSingleCategroy runBlockNULLIdentity:@"collectionViewCell-picture-taking"];
        }
    }
    [self.popMenuButtonView hideItems];
}

- (void)backAction{
    [self backUpDataBase];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backUpDataBase{
    //保存数据库
    BOOL haveData=[ZHLayoutLibriaryTableViewCellModel haveData];
    if (!haveData) {
        haveData=[ZHLayoutLibriaryCollectionViewCellModel haveData];
    }
    if (haveData) {
        NSString *dataBasePath=[ZHLayoutLibriaryCollectionViewCellModel dbPath:nil];
        NSString *toPath=[[ZHAddLayoutLibriaryHelp new].backUpDataBasePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:dataBasePath]];
        
        if ([ZHFileManager fileExistsAtPath:toPath]) {
            [ZHFileManager removeItemAtPath:toPath];
        }
        [ZHFileManager copyItemAtPath:dataBasePath toPath:toPath];
    }

}

- (void)gotoSearchVC{
    [TabBarAndNavagation pushViewController:@"SearchLayoutLibriaryViewController" toTarget:self pushHideTabBar:NO backShowTabBar:NO];
}

- (void)setUpAllViewController{
    SaveTVCLayoutLibriaryViewController *vc1 = (SaveTVCLayoutLibriaryViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"SaveTVCLayoutLibriaryViewController"];
    vc1.title=@"TableViewCell";
    [self addChildViewController:vc1];
    
    SaveCVCLayoutLibriaryViewController *vc2 = [SaveCVCLayoutLibriaryViewController new];
    vc2.title=@"CollectionViewCell";
    [self addChildViewController:vc2];
}

@end
