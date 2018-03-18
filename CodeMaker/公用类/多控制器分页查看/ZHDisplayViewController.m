
#import "ZHDisplayViewController.h"

#import "ZHDisplayTitleLabel.h"

#import "ZHDisplayViewControllerConst.h"

@interface ZHDisplayViewController ()<UIScrollViewDelegate>

/** 标题滚动视图 */
@property (nonatomic, weak) UIScrollView *titleScrollView;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *badges;
@property (nonatomic, strong) NSMutableArray *titleWidths;
@property (nonatomic, weak) UIView *underLine;
@property (nonatomic, weak) UIView *coverView;


// 记录上一次内容滚动视图偏移量
@property (nonatomic, assign) CGFloat lastOffsetX;

// 记录是否点击
@property (nonatomic, assign) BOOL isClickTitle;

// 记录是否在动画
@property (nonatomic, assign) BOOL isAniming;

// 标题间距
@property (nonatomic, assign) CGFloat titleMargin;

@end

@implementation ZHDisplayViewController

#pragma mark --- 懒加载
/**懒加载高*/
- (CGFloat)ZHScreenH{
    if (_ZHScreenH==0) {
        _ZHScreenH=[UIApplication sharedApplication].keyWindow.bounds.size.height;
    }
    return _ZHScreenH;
}
/**懒加载宽*/
- (CGFloat)ZHScreenW{
    if (_ZHScreenW==0) {
        _ZHScreenW=[UIApplication sharedApplication].keyWindow.bounds.size.width;
    }
    return _ZHScreenW;
}
/**懒加载数组*/
- (NSMutableArray *)titleWidths{
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}
- (NSMutableArray *)titleLabels{
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}
- (NSMutableArray *)badges{
    if (!_badges) {
        _badges=[NSMutableArray array];
    }
    return _badges;
}
- (NSMutableArray *)badgeCounts{
    if (!_badgeCounts) {
        _badgeCounts=[NSMutableArray array];
    }
    return _badgeCounts;
}
- (void)setTitleScrollViewColor:(UIColor *)titleScrollViewColor{
    _titleScrollViewColor=titleScrollViewColor;
    _titleScrollView.backgroundColor = titleScrollViewColor;
}
/**懒加载字体*/
- (UIFont *)titleFont{
    if (!_titleFont) {
        _titleFont=[UIFont systemFontOfSize:14];
    }
    return _titleFont;
}
/**懒加载未选中文字颜色*/
- (UIColor *)norColor{
    if (_norColor == nil){
        _norColor = [UIColor blackColor];
    }
    
    return _norColor;
}
/**懒加载选中文字颜色*/
- (UIColor *)selColor{
    if (_selColor == nil) _selColor = [UIColor grayColor];
    return _selColor;
}
/**懒加载下划线*/
- (UIView *)underLine{
    if (_underLine == nil) {
        
        UIView *underLineView = [[UIView alloc] init];
        
        underLineView.backgroundColor = _underLineColor?_underLineColor:[UIColor grayColor];
        
        [self.titleScrollView addSubview:underLineView];
        
        _underLine = underLineView;
    }
    return _isShowUnderLine?_underLine : nil;
}





#pragma mark --- 初始化
/**初始化*/
- (instancetype)init{
    if (self = [super init]) {
        //初始化
        [self initial];
    }
    return self;
}
/**初始化*/
- (void)awakeFromNib{
    [super awakeFromNib];
    [self initial];
}
/**初始化*/
- (void)initial{
    //设置高度
     _titleHeight = ZHTitleScrollViewH;
}
/**初始化*/
- (void)setUp{
    if (_isfullScreen) {
        // 全屏展示
        _contentScrollView.frame = CGRectMake(0, 0, self.ZHScreenW, self.ZHScreenH);
    }
}





#pragma mark --- 生命周期
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.titleLabels.count) return;
    
    [self setUpTitleWidth];
    
    [self setUpAllTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加顶部标签滚动视图
    [self setUpTitleScrollView];
    
    // 添加底部内容滚动视图
    [self setUpContentScrollView];
    
    // 初始化
    [self setUp];
    
}





#pragma mark --- 设置并计算
/**设置所有标题*/
- (void)setUpAllTitle{
    // 遍历所有的子控制器
    NSUInteger count = self.childViewControllers.count;
    
    // 添加所有的标题
    CGFloat labelW = 0;
    CGFloat labelH = self.titleHeight;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    for (int i = 0; i < count; i++) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        UILabel *label = [[ZHDisplayTitleLabel alloc] init];
        label.textAlignment=NSTextAlignmentCenter;
        
        label.tag = i;
        
        // 设置按钮的文字颜色
        label.textColor = self.norColor;
        label.font = self.titleFont;
        
        // 设置按钮标题
        label.text = vc.title;
        labelW = [self.titleWidths[i] floatValue];
        
        // 设置按钮位置
        UILabel *lastLabel = [self.titleLabels lastObject];
        if (i==0) labelX = _titleMargin/2.0 + CGRectGetMaxX(lastLabel.frame);
        else labelX = _titleMargin + CGRectGetMaxX(lastLabel.frame);
        
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        //添加徽标
        CGFloat badgeWidth=8;
        UILabel *badge=[[UILabel alloc]initWithFrame:CGRectMake(labelX+labelW, labelY+badgeWidth, badgeWidth, badgeWidth)];
        badge.backgroundColor=[UIColor redColor];
        [badge cornerRadiusWithFloat:badgeWidth/2.0];
        if (self.badgeCounts.count>i) {
            if ([self.badgeCounts[i] integerValue]>0)badge.hidden=NO;
            else badge.hidden=YES;
        }else{
            badge.hidden=YES;
        }
        [self.badges addObject:badge];
        
        // 监听标题的点击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        
        //默认选中第一个
        if (i == 0) [self titleClick:tap];
        
        // 保存到数组
        [self.titleLabels addObject:label];
        
        //加到titleScrollView
        [_titleScrollView addSubview:label];
        //加到titleScrollView
        [_titleScrollView addSubview:badge];
    }
    
    // 设置标题滚动视图的内容范围
    UILabel *lastLabel = self.titleLabels.lastObject;
    
    _titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame)+_titleMargin/2.0, 0);
    _titleScrollView.showsHorizontalScrollIndicator = NO;
    
    _contentScrollView.contentSize = CGSizeMake(count * self.ZHScreenW, 0);
    
}
/**设置所有控制器*/
- (void)setUpVc:(NSInteger)i{
    UIViewController *vc = self.childViewControllers[i];
    if (vc.viewIfLoaded) return;//如果已经加载过了,就不要再加载了
    //设置frame
    vc.view.frame = CGRectMake(i*self.ZHScreenW, 0, self.contentScrollView.width, self.contentScrollView.height);
    //添加到ScrollView中
    [self.contentScrollView addSubview:vc.view];
}
/**设置蒙版*/
- (void)setUpCoverView:(UILabel *)label{
    
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    //至少要覆盖,所以边框再加上5 (4个边框分别加5)
    CGFloat border = 5;
    CGFloat coverH = titleBounds.size.height + 2 * border;
    CGFloat coverW = titleBounds.size.width + 2 * border;
    
    self.coverView.width = coverW;
    
    self.coverView.y = (label.height - coverH) * 0.5;
    self.coverView.height = coverH;
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.x = label.x - border;
    }];
}
/**设置下标的位置*/
- (void)setUpUnderLine:(UILabel *)label{
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGFloat width=titleBounds.size.width;
    
    if (self.needAverageTitleWidth) {
        width=self.averageTitleWidth;
    }
    
    CGFloat underLineH = _underLineH?_underLineH:ZHUnderLineH;
    
    self.underLine.y = label.height - underLineH;
    self.underLine.height = underLineH;
    self.underLine.width = width-2*self.underLineIndexWidth;
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.underLine.x = label.x+self.underLineIndexWidth;
    }];
    
}
/**让选中的按钮居中显示*/
- (void)setLabelTitleCenter:(UILabel *)label{
    
    // 设置标题滚动区域的偏移量
    CGFloat offsetX = label.center.x - self.ZHScreenW * 0.5;
    
    if (offsetX < 0)offsetX = 0;
    
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - self.ZHScreenW;
    
    if (maxOffsetX < 0) maxOffsetX = 0;
    
    if (offsetX > maxOffsetX) offsetX = maxOffsetX;
    
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}
/**计算标题宽度*/
- (void)setUpTitleWidth{
    // 判断是否能占据整个屏幕
    NSUInteger count = self.childViewControllers.count;
    
    NSArray *titles = [self.childViewControllers valueForKeyPath:@"title"];
    
    CGFloat totalWidth = 0;
    
    if (self.needAverageTitleWidth) {
        
        _titleMargin=0;
        
        if (titles.count<self.ZHScreenW) {
            self.averageTitleWidth=self.ZHScreenW/titles.count;
        }
        
        for (NSInteger i=0; i<titles.count; i++) {
            [self.titleWidths addObject:@(self.averageTitleWidth)];
        }
        
        return;
    }
    
    // 计算所有标题的宽度
    for (NSString *title in titles) {
        CGRect titleBounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
        
        CGFloat width = titleBounds.size.width;
        
        [self.titleWidths addObject:@(width)];
        
        totalWidth += width;
    }
    
    if (totalWidth > self.ZHScreenW) {
        
        _titleMargin = margin;
        
        return;
    }
    
    CGFloat titleMargin = (self.ZHScreenW - totalWidth) / (count + 1);
    
    _titleMargin = titleMargin < margin? margin: titleMargin;
}
/**设置标题滚动视图*/
- (void)setUpTitleScrollView{
    UIScrollView *titleScrollView = [[UIScrollView alloc] init];
    
    // 计算尺寸
    CGFloat y = self.navigationController?ZHNavBarH : 0;
    
    CGFloat titleH = _titleHeight?_titleHeight:ZHTitleScrollViewH;
    
    titleScrollView.frame = CGRectMake(0, y, self.ZHScreenW, titleH);
    
    [self.view addSubview:titleScrollView];
    
    titleScrollView.bounces=NO;
    
    _titleScrollView = titleScrollView;
}
/**设置内容滚动视图*/
- (void)setUpContentScrollView{
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    
    // 计算尺寸
    CGFloat y = CGRectGetMaxY(_titleScrollView.frame);
    
    CGFloat navigationBarHeight=0;
    if(self.navigationController.navigationBar!=nil)
        navigationBarHeight=64;
    
    if (self.reduceContentViewHeight>0) {
        if (navigationBarHeight!=64&&self.navigationBarHeight>0) {
            navigationBarHeight=self.navigationBarHeight;
        }
        contentScrollView.frame = CGRectMake(0, y, self.ZHScreenW, self.ZHScreenH-y-navigationBarHeight-self.reduceContentViewHeight);
    }else{
        contentScrollView.frame = CGRectMake(0, y, self.ZHScreenW, self.ZHScreenH-y-navigationBarHeight);
    }
    
    [self.view insertSubview:contentScrollView belowSubview:_titleScrollView];
    
    _contentScrollView = contentScrollView;
    
    _contentScrollView.delegate = self;
    
    // 设置内容滚动视图
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.bounces = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}
/**设置标题滚动视图底部线条颜色*/
- (void)setTitleScrollViewSplitLineColor:(UIColor *)titleScrollViewSplitLineColor{
    _titleScrollViewSplitLineColor=titleScrollViewSplitLineColor;
    
    // 计算尺寸
    CGFloat y = self.navigationController?ZHNavBarH : 0;
    
    CGFloat titleH = _titleHeight?_titleHeight:ZHTitleScrollViewH;
    
    _titleScrollView.frame = CGRectMake(-1, y-1, self.ZHScreenW+1, titleH+1);
    
    //添加标题滚动视图底部线条
    [_titleScrollView cornerRadiusWithBorderColor:self.titleScrollViewSplitLineColor borderWidth:1];
}
/**设置标题颜色渐变*/
- (void)setUpTitleColorGradientWithOffset:(CGFloat)offsetX rightLabel:(ZHDisplayTitleLabel *)rightLabel leftLabel:(ZHDisplayTitleLabel *)leftLabel{
    // 获取右边缩放
    CGFloat rightSacle = offsetX / self.ZHScreenW - leftLabel.tag;
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    if (offsetDelta > 0) { // 往右边
        
        rightLabel.fillColor = self.selColor;
        rightLabel.progress = rightSacle;
        
        leftLabel.fillColor = self.norColor;
        leftLabel.progress = rightSacle;
        
    }else if(offsetDelta < 0){ // 往左边
        
        rightLabel.textColor = self.norColor;
        rightLabel.fillColor = self.selColor;
        rightLabel.progress = rightSacle;
        
        leftLabel.textColor = self.selColor;
        leftLabel.fillColor = self.norColor;
        leftLabel.progress = rightSacle;
    }
}
/**设置下标偏移*/
- (void)setUpUnderLineOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel{
    if (_isClickTitle) return;
    
    if (rightLabel==nil) {
        self.underLine.x=leftLabel.x;
        return;
    }
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.x - leftLabel.x;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat underLineTransformX = offsetDelta * centerDelta / self.ZHScreenW;
    
    // 宽度递增偏移量
    CGFloat underLineWidth = offsetDelta * widthDelta / self.ZHScreenW;
    
    if (self.needAverageTitleWidth) {
        self.underLine.width = self.averageTitleWidth-self.underLineIndexWidth*2;
    }else
        self.underLine.width += underLineWidth;
    self.underLine.x += underLineTransformX;
}
/**设置遮盖偏移*/
- (void)setUpCoverOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel{
    if (_isClickTitle) return;
    
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.x - leftLabel.x;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat coverTransformX = offsetDelta * centerDelta / self.ZHScreenW;
    
    // 宽度递增偏移量
    CGFloat coverWidth = offsetDelta * widthDelta / self.ZHScreenW;
    
    self.coverView.width += coverWidth;
    self.coverView.x += coverTransformX;
}




#pragma mark - UIScrollViewDelegate 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 点击和动画的时候不需要设置
    if (_isAniming) return;
    
    // 获取偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 获取左边角标
    NSInteger leftIndex = offsetX / self.ZHScreenW;
    
    // 左边按钮
    ZHDisplayTitleLabel *leftLabel = self.titleLabels[leftIndex];
    
    // 右边角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 右边按钮
    ZHDisplayTitleLabel *rightLabel = nil;
    
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    
    if (_isClickTitle==NO) {
        // 设置下标偏移
        [self setUpUnderLineOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    }
    
    // 设置遮盖偏移
    [self setUpCoverOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置标题渐变
    [self setUpTitleColorGradientWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 记录上一次的偏移量
    _lastOffsetX = offsetX;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _isAniming = NO;
    // 点击事件处理完成
    _isClickTitle = NO;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 获取角标
    NSInteger i = offsetX / self.ZHScreenW;
    
    // 添加控制器的view
    [self setUpVc:i];
    
    if (i>0) {
        [self setUpVc:i-1];
    }
    if (i<self.childViewControllers.count-1) {
        [self setUpVc:i+1];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    NSInteger offsetXInt = offsetX;
    NSInteger screenWInt = self.ZHScreenW;
    
    NSInteger extre = offsetXInt % screenWInt;
    if (extre > self.ZHScreenW * 0.5) {
        // 往右边移动
        offsetX = offsetX + (self.ZHScreenW - extre);
        _isAniming = YES;
        [self.contentScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }else if (extre < self.ZHScreenW * 0.5 && extre > 0){
        _isAniming = YES;
        // 往左边移动
        offsetX =  offsetX - extre;
        [self.contentScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
    // 获取角标
    NSInteger i = offsetX / self.ZHScreenW;
    
    // 选中标题
    [self selectLabel:self.titleLabels[i]];
    
    [self setUpVc:i];
}










#pragma mark  --- 事件响应函数
/**标题按钮点击*/
- (void)titleClick:(UITapGestureRecognizer *)tap
{
    
    // 记录是否点击标题
    _isClickTitle = YES;
    
    // 获取对应标题label
    UILabel *label = (UILabel *)tap.view;
    
    // 获取当前角标
    NSInteger i = label.tag;
    
    // 选中label
    [self selectLabel:label];
    
    // 内容滚动视图滚动到对应位置
    CGFloat offsetX = i * self.ZHScreenW;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentScrollView.contentOffset=CGPointMake(offsetX, 0);
    }completion:^(BOOL finished) {
        // 点击事件处理完成
        _isClickTitle = NO;
    }];
    
    
    // 记录上一次偏移量,因为点击的时候不会调用scrollView代理记录，因此需要主动记录
    _lastOffsetX = offsetX;
    
    // 添加对应的控制器view在对应位置上
    [self setUpVc:i];
}
- (void)selectLabel:(UILabel *)label
{
    
    for (UILabel *labelView in self.titleLabels) {
        
        labelView.transform = CGAffineTransformIdentity;
        
        labelView.textColor = self.norColor;
    }
    
    // 修改标题选中颜色
    label.textColor = self.selColor;
    
    // 设置标题居中
    [self setLabelTitleCenter:label];
    
    // 设置下标的位置
    [self setUpUnderLine:label];
    
    // 设置cover
    [self setUpCoverView:label];
}




#pragma mark  --- 辅助函数
/**获取两个按钮的宽度差值*/
- (CGFloat)widthDeltaWithRightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel{
    
    //求出右边按钮的CGRect(因为标题不一样,按钮的宽度就应该不一样)
    CGRect titleBoundsR = [rightLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    //求出左边按钮的CGRect
    CGRect titleBoundsL = [leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    //返回按钮的宽度差值
    return titleBoundsR.size.width - titleBoundsL.size.width;
}

/**更新界面*/
- (void)refreshDisplay{
    // 清空之前所有标题
    
    [self.titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    // 清空之前所有内容
    for (UIView *childView in self.contentScrollView.subviews) {
        if (childView.width == self.contentScrollView.width) {
            [childView removeFromSuperview];
        }
    }
    
    // 重新设置标题
    [self setUpTitleWidth];
    
    [self setUpAllTitle];
}

- (void)setBadgeCount:(NSInteger)count forIndex:(NSInteger)index animation:(BOOL)animation{
    
    CGFloat animationTime=0.25;
    if (!animation) {
        animationTime=0.0;
    }
    
    if (self.badges.count>index) {
        UILabel *badge=self.badges[index];
        if (count>0) {
            if (badge.hidden==NO)return;
            badge.alpha=0.0;
            [UIView animateWithDuration:animationTime animations:^{
                badge.alpha=1.0;
            }completion:^(BOOL finished) {
                badge.hidden=NO;
            }];
        }else if (count==0) {
            if (badge.hidden==YES)return;
            badge.alpha=1.0;
            [UIView animateWithDuration:animationTime animations:^{
                badge.alpha=0.0;
            }completion:^(BOOL finished) {
                badge.hidden=YES;
                badge.alpha=1.0;
            }];
        }
    }
}
@end
