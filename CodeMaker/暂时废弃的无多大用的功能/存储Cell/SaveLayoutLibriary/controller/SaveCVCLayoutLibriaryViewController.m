#import "SaveCVCLayoutLibriaryViewController.h"
#import "SaveCVCLayoutLibriaryCell.h"
#import "ZHLayoutLibriaryCollectionViewCellModel.h"
#import "JGWaterflowLayout.h"
#import "SDImageCache.h"
#import "ZHImage.h"
#import "ZHCreatXibHelp.h"
#import "ZHOutPutLayoutLibriary.h"
#import "ZHSearchCondition.h"

@interface SaveCVCLayoutLibriaryViewController () <UICollectionViewDataSource, JGWaterflowLayoutDelegate,UICollectionViewDelegate>

@property (nonatomic, strong)NSMutableArray *dataArr;
@property (nonatomic,strong)NSMutableArray *searchDataArr;

/** collectionView */
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic,strong)NSArray *itemRects;

@end

@implementation SaveCVCLayoutLibriaryViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.searchDataArr removeAllObjects];
    for (ZHLayoutLibriaryCollectionViewCellModel *model in self.dataArr) {
        if ([[ZHSearchCondition sharedZHSearchCondition] isFitCondition:[NSDictionary dictionaryWithJsonString:model.viewTypeAndCountJosn]]) {
            [self.searchDataArr addObject:model];
        }
    }
    [self.collectionView reloadData];
    if (self.searchDataArr.count<=0) {
        if (self.dataArr.count>0) {
            [MBProgressHUD showHUDAddedToView:self.view withText:@"无匹配数据" withDuration:1 animated:YES];
        }
    }
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
        NSArray *models=[ZHLayoutLibriaryCollectionViewCellModel findAll];
        
        for (ZHLayoutLibriaryCollectionViewCellModel *model in models) {
            if(model.isDelete==0){
                [_dataArr addObject:model];
            }
        }
        if(_dataArr.count>0){
            [_dataArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                ZHLayoutLibriaryCollectionViewCellModel *model1=obj1,*model2=obj2;
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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupLayout];
    
    //CollectionViewCell 列表快照
    __weak typeof(self)weakSef=self;
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        if (weakSef.dataArr.count>0) {
            [MBProgressHUD showHUDAddedToView:weakSef.view animated:YES];
            [weakSef performSelector:@selector(getImageFromCollectionView) withObject:nil afterDelay:0.1];
        }else{
            [MBProgressHUD showHUDAddedToView:weakSef.view withText:@"无数据" withDuration:1 animated:YES];
        }
    } WithIdentity:@"collectionViewCell-picture-taking"];
}

/**截取整个CollectionView的内容形成图片返回*/
- (void)getImageFromCollectionView{
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:self.collectionView.frame];
    scrollView.backgroundColor=[UIColor whiteColor];
    NSInteger index=0;
    CGFloat maxW=0,maxH=0;
    for (UICollectionViewLayoutAttributes *attrs in self.itemRects) {
        if(self.searchDataArr.count>index){
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:attrs.frame];
            ZHLayoutLibriaryCollectionViewCellModel *model=self.searchDataArr[index];
            imageView.image=[UIImage imageNamed:model.drawViewAddress];
            UIColor *color=[UIColor redColor];
            switch (index%3) {
                case 0:color=[UIColor redColor];break;
                case 1:color=[UIColor greenColor];break;
                case 2:color=[UIColor blueColor];break;
            }
            [imageView cornerRadiusWithFloat:5 borderColor:color borderWidth:1];
            [scrollView addSubview:imageView];
        }
        if(attrs.frame.size.width+attrs.frame.origin.x>maxW)maxW=attrs.frame.size.width+attrs.frame.origin.x;
        if(attrs.frame.size.height+attrs.frame.origin.y>maxH)maxH=attrs.frame.size.height+attrs.frame.origin.y;
        index++;
    }
    scrollView.frame=CGRectMake(0, 0, maxW, maxH+10);
    UIImage *image=[ZHImage getImageFromView:scrollView];
    
    NSString *saveFilePath=[[ZHFileManager getMacDesktop] stringByAppendingPathComponent:[NSString stringWithFormat:@"collectionViewCell-picture-taking.png"]];
    [ZHImage saveImage_PNG:image toFile:saveFilePath];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)dealloc{
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
}


- (void)setupLayout {
    
    //创建布局
    JGWaterflowLayout *layout = [[JGWaterflowLayout alloc] init];
    layout.delegate = self;
    
    //创建collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64-44) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate=self;
    [self.view addSubview:collectionView];
    
    //注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SaveCVCLayoutLibriaryCell class]) bundle:nil] forCellWithReuseIdentifier:@"SaveCVCLayoutLibriaryCell"];
    self.collectionView = collectionView;
}

#pragma mark - <UICollectionViewDataSource> -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SaveCVCLayoutLibriaryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SaveCVCLayoutLibriaryCell" forIndexPath:indexPath];
    cell.dataModel = self.searchDataArr[indexPath.row];
    UIColor *color=[UIColor redColor];
    switch (indexPath.row%3) {
        case 0:color=[UIColor redColor];break;
        case 1:color=[UIColor greenColor];break;
        case 2:color=[UIColor blueColor];break;
    }
    [cell cornerRadiusWithFloat:5 borderColor:color borderWidth:1];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    SaveCVCLayoutLibriaryCell *cell=(SaveCVCLayoutLibriaryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ZHLayoutLibriaryCollectionViewCellModel *model=cell.dataModel;
    [cell addShakerWithDuration:0.5];
    
    [ZHAlertAction alertWithTitle:nil withMsg:nil addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
        [self GoToPhotoBrowser:indexPath.row srcImageView:cell.imageView];
    },^{//导出到桌面
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [ZHAlertAction alertWithTitle:nil withMsg:nil addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
                NSString *filesPath=[ZHOutPutLayoutLibriary outPut_PureHand_marsonyCodePath_CollectionViewCell:model.cellFileAddress withCellName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
                [ZHOutPutLayoutLibriary changeFileNameWithFilesPath:filesPath showAlertToViewController:self];
                model.useCount++;[model update];
            },^{
                NSString *filesPath=[ZHOutPutLayoutLibriary outPut_PureHand_frameCodePath_CollectionViewCell:model.cellFileAddress withCellName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
                [ZHOutPutLayoutLibriary changeFileNameWithFilesPath:filesPath showAlertToViewController:self];
                model.useCount++;[model update];
            },^{
                NSString *filesPath=[ZHOutPutLayoutLibriary outPut_noPureHandCodePath_CollectionViewCell:model.cellFileAddress withCellName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
                [ZHOutPutLayoutLibriary changeFileNameWithFilesPath:filesPath showAlertToViewController:self];
                model.useCount++;[model update];
            },^{}] otherButtonTitles:@[@"纯手写模式-marsony",@"纯手写模式-frame",@"非纯手写模式",@"取消"]];
            
        });
        
    },^{//导出xib
        [ZHCreatXibHelp saveCollectionViewCellXmlCodePath:model.cellFileAddress withXibName:model.customClassName fileAddress:model.fileAddress modelAddress:model.modelAddress];
        model.useCount++;[model update];
        [MBProgressHUD showHUDAddedToView:self.view withText:@"已生成xib在桌面" withDuration:1 animated:YES];
    },^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZHAlertAction alertWithTitle:@"确定删除" withMsg:nil addToViewController:self withCancleBlock:nil withOkBlock:^{
                cell.dataModel.isDelete=1;
                [cell.dataModel saveOrUpdate];
                [self.dataArr removeObject:cell.dataModel];
                [self.searchDataArr removeObjectAtIndex:indexPath.row];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } ActionSheet:NO];
        });
    },^{}] otherButtonTitles:@[@"查看大图",@"导出到桌面",@"转成Xib",@"删除",@"取消"]];
}

/**图片查看*/
- (void)GoToPhotoBrowser:(NSInteger)index srcImageView:(UIImageView *)srcImageView{
    
    ZHLayoutLibriaryCollectionViewCellModel *model=self.searchDataArr[index];
    ZHPhotosViewController *vc=[ZHPhotosViewController new];
    [vc.imageNames addObject:model.drawViewAddress];
    [vc.imageNames addObject:model.drawRectAddress];
    [vc addRectWithImageView:srcImageView];
    [vc addRectWithImageView:srcImageView];
    vc.indexCur=0;
    vc.srcImageView=srcImageView;
    [vc show];
}

#pragma mark - <JGWaterflowLayoutDelegate> -
- (CGFloat)waterflowlayout:(JGWaterflowLayout *)waterlayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth {
    
    ZHLayoutLibriaryCollectionViewCellModel *model = self.searchDataArr[index];
    if (index==self.searchDataArr.count-1) {
        self.itemRects=[waterlayout layoutAttributesForElementsInRect:self.collectionView.frame];
    }
    
    return itemWidth * model.imageHeigh / model.imageWidth;
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
