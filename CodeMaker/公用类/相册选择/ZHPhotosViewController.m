
#import "ZHPhotosViewController.h"

#import "UIImageView+ZHImageViewValue.h"
#import "UIImageView+PlayGIF.h"

typedef enum : NSUInteger {
    ZHPhotosTypeUnkown=-1,
    ZHPhotosTypeUrl=1,
    ZHPhotosTypeImage=2,
    ZHPhotosTypeImageName=3,
} ZHPhotosType;

@implementation ZHPhotosViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollImageView=[[UIScrollView alloc]initWithFrame:self.bounds];
        // 缩小:
        _scrollImageView.minimumZoomScale =1.0;
        // 放大:
        _scrollImageView.maximumZoomScale = 2.0;
//        _scrollImageView.clipsToBounds = YES;
//        _scrollImageView.contentSize=self.bounds.size;
        _scrollImageView.decelerationRate = UIScrollViewDecelerationRateFast;
//        _scrollImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _largeImageView = [[UIImageView alloc] initWithFrame:_scrollImageView.bounds];
        
        _largeImageView.contentMode=UIViewContentModeScaleAspectFit;
//        _largeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _largeImageView.backgroundColor=[UIColor blackColor];
        _largeImageView.userInteractionEnabled=YES;
        
        [_scrollImageView addSubview:_largeImageView];
        [self.contentView addSubview:_scrollImageView];
    }
    return self;
}

- (void)adjustFrame{
    if (self.largeImageView.image==nil) {
        return;
    }
    CGFloat w=CGImageGetWidth(self.largeImageView.image.CGImage);
    CGFloat h=CGImageGetHeight(self.largeImageView.image.CGImage);
    
    if (w<0.01) w=1;
    if (h<0.01) h=1;
    
    CGRect rectNew,rect=[UIApplication sharedApplication].keyWindow.bounds;
    
    CGFloat percerX_rect,percerY_rect;
    percerX_rect=w/rect.size.width;
    percerY_rect=h/rect.size.height;
    
    //判断这张图片是宽度占满了屏幕还是高度占满了图片
    
    if(percerX_rect<percerY_rect){//高度占满屏幕
        rectNew=CGRectMake(0, 0, rect.size.width, h/percerX_rect);
        self.scrollImageView.contentOffset=CGPointMake(0, 0);
        self.scrollImageView.contentSize=rectNew.size;
        self.largeImageView.frame=rectNew;
    }else{
        self.scrollImageView.contentOffset=CGPointMake(0, 0);
        self.scrollImageView.contentSize=rect.size;
        self.largeImageView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    }
}

@end


@interface ZHPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UICollectionView *collectionView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic,assign)ZHPhotosType dataType;

@property (nonatomic,strong)UIImageView *srcImageViewNew;
@property (nonatomic,assign)CGRect srcImageViewCGRect;

@property (nonatomic,weak)ZHPhotosViewCollectionViewCell *curCell;
@property (nonatomic,assign)BOOL isZooming;

@property (nonatomic,strong)UILabel *indexCurLabel;
@property (nonatomic,strong)UILabel *shadowOffsetLabel_1;
@property (nonatomic,strong)UILabel *shadowOffsetLabel_2;
@property (nonatomic,strong)UILabel *shadowOffsetLabel_3;

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,assign)NSInteger index;
@property (nonatomic,assign)NSInteger imageCount;

@property (nonatomic,assign)CGRect curRect;
@property (nonatomic,assign)NSInteger curRectIndex;

@property (nonatomic,assign)BOOL isFirstShow;

@property (nonatomic,assign)BOOL statusBarHidden;
@property (nonatomic,assign)UIStatusBarStyle statusBarStyle;

@end

@implementation ZHPhotosViewController

- (NSMutableArray *)urls{
    if (!_urls) {
        _urls=[NSMutableArray array];
    }
    return _urls;
}
- (NSMutableArray *)rects{
    if (!_rects) {
        _rects=[NSMutableArray array];
    }
    return _rects;
}
- (NSMutableArray *)images{
    if (!_images) {
        _images=[NSMutableArray array];
    }
    return _images;
}
- (NSMutableArray *)imageNames{
    if (!_imageNames) {
        _imageNames=[NSMutableArray array];
    }
    return _imageNames;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
        
        NSInteger urlsCount=self.urls.count,imagesCount=self.images.count,imageNamesCount=self.imageNames.count;
        if (urlsCount>=imagesCount&&urlsCount>=imageNamesCount) {
            self.dataType=ZHPhotosTypeUrl;
            self.imageCount=urlsCount;
            [self.dataArr addObjectsFromArray:self.urls];
        }
        if (imagesCount>=urlsCount&&imagesCount>=imageNamesCount) {
            self.dataType=ZHPhotosTypeImage;
            self.imageCount=imageNamesCount;
            [self.dataArr addObjectsFromArray:self.images];
        }
        if (imageNamesCount>=urlsCount&&imageNamesCount>=imagesCount) {
            self.dataType=ZHPhotosTypeImageName;
            self.imageCount=imageNamesCount;
            [self.dataArr addObjectsFromArray:self.imageNames];
        }
    }
    return _dataArr;
}

- (CGRect)srcImageViewCGRect{
    if (CGRectEqualToRect(_srcImageViewCGRect, CGRectZero)) {
        if (self.srcImageView) {
            CGRect rect=[self.srcImageView convertRect:[UIApplication sharedApplication].keyWindow.rootViewController.view.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
            rect.size=self.srcImageView.size;
            _srcImageViewCGRect=rect;
        }
    }
    return _srcImageViewCGRect;
}

- (void)setIndex:(NSInteger)index{
    _index=index;
    self.shadowOffsetLabel_1.text=self.shadowOffsetLabel_2.text=self.shadowOffsetLabel_3.text=self.indexCurLabel.text=[NSString stringWithFormat:@"%zd/%zd",index+1,self.imageCount];
}
- (void)indexLabelHide{
    self.shadowOffsetLabel_1.hidden=self.shadowOffsetLabel_2.hidden=self.shadowOffsetLabel_3.hidden=self.indexCurLabel.hidden=YES;
}

- (ZHPhotosType)dataType{
    if (_dataType!=ZHPhotosTypeUnkown) {
        return _dataType;
    }
    NSInteger urlsCount=self.urls.count,imagesCount=self.images.count,imageNamesCount=self.imageNames.count;
    if (urlsCount>=imagesCount&&urlsCount>=imageNamesCount) {
        _dataType=ZHPhotosTypeUrl;
    }
    if (imagesCount>=urlsCount&&imagesCount>=imageNamesCount) {
        _dataType=ZHPhotosTypeImage;
    }
    if (imageNamesCount>=urlsCount&&imageNamesCount>=imagesCount) {
        _dataType=ZHPhotosTypeImageName;
    }
    return _dataType;
}
- (NSInteger)imageCount{
    if (_imageCount==0) {
        NSInteger urlsCount=self.urls.count,imagesCount=self.images.count,imageNamesCount=self.imageNames.count;
        if (urlsCount>=imagesCount&&urlsCount>=imageNamesCount) {
            self.dataType=ZHPhotosTypeUrl;
            _imageCount=urlsCount;
        }
        if (imagesCount>=urlsCount&&imagesCount>=imageNamesCount) {
            self.dataType=ZHPhotosTypeImage;
            _imageCount=imagesCount;
        }
        if (imageNamesCount>=urlsCount&&imageNamesCount>=imagesCount) {
            self.dataType=ZHPhotosTypeImageName;
            _imageCount=imageNamesCount;
        }
    }
    return _imageCount;
}

- (UILabel *)createLabelWithText:(NSString *)text withFrame:(CGRect)Frame withShadowOffset:(CGSize)shadowOffset{
    UILabel *label=[[UILabel alloc]initWithFrame:Frame];
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.shadowColor=[UIColor grayColor];
    label.shadowOffset=shadowOffset;
    label.text=text;
    return label;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
        
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;//垂直
        
        flow.minimumInteritemSpacing = 0;
        
        flow.minimumLineSpacing = 0;
        
        flow.itemSize=CGSizeMake(self.view.width, self.view.height);
        
        _collectionView=[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flow];
        // 设置代理:
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        
        [_collectionView registerClass:[ZHPhotosViewCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        _collectionView.backgroundColor=[UIColor blackColor];//背景颜色
        
        _collectionView.pagingEnabled=YES;
        
        _collectionView.showsVerticalScrollIndicator=NO;
        _collectionView.showsHorizontalScrollIndicator=NO;
        
        [self.view addSubview:_collectionView];
        
        self.collectionView.alpha=0.0;
        
        CGFloat shadowOffsetValue=0.9;
        
        _indexCurLabel=[self createLabelWithText:@"1/1" withFrame:CGRectMake(30, self.view.height-60, self.view.width-60, 40) withShadowOffset:CGSizeMake(-shadowOffsetValue, 0)];
        
        _shadowOffsetLabel_1=[self createLabelWithText:@"1/1" withFrame:CGRectMake(30, self.view.height-60, self.view.width-60, 40) withShadowOffset:CGSizeMake(shadowOffsetValue, 0)];
        
        _shadowOffsetLabel_2=[self createLabelWithText:@"1/1" withFrame:CGRectMake(30, self.view.height-60, self.view.width-60, 40) withShadowOffset:CGSizeMake(0, -shadowOffsetValue)];
        
        _shadowOffsetLabel_3=[self createLabelWithText:@"1/1" withFrame:CGRectMake(30, self.view.height-60, self.view.width-60, 40) withShadowOffset:CGSizeMake(0, shadowOffsetValue)];
        
        _titleLabel=[self createLabelWithText:@"标题" withFrame:CGRectMake(30, 30, self.view.width-60, 40) withShadowOffset:CGSizeMake(-shadowOffsetValue, 0)];
        _titleLabel.textColor=[UIColor redColor];
        
        [self.view addSubview:_shadowOffsetLabel_1];
        [self.view addSubview:_shadowOffsetLabel_2];
        [self.view addSubview:_shadowOffsetLabel_3];
        [self.view addSubview:_indexCurLabel];
        [self.view addSubview:_titleLabel];
        
    }
    return _collectionView;
}

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    
    UIScrollView *scrollView=(UIScrollView *)tap.view;
    // 如果图像视图放大到两倍，还原初始大小
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1.0f animated:YES];
    } else {
        // 否则，从手势触摸位置开始放大
        CGPoint location = [tap locationInView:scrollView];
        [scrollView zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
    }
}
- (void)singleTap:(UITapGestureRecognizer *)tap{
    [self quitAnimation];
}

- (void)setImageWithIndex:(NSInteger)index toImageView:(UIImageView *)imageView ifFatherIsCell:(ZHPhotosViewCollectionViewCell *)cell{
    switch (self.dataType) {
        case ZHPhotosTypeImageName:
        {
            NSString *imageName=self.dataArr[index];
            if ([imageName hasSuffix:@".gif"]) {
                if (imageView.gifPath.length<=0) {
                    imageView.image=nil;
                }
                if (imageView.isGIFPlaying) {
                    imageView.image=nil;
                    [imageView stopGIF];
                }
                imageView.gifPath = imageName;
                [imageView startGIF];
            }else{
                if (imageView.gifPath.length>0) {
                    imageView.image=nil;
                    [imageView stopGIF];
                    imageView.gifPath=nil;
                }
                
                [[SDImageCache sharedImageCache]removeImageForKey:imageName fromDisk:YES withCompletion:^{
                    [imageView imageWithURLString:self.dataArr[index] withCompleteBlock:^{
                        if (imageView.image==nil) {
                            imageView.image=[UIImage imageNamed:@"jiazhang_msg_photofailure2"];
                        }
                        if (cell) {
                            [cell adjustFrame];
                        }
                    }];
                }];
            }
            
        }
            break;
        case ZHPhotosTypeImage:
        {
            imageView.image=self.dataArr[index];
            if (imageView.image==nil) {
                imageView.image=[UIImage imageNamed:@"jiazhang_msg_photofailure2"];
            }
            [cell adjustFrame];
        }
            break;
        case ZHPhotosTypeUrl:
        {
            [imageView imageWithURLString:self.dataArr[index] withCompleteBlock:^{
                if (imageView.image==nil) {
                    imageView.image=[UIImage imageNamed:@"jiazhang_msg_photofailure2"];
                }
                if (cell) {
                    [cell adjustFrame];
                }
            }];
        }
            break;
        default:break;
    }
}

- (void)addRectWithImageView:(UIImageView *)imageView{
    CGRect rect=[imageView convertRect:[UIApplication sharedApplication].keyWindow.rootViewController.view.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    rect.size=imageView.size;
    
    [self.rects addObject:[NSValue valueWithCGRect:rect]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataType=ZHPhotosTypeUnkown;
    self.view.backgroundColor=[UIColor clearColor];
    
    [self beginAnimation];
}

- (CGRect)getAdapterRect:(UIImage *)image{
    CGFloat w=CGImageGetWidth(image.CGImage);
    CGFloat h=CGImageGetHeight(image.CGImage);
    
    if (w<0.01) w=1;
    if (h<0.01) h=1;
    
    CGRect rectNew=CGRectZero,rect=[UIApplication sharedApplication].keyWindow.bounds;
    
    
    CGFloat percerX_rect,percerY_rect;
    percerX_rect=w/rect.size.width;
    percerY_rect=h/rect.size.height;
    
    //判断这张图片是宽度占满了屏幕还是高度占满了图片
    
    if(percerX_rect<percerY_rect){//高度占满屏幕
        rectNew=CGRectMake(0, 0, rect.size.width, h/percerX_rect);
    }
    
    return rectNew;
}

- (void)beginAnimation{
    _statusBarStyle=[UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    CGRect rect;
    if (self.srcImageView) {
        
        rect=self.srcImageViewCGRect;
        
        UIImageView *srcImageView=[[UIImageView alloc]initWithFrame:rect];
        srcImageView.contentMode=UIViewContentModeScaleAspectFit;
        srcImageView.backgroundColor=[UIColor clearColor];
        srcImageView.image=self.srcImageView.image;
        
        [self.view addSubview:srcImageView];
        
        self.srcImageViewNew=srcImageView;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.backgroundColor=[UIColor blackColor];
            self.srcImageViewNew.backgroundColor=[UIColor blackColor];
            
            CGRect rectNew=[self getAdapterRect:srcImageView.image];
            
            if (CGRectEqualToRect(rectNew, CGRectZero)) {
                self.srcImageViewNew.frame=self.view.bounds;
            }else{
                self.srcImageViewNew.frame=rectNew;
            }
            
        }completion:^(BOOL finished) {
            [self.srcImageViewNew removeFromSuperview];
            self.collectionView.alpha=1.0;
        }];
    }else{
        //从中间或者是不显示最初的图片
        if (self.rects.count>0&&self.rects.count>self.indexCur) {
            rect=[self.rects[self.indexCur] CGRectValue];
            
            self.curRect=rect;
            self.curRectIndex=self.indexCur;
            
            UIImageView *srcImageView=[[UIImageView alloc]initWithFrame:rect];
            srcImageView.contentMode=UIViewContentModeScaleAspectFit;
            srcImageView.backgroundColor=[UIColor whiteColor];
            [self setImageWithIndex:self.indexCur toImageView:srcImageView ifFatherIsCell:nil];
            
            [self.view addSubview:srcImageView];
            
            self.srcImageViewNew=srcImageView;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.view.backgroundColor=[UIColor blackColor];
                self.srcImageViewNew.backgroundColor=[UIColor blackColor];
                
                self.srcImageViewNew.frame=self.view.bounds;
            }completion:^(BOOL finished) {
                [self.srcImageViewNew removeFromSuperview];
                self.collectionView.alpha=1.0;
            }];
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                self.view.backgroundColor=[UIColor blackColor];
            }completion:^(BOOL finished) {
                self.collectionView.alpha=1.0;
            }];
        }
    }
    
}

- (void)quitAnimation{
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:NO];
    
    CGRect rect;
    if (!CGRectEqualToRect(self.curRect, CGRectZero)) {
        
        rect=self.curRect;
        
        CGRect rectNew;
        
        CGFloat w=CGImageGetWidth(self.curCell.largeImageView.image.CGImage);
        CGFloat h=CGImageGetHeight(self.curCell.largeImageView.image.CGImage);
        
        if (w<0.01) w=1;
        if (h<0.01) h=1;
        
        CGFloat percerX_rect,percerY_rect;
        percerX_rect=w/rect.size.width;
        percerY_rect=h/rect.size.height;
        
        //        判断这张图片是宽度占满了屏幕还是高度占满了图片
        
        if(percerX_rect>percerY_rect){//宽度占满屏幕
            rectNew=CGRectMake(rect.origin.x, (rect.size.height-h*rect.size.width/w)/2.0+rect.origin.y, rect.size.width, h*rect.size.width/w);
        }else{//高度占满屏幕
            rectNew=CGRectMake((rect.size.width-w*rect.size.height/h)/2.0+rect.origin.x, rect.origin.y, w*rect.size.height/h, rect.size.height);
        }
        
        CGRect rectScreen;
        
        CGFloat percerX,percerY;
        percerX=w/self.view.width;
        percerY=h/self.view.height;
        
//        判断这张图片是宽度占满了屏幕还是高度占满了图片
        if(percerX>percerY){//宽度占满屏幕
            rectScreen=CGRectMake(0, (self.view.height-h*self.view.width/w)/2.0, self.view.width, h*self.view.width/w);
        }else{//高度占满屏幕
            rectScreen=CGRectMake((self.view.width-w*self.view.height/h)/2.0, 0, w*self.view.height/h, self.view.height);
        }
        
        CGRect rectSub=[self getAdapterRect:self.curCell.largeImageView.image];
        
        if (CGRectEqualToRect(rectSub, CGRectZero)) {
            if (self.curCell.largeImageView==nil) {
                rectScreen=CGRectMake(0, 0, self.view.width, self.view.height);
            }
            self.curCell.largeImageView.frame=rectScreen;
        }else{
            self.curCell.largeImageView.frame=rectSub;
        }
        
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.curCell.largeImageView];
        
        [self indexLabelHide];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha=0.3;
            self.view.backgroundColor=[UIColor whiteColor];
            
            self.curCell.largeImageView.frame=rectNew;
            
        }completion:^(BOOL finished) {
            [self.curCell.largeImageView removeFromSuperview];
            [self quit];
        }];
    }else{
        
        [self indexLabelHide];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha=0.3;
            self.view.backgroundColor=[UIColor whiteColor];
            
        }completion:^(BOOL finished) {
            [self.curCell.largeImageView removeFromSuperview];
            [self quit];
        }];
    }
}

- (void)show{
    UIViewController *rootViewController=[UIApplication sharedApplication].keyWindow.rootViewController;
    
    [rootViewController addChildViewController:self];
    [rootViewController.view addSubview:self.view];
    
    self.collectionView.contentOffset=CGPointMake(self.view.width*self.indexCur, 0);
    self.index=self.indexCur;
    self.titleLabel.text=[ZHFileManager getFileNameNoPathComponentFromFilePath:self.dataArr[self.index]];
    
    //找到对应的cgrect
    [self findCGRect];
}

- (void)findCGRect{
    //首先判断对应的下标位置的CGRect就是现在的Rect
    if (self.srcImageView&&self.rects.count>0) {
        self.curRectIndex=-1;
        NSInteger index=0;
        for (NSValue *value in self.rects) {
            if (CGRectEqualToRect(self.srcImageViewCGRect, [value CGRectValue])) {
                self.curRectIndex=index;
                self.curRect=[value CGRectValue];
                break;
            }
            index++;
        }
        if (self.curRectIndex!=-1) {
            NSLog(@"%@",@"找到了");
        }
    }
    
}

- (void)quit{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - collectionView的代理方法:
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZHPhotosViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [self setImageWithIndex:indexPath.row toImageView:cell.largeImageView ifFatherIsCell:cell];
    if (indexPath.row==self.indexCur&&self.isFirstShow==NO) {
        self.curCell=cell;
        self.isFirstShow=YES;
    }
    cell.scrollImageView.delegate=self;
    
    if (cell.isAddGestureRecognizer==NO) {
        //  添加双击手势监听
        UITapGestureRecognizer *doubleTap =[cell.scrollImageView addUITapGestureRecognizerWithTarget:self withAction:@selector(doubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        
        //  添加单击手势监听
        UITapGestureRecognizer *singleTap =[cell.scrollImageView addUITapGestureRecognizerWithTarget:self withAction:@selector(singleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        cell.isAddGestureRecognizer=YES;
    }
    
    return cell;
}


#pragma mark - UIScrollView的代理方法:
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.isZooming) {
        return;
    }
    
    if ([scrollView isEqual:self.collectionView]) {
        
        NSInteger index=scrollView.contentOffset.x/self.view.width;
        
        ZHPhotosViewCollectionViewCell *cell=(ZHPhotosViewCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        if (self.curCell&&[self.curCell isEqual:cell]==NO) {
            [self.curCell.scrollImageView  setZoomScale:1.0];
            self.curCell=cell;
        }
        
        self.index=scrollView.contentOffset.x/self.view.width;
        self.titleLabel.text=[ZHFileManager getFileNameNoPathComponentFromFilePath:self.dataArr[self.index]];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.collectionView]) {
        CGFloat index=scrollView.contentOffset.x/self.view.width;
        if (self.index<index&&index-self.index>0.5&&index-self.index<1) {
            self.index++;
            [self nextOrUpRect:YES];
        }else if (index<self.index&&self.index-index>=0.5&&self.index-index<=1){
            self.index--;
            [self nextOrUpRect:NO];
        }
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    self.isZooming=YES;
}

//  缩小或者放大回调该方法， 告诉系统需要缩放的图片是哪一张
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.curCell.largeImageView; // 在scrollView上的图片可以缩放;
}

// 已经缩放会自动回调该方法:
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.isZooming=NO;
}

- (void)nextOrUpRect:(BOOL)next{
    if (next) {
        self.curRectIndex++;
        if (self.curRectIndex>=self.rects.count||self.curRectIndex<0) {
            self.curRect=CGRectZero;
            NSLog(@"%@",@"滚动器应该下移");
        }else{
            self.curRect=[self.rects[self.curRectIndex] CGRectValue];
        }
    }else{
        self.curRectIndex--;
        if (self.curRectIndex<0||self.curRectIndex>=self.rects.count) {
            self.curRect=CGRectZero;
            NSLog(@"%@",@"滚动器应该上移");
        }else{
            self.curRect=[self.rects[self.curRectIndex] CGRectValue];
        }
    }
}
@end
