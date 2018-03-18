#import "WaterPhotoViewController.h"
#import "JGShopCell.h"
#import "JGShop.h"
#import "JGWaterflowLayout.h"
#import "MJRefresh.h"
#import "SDImageCache.h"

@interface WaterPhotoViewController () <UICollectionViewDataSource, JGWaterflowLayoutDelegate,UICollectionViewDelegate>

/** 所有的商品数据  */
@property (nonatomic, strong)NSMutableArray *shops;

/** collectionView */
@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString * const JGShopId = @"shop";

@implementation WaterPhotoViewController

- (NSMutableArray *)shops {
    if (!_shops) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupLayout];

    [self setupRefresh];
    
    self.title=@"瀑布流显示照片收集图";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc{
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupRefresh {
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    [self.collectionView.mj_header beginRefreshing];
}

- (void)loadNewShops {
    
    NSArray *filePaths=[ZHFileManager subPathFileArrInDirector:self.director hasPathExtension:@[@".jpg",@".png",@".gif"]];
    
    [self.shops removeAllObjects];
    for (NSInteger i=0; i<filePaths.count; i++) {
        @autoreleasepool {
            UIImage *image=[UIImage imageWithContentsOfFile:filePaths[i]];
            JGShop *model = [[JGShop alloc] init];
            model.price=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePaths[i]];
            model.w=CGImageGetWidth(image.CGImage);
            model.h=CGImageGetHeight(image.CGImage);
            model.img=filePaths[i];
            [self.shops addObject:model];
        }
    }
    
    //刷新数据
    [self.collectionView reloadData];
    [self.collectionView.mj_header endRefreshing];
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    [self.collectionView removeFromSuperview];
    [self setupLayout];
    [self.collectionView reloadData];
}

- (void)setupLayout {
    
    //创建布局
    JGWaterflowLayout *layout = [[JGWaterflowLayout alloc] init];
    layout.delegate = self;
    
    //创建collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor blackColor];
    collectionView.dataSource = self;
    collectionView.delegate=self;
    [self.view addSubview:collectionView];
    
    //注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JGShopCell class]) bundle:nil] forCellWithReuseIdentifier:JGShopId];
    self.collectionView = collectionView;
}



#pragma mark - <UICollectionViewDataSource> -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.collectionView.mj_footer.hidden = self.shops.count == 0;
    return self.shops.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JGShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JGShopId forIndexPath:indexPath];
    cell.tag=indexPath.row+1;
    cell.shop = self.shops[indexPath.row];
    cell.shop.row=indexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    JGShopCell *cell=(JGShopCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self GoToPhotoBrowser:cell.shop.row srcImageView:cell.imageView];
}
/**图片查看*/
- (void)GoToPhotoBrowser:(NSInteger)index srcImageView:(UIImageView *)srcImageView{
    
    NSMutableArray *arrTemp=[NSMutableArray array];
    
    NSInteger imagesCount=0;
    NSMutableArray *tempShops=[NSMutableArray arrayWithArray:self.shops];
    //排序
    [tempShops sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        JGShop *model1=obj1,*model2=obj2;
        return model1.row>model2.row;
    }];
    
    for (JGShop *model in tempShops) {
        [arrTemp addObject:model.img];
        imagesCount++;
    }
    
    ZHPhotosViewController *vc=[ZHPhotosViewController new];
    
    for (NSString *str in arrTemp) {
        [vc.imageNames addObject:str];
    }
    
    NSMutableArray *cells=[NSMutableArray array];
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:[JGShopCell class]]) {
            [cells addObject:cell];
        }
    }
    
    //排序
    [cells sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        JGShopCell *cell1=obj1,*cell2=obj2;
        return cell1.shop.row>cell2.shop.row;
    }];
    
    for (JGShopCell *cell in cells) {
        [vc addRectWithImageView:((JGShopCell *)cell).imageView];
    }
    
    vc.indexCur=index;
    vc.srcImageView=srcImageView;
    
    [vc show];
}

#pragma mark - <JGWaterflowLayoutDelegate> -
- (CGFloat)waterflowlayout:(JGWaterflowLayout *)waterlayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth {
    
    JGShop *shop = self.shops[index];
    shop.row=index;
    return itemWidth * shop.h / shop.w;
}

- (CGFloat)rowMarginInWaterflowLayout:(JGWaterflowLayout *)waterflowLayout {
    return 20;
}

- (CGFloat)columnCountInWaterflowLayout:(JGWaterflowLayout *)waterflowLayout {
    return 3;
}

- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(JGWaterflowLayout *)waterflowLayout {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
