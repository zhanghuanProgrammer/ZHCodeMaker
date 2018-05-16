#import "DrawBoard.h"
#import "PathStyle.h"
#import "SearchLayoutLibriaryViewController.h"

@interface DrawBoard ()
@property (nonatomic, strong) UIBezierPath* currentPath;
@property (nonatomic, strong) PathStyle* currentPathStyle;
@property (nonatomic, assign) CGPoint currentPoint;

@property (nonatomic, strong) UIColor* currentColor;
@property (nonatomic, assign) CGFloat currentWidth;

//控制点
@property (nonatomic, assign) CGPoint one;
@property (nonatomic, assign) CGPoint two;

//判断
@property (nonatomic, assign) BOOL onOne;
@property (nonatomic, assign) BOOL onTwo;

@property (nonatomic, strong) UIColor *lastColor;

@end

@implementation DrawBoard

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self loadAvatarInKeyView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self loadAvatarInKeyView];
    }
    return self;
}

- (void)didMoveToSuperview
{
    _currentColor = [UIColor blackColor];
    _currentWidth = 1;
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    //创建path
    UIBezierPath* path = [UIBezierPath bezierPath];
    _currentPath = path;
    
    //创建绘图style
    _currentPathStyle = [PathStyle new];
    _currentPathStyle.color = _currentColor;
    _currentPathStyle.width = _currentWidth;
    
    //获取当前点
    _currentPoint = [touches.anyObject locationInView:self];
    [self drawLineTouchBegin];
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    _currentPoint = [touches.anyObject locationInView:self];
    [self drawLineTouchMove];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    [self drawLineTouchEnd];
}

- (void)drawRect:(CGRect)rect
{
    if (_currentPath&&_currentPathStyle) {
        UIBezierPath* path = _currentPath;
        PathStyle* style = _currentPathStyle;
        //设置style
        [path setLineWidth:style.width];
        [style.color setStroke];
        //美化
        [path setLineCapStyle:kCGLineCapRound];
        [path setLineJoinStyle:kCGLineJoinRound];
        //渲染
        [path stroke];
    }
    [self drawRectanglePath];
}

- (void)loadAvatarInKeyView {
    
    Custombutton *avatar = [[Custombutton alloc] initInKeyWindowWithFrame:CGRectMake(0, 333.5, 60, 60)];
    self.customBtn=avatar;
    
    [avatar setTag:100];
    
    [avatar setBackgroundImage:@"loadAvatar"];
    
    [avatar setTapBlock:^(Custombutton *avatar) {
        [self CustombuttonTap];
    }];
    
    [avatar setLongPressBlock:^(Custombutton *button) {
        [self cancelClick];
    }];
    [avatar setDoubleTapBlock:^(Custombutton *button) {
        [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawUIViewControllerOpenHistory"];
    }];
}

- (void)CustombuttonTap{
    if (self.vc&&_onDraw==1){
        __weak typeof(self)weakSelf=self;
        
        CGFloat minX,minY,maxX,maxY;
        minX=_one.x<_two.x?_one.x:_two.x;
        maxX=_one.x>_two.x?_one.x:_two.x;
        minY=_one.y<_two.y?_one.y:_two.y;
        maxY=_one.y>_two.y?_one.y:_two.y;
        CGRect rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
        
        [ZHBlockSingleCategroy addBlockWithNSString:^(NSString *str1) {
            [weakSelf.vc addView:rect type:str1];
            [weakSelf cancelClick];
        } WithIdentity:@"DrawUIViewControllerViewCategory"];
        SearchLayoutLibriaryViewController *vc=(SearchLayoutLibriaryViewController *)[TabBarAndNavagation getViewControllerFromStoryBoardWithIdentity:@"SearchLayoutLibriaryViewController"];
        vc.isUseForOtherUIViewController=YES;
        [self.vc.navigationController pushViewController:vc animated:NO];
    }
}

#pragma mark-------------------按钮点击--------------
- (void)cleanClick:(UIButton*)btn
{
    [self setNeedsDisplay];
}

- (void)cirtainClick
{
    UIBezierPath* path = [UIBezierPath bezierPath];
    path = [self drawRectangle];
    
    _onDraw = 0;
    _one = CGPointZero;
    _two = CGPointZero;
    
    [self setNeedsDisplay];
}

- (void)cancelClick
{
    _onDraw = 0;
    _one = CGPointZero;
    _two = CGPointZero;
    
    [self setNeedsDisplay];
}

#pragma mark-------------------画线----------------
//画线-----开始触摸
- (void)drawLineTouchBegin
{
    if (CGPointEqualToPoint(_one, CGPointZero)) {
        _one = _currentPoint;
        _two = _one;
    }
    if (_onDraw) {
        _onOne = [self selectPoint:_currentPoint OnPoint:_one];
        _onTwo = [self selectPoint:_currentPoint OnPoint:_two];
    }
}
//画线-----移动
- (void)drawLineTouchMove
{
    if (!_onDraw) {
        _two = _currentPoint;
    }
    else {
        _one = _onOne ? _currentPoint : _one;
        _two = _onTwo ? _currentPoint : _two;
    }
}
//画线-----结束触摸
- (void)drawLineTouchEnd
{
    if (!CGPointEqualToPoint(_two, _one)) {
        _onDraw = 1;
    }
}

#pragma mark-------------------画矩形--------------
- (UIBezierPath*)drawRectangle
{
    CGRect rect = CGRectMake(_one.x, _one.y, _two.x - _one.x, _two.y - _one.y);
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    return path;
}
- (void)drawRectanglePath
{
    UIBezierPath* cir1 = [UIBezierPath bezierPathWithArcCenter:_one
                                                        radius:5
                                                    startAngle:0
                                                      endAngle:2 * M_PI
                                                     clockwise:1];
    [cir1 fill];
    UIBezierPath* cir2 = [UIBezierPath bezierPathWithArcCenter:_two
                                                        radius:5
                                                    startAngle:0
                                                      endAngle:2 * M_PI
                                                     clockwise:1];
    [cir2 fill];

    [[self drawRectangle] stroke];
}

//选择拖动点
- (BOOL)selectPoint:(CGPoint)Point OnPoint:(CGPoint)center
{
    CGRect rect = CGRectMake(center.x - 5, center.y - 5, 10, 10);
    return CGRectContainsPoint(rect, Point);
}

@end
