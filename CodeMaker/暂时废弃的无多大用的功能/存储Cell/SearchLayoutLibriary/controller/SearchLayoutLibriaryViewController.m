#import "SearchLayoutLibriaryViewController.h"

#import "SearchLayoutLibriaryCollectionViewCell.h"
#import "ZHSearchCondition.h"

@interface SearchLayoutLibriaryViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong)UITextField *commandTextField;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,weak)UICollectionViewCell *selectCell;
@end

static int isRepeat = NO;

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
    self.commandTextField=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
    [self.view addSubview:self.commandTextField];
    self.commandTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commandTextField.delegate=self;
    self.commandTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view sendSubviewToBack:self.commandTextField];
    [self.commandTextField becomeFirstResponder];
    
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
    
    [self repeatAction];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isRepeat = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isRepeat = NO;
}

- (void)repeatAction{
    NSString *commandTemp = [[self.commandTextField.text stringByTrim] lowercaseString];
    if(commandTemp.length>0){
        if ([ZHNSString isPureInt:commandTemp]) {
            if (self.selectCell) {
                [self.selectCell cornerRadiusWithFloat:10 borderColor:[[UIColor grayColor] colorWithAlphaComponent:0.6] borderWidth:1];
                self.selectCell = nil;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[commandTemp integerValue]-1 inSection:0]];
            if (cell) {
                [cell cornerRadiusWithFloat:10 borderColor:[UIColor redColor] borderWidth:1];
                self.selectCell = cell;
            }else{
                self.commandTextField.text = @"";
            }
        }else{
            self.commandTextField.text = @"";
        }
    }else{
        if (self.selectCell) {
            [self.selectCell cornerRadiusWithFloat:10 borderColor:[[UIColor grayColor] colorWithAlphaComponent:0.6] borderWidth:1];
            self.selectCell = nil;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isRepeat) {
            [self repeatAction];
        }
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self runScrip];
    return YES;
}

- (void)runScrip{
    if (self.selectCell) {
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[self.collectionView indexPathForCell:self.selectCell]];
    }
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
