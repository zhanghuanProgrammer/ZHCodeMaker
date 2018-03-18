#import "SearchLayoutLibriaryViewController.h"

#import "SearchLayoutLibriaryCollectionViewCell.h"
#import "ZHSearchCondition.h"

@interface SearchLayoutLibriaryViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end
@implementation SearchLayoutLibriaryViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSArray *categroyViews=@[@"label",@"button",@"imageView",@"view",@"textField",@"textView",@"switch",@"progressView",@"tableView",@"collectionView",@"segmentedControl",@"scrollView",@"datePicker",@"stepper",@"pageControl",@"pickerView",@"mapView",@"searchBar",@"webView",@"activityIndicatorView",@"slider"];
        NSArray *icons=@[@"label_icon",@"button_icon",@"imageView_icon",@"view_icon",@"textField_icon",@"textView_icon",@"switch_icon",@"progressView_icon",@"tableView_icon",@"collectionView_icon",@"segmentedControl_icon",@"scrollView_icon",@"datePicker_icon",@"stepper_icon",@"pageControl_icon",@"pickerView_icon",@"mapView_icon",@"searchBar_icon",@"webView_icon",@"activityIndicatorView_icon",@"slider_icon"];
        
        for (NSInteger i=0; i<categroyViews.count; i++) {
            SearchLayoutLibriaryCellModel *searchLayoutLibriaryModel=[SearchLayoutLibriaryCellModel new];
            searchLayoutLibriaryModel.categoryView=categroyViews[i];
            searchLayoutLibriaryModel.icon=icons[i];
            searchLayoutLibriaryModel.isUseForOtherUIViewController=self.isUseForOtherUIViewController;
            searchLayoutLibriaryModel.count=[[ZHSearchCondition sharedZHSearchCondition] countForCategoryView:categroyViews[i]];
            [_dataArr addObject:searchLayoutLibriaryModel];
        }
	}
	return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	[self addFlowLayoutToCollectionView:self.collectionView];
	self.edgesForExtendedLayout=UIRectEdgeNone;
    self.title=@"条件搜索";
    if (!self.isUseForOtherUIViewController) {
        [TabBarAndNavagation setRightBarButtonItemTitle:@"重置" TintColor:[UIColor redColor] target:self action:@selector(clear)];
    }else{
        [TabBarAndNavagation setRightBarButtonItemTitle:@"打开历史记录" TintColor:[UIColor redColor] target:self action:@selector(clear)];
    }
    
    
    __weak typeof(self)weakSelf=self;
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        NSMutableDictionary *tempCondition=[NSMutableDictionary dictionary];
        for (SearchLayoutLibriaryCellModel *model in weakSelf.dataArr) {
            if (model.count>0) {
                [tempCondition setValue:@(model.count) forKey:model.categoryView];
            }
        }
        [[ZHSearchCondition sharedZHSearchCondition]updateCondition:tempCondition];
    } WithIdentity:@"UpdateSearchLayoutLibriary"];
}

- (void)clear{
    if (self.isUseForOtherUIViewController) {
        [self.navigationController popViewControllerAnimated:NO];
        [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawUIViewControllerOpenHistory"];
    }else{
        for (SearchLayoutLibriaryCellModel *model in self.dataArr) {
            model.count=0;
        }
        [[ZHSearchCondition sharedZHSearchCondition]clear];
        [self.collectionView reloadData];
    }
}

/**为collectionView添加布局*/
- (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView{
	UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
	
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直
	
	flow.minimumInteritemSpacing = 10;
	flow.minimumLineSpacing = 10;
	collectionView.collectionViewLayout=flow;
	
	// 设置代理:
	self.collectionView.delegate=self;
	self.collectionView.dataSource=self;
	
	collectionView.backgroundColor=[UIColor whiteColor];//背景颜色
	collectionView.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);//内嵌值
}

#pragma mark - collectionView的代理方法:
// 1.返回组数:
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}
// 2.返回每一组item的个数:
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.dataArr.count;
}
// 3.返回每一个item（cell）对象;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	id modelObjct=self.dataArr[indexPath.row];
	if ([modelObjct isKindOfClass:[SearchLayoutLibriaryCellModel class]]){
		SearchLayoutLibriaryCollectionViewCell *searchLayoutLibriaryCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchLayoutLibriaryCollectionViewCell" forIndexPath:indexPath];
		SearchLayoutLibriaryCellModel *model=modelObjct;
		[searchLayoutLibriaryCell refreshUI:model];
		return searchLayoutLibriaryCell;
	}
	
	//随便给一个cell
	UICollectionViewCell *cell=[UICollectionViewCell new];
	return cell;
}
//4.每一个item的大小:
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(80, 80);
}
// 5.选择某一个cell:
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id modelObjct=self.dataArr[indexPath.row];
    if ([modelObjct isKindOfClass:[SearchLayoutLibriaryCellModel class]]){
        SearchLayoutLibriaryCellModel *model=modelObjct;
        if (self.isUseForOtherUIViewController) {
            [ZHBlockSingleCategroy runBlockNSStringIdentity:@"DrawUIViewControllerViewCategory" Str1:model.categoryView];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
}

@end
