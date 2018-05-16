
#import "SCLazyView.h"
#import <objc/runtime.h>
#import "Masonry.h"
#import "SCLayoutControl.h"
#import "DrawBoard.h"
#import "DrawViewConstarint.h"
#import "DrawViewLineTool.h"

#define SCScreenWidth [UIScreen mainScreen].bounds.size.width
#define SCScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCValueRect(rect) [NSValue valueWithCGRect:rect]
#define SCValuePoint(point) [NSValue valueWithCGPoint:point]

@interface SCLazyView ()<UIGestureRecognizerDelegate>

@end

@implementation SCLazyView {
    
    CGPoint originPositionInView;
    CGFloat originX;
    CGFloat originY;
    CGFloat originWidth;
    CGFloat originHeight;
    CGPoint originCenter;
    NSArray *activeXs;
    NSArray *activeYs;
}

- (void)setShouldSetVaule:(BOOL)shouldSetVaule{
    _shouldSetVaule = shouldSetVaule;
    if (shouldSetVaule) {
        for (UIView *controller in self.controllers){
            controller.hidden = YES;
        }
    }else{
        for (UIView *controller in self.controllers){
            controller.hidden = NO;
        }
        for (UIView *view in self.viewController.selectViews){
            if (view != self.viewController.selectView){
                [self.viewController.selectView cornerRadiusWithFloat:0 borderColor:[UIColor clearColor] borderWidth:0];
            }
        }
        [self.viewController.selectViews removeAllObjects];
    }
}

- (void)actived{
    self.isActived = YES;//被激活
    [self activeSubviews:YES];//激活所有Subviews
    [self setNeedsDisplay];//刷新视图
    [self.constarintOperation removeAllObjects];
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
}

- (void)unActived{
    [self tapSubView:nil];
    self.isActived = NO;//设置不被激活状态
    [self activeSubviews:NO];//取消激活所有Subviews
    [self setNeedsDisplay];
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
}

static const NSString *interactionEnableKey = @"interactionEnable";
static const NSString *panKey = @"pan";
static const NSString *tapKey = @"tap";

- (void)activeSubviews:(BOOL)isActive {
    
    if (!isActive) [self removeControllers];
    
    for (UIView *subview in self.subviews) {
        //画布不能进行移动和控制四个点进行缩放调节
        if ([subview isKindOfClass:[DrawBoard class]] || subview.tag == 999) {
            continue;
        }
        if (isActive) {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSubview:)];
            pan.delegate = self;
            [subview addGestureRecognizer:pan];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSubView:)];
            [subview addGestureRecognizer:tap];
            //记住之前的isUserInteractionEnabled
            objc_setAssociatedObject(subview, &interactionEnableKey, @(subview.isUserInteractionEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(subview, &panKey, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(subview, &tapKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            subview.userInteractionEnabled = YES;
            [self addController:subview];
        }else {
            UIPanGestureRecognizer *pan = objc_getAssociatedObject(subview, &panKey);
            UITapGestureRecognizer *tap = objc_getAssociatedObject(subview, &tapKey);
            //还原之前的isUserInteractionEnabled
            BOOL isUserInteractionEnable = [objc_getAssociatedObject(subview, &interactionEnableKey) boolValue];
            subview.userInteractionEnabled = isUserInteractionEnable;
            [subview removeGestureRecognizer:pan];
            [subview removeGestureRecognizer:tap];
        }
    }
}

- (void)panSubview:(UIPanGestureRecognizer*)ges{
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        originCenter = ges.view.center;
        originPositionInView = [ges locationInView:self];
    }else if (ges.state == UIGestureRecognizerStateEnded) {
        
    }else if (ges.state == UIGestureRecognizerStateChanged) {
        CGPoint positionInView = [ges locationInView:self];
        ges.view.center = CGPointMake(originCenter.x + positionInView.x - originPositionInView.x,
                                      originCenter.y + positionInView.y - originPositionInView.y);
        [self setNeedsDisplay];
    }
}

- (void)tapSubView:(UITapGestureRecognizer *)tap{
    [self tapSelectSubView:tap.view];
}

- (void)tapSelectSubView:(UIView *)view{
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"ShouldInputCommand"];
    [self removeConstraintLines];
    
    if (self.viewController.selectView) {
        if (view == self.viewController.selectView || !self.shouldSetVaule){
            [self.viewController.selectView cornerRadiusWithFloat:0 borderColor:[UIColor clearColor] borderWidth:0];
        }else if (self.shouldSetVaule) {
            [self.viewController.selectView cornerRadiusWithFloat:0.1 borderColor:[[UIColor redColor] colorWithAlphaComponent:0.3] borderWidth:1];
        }
    }
    if (view == self.viewController.selectView) {
        if (self.shouldSetVaule) [self.viewController.selectViews removeObject:self.viewController.selectView];
        self.viewController.selectView = nil;
        [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
        return;
    }
    if (self.shouldSetVaule && self.viewController.selectView) {
        if (![self.viewController.selectViews containsObject:self.viewController.selectView]) {
            [self.viewController.selectViews addObject:self.viewController.selectView];
        }
    }
    self.viewController.selectView = view;
    if (self.shouldSetVaule && self.viewController.selectView) {
        if (![self.viewController.selectViews containsObject:self.viewController.selectView]) {
            [self.viewController.selectViews addObject:self.viewController.selectView];
        }
    }
    [self addConstraintLines];
    [self.viewController.selectView cornerRadiusWithFloat:0.1 borderColor:[UIColor redColor] borderWidth:1];
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
}



#pragma mark - Controller五个控制点
static const NSString *subviewKey = @"subview";
static const NSString *indexKey = @"index";

/**添加控制点*/
- (void)addController:(UIView*)subview{
    /*
     0  5  1
     |-----|
    6|  4  |7
     |-----|
     3  8  2
     */
    NSArray *points = @[
                        @[subview.mas_left,subview.mas_top],
                        @[subview.mas_right,subview.mas_top],
                        @[subview.mas_right,subview.mas_bottom],
                        @[subview.mas_left,subview.mas_bottom],
                        @[subview.mas_centerX,subview.mas_centerY],
                        @[subview.mas_centerX,subview.mas_top],
                        @[subview.mas_left,subview.mas_centerY],
                        @[subview.mas_right,subview.mas_centerY],
                        @[subview.mas_centerX,subview.mas_bottom],
                        ];
    
    for (int i=0; i<points.count; i++){
        
        NSArray *point = points[i];
        
        //创建控制点
        SCLayoutControl *controller = [SCLayoutControl new];
        controller.relateView=subview;
        [self addSubview:controller];
        
        //设置控制点的约束
        controller.mas_key = [NSString stringWithFormat:@"controller%d",i];
        [controller mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(point[0]);
            make.centerY.equalTo(point[1]);
            make.width.height.offset(10);
        }];
        
        if(i==4){
            //为每个控制点添加点击事件
            [controller addTarget:self action:@selector(deleteView:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i<4) {
            //为每个控制点添加移动事件(除了中间的控制点)
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panController:)];
            pan.delaysTouchesBegan = NO;
            [controller addGestureRecognizer:pan];
        }
        if (i>4) {
            [controller addTarget:self action:@selector(selectConstraint:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //为控制点添加对应的控制对象
        objc_setAssociatedObject(controller, &subviewKey, subview, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(controller, &indexKey, @(i), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        controller.hidden = self.shouldSetVaule;
        [self.controllers addObject:controller];
    }
}

/**移除所有控制点*/
- (void)removeControllers{
    for (UIView *controller in self.controllers){
        [controller removeFromSuperview];
    }
    [self.controllers removeAllObjects];
}
- (void)reSelectControll:(DrawViewConstarint *)model{
    for (SCLayoutControl *controller in self.controllers) controller.selected = NO;
    for (SCLayoutControl *controller in self.controllers) {
        if ([[NSString stringWithFormat:@"%p",controller.relateView] isEqualToString:model.firstItem]) {
            if ([controller.mas_key isEqualToString: [NSString stringWithFormat:@"controller%@",[model firstControllIndex]]]) {
                [self selectConstraint:controller];
            }
        }
    }
    for (SCLayoutControl *controller in self.controllers) {
        if ([[NSString stringWithFormat:@"%p",controller.relateView] isEqualToString:model.secondItem]) {
            if ([controller.mas_key isEqualToString: [NSString stringWithFormat:@"controller%@",[model secondControllIndex]]]) {
                [self selectConstraint:controller];
            }
        }
    }
}
- (void)runCommandSuccess{
    for (SCLayoutControl *controller in self.controllers) {
        controller.selected = NO;
    }
}

- (void)selectConstraint:(SCLayoutControl*)sender{
    sender.selected = !sender.isSelected;
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"ShouldInputCommand"];
    
    NSString *relateView = [NSString stringWithFormat:@"%p",sender.relateView];
    NSInteger controllerIndex = [[sender.mas_key stringByReplacingOccurrencesOfString:@"controller" withString:@""] integerValue];
    NSString *constarintName = nil;
    switch (controllerIndex) {
        case 5:constarintName = @"top";break;
        case 6:constarintName = @"left";break;
        case 7:constarintName = @"right";break;
        case 8:constarintName = @"bottom";break;
    }
    if (!constarintName) return;
    
    if (sender.selected) {
        if (!self.constarintOperation[relateView]) {
            if (self.constarintOperation.count==0 || (self.constarintOperation.count<2&&[[self.constarintOperation allValues][0] count]<2)) {
                [self.constarintOperation setValue:[NSMutableArray arrayWithObject:constarintName] forKey:relateView];
                self.lastSelectControll = relateView;//没办法,设置下顺序吧,不然不知道谁相对谁
            }else{
                sender.selected = NO;
            }
        }else{
            NSMutableArray *arrM = self.constarintOperation[relateView];
            if (self.constarintOperation.count<2) {
                [arrM addObject:constarintName];
            }else{
                sender.selected = NO;
            }
        }
    }else{
        if (self.constarintOperation[relateView]) {
            NSMutableArray *arrM = self.constarintOperation[relateView];
            [arrM removeObject:constarintName];
            if (arrM.count == 0) {
                self.constarintOperation[relateView] = nil;
            }
        }
    }
}

- (void)deleteView:(SCLayoutControl*)sender{
    if (!sender.isSelected){//如果没有选中,就选中
        sender.selected = !sender.isSelected;
    }else{
        UIView *relateView=sender.relateView;
        //删除这个控件(被操控的控件)
        for (UIView *controller in self.subviews){
            if ([controller isKindOfClass:[SCLayoutControl class]]) {
                if ([[(SCLayoutControl *)controller relateView] isEqual:relateView]) {
                    [controller removeFromSuperview];
                    [self.controllers removeObject:controller];
                }
            }
        }
        
        UIViewController *vc=self.viewController;
        if([vc isKindOfClass:[DrawUIViewController class]]){
            [(DrawUIViewController *)vc removeView:relateView];
        }
    }
}

/**按住控制点移动时的不同情况处理*/
- (void)panController:(UIPanGestureRecognizer*)ges {
    
    //如果是中间的控制点 controller4
    if ([ges.view.mas_key isEqualToString:@"controller4"])return;
    
    UIView *subview = objc_getAssociatedObject(ges.view, &subviewKey);
    if (ges.state == UIGestureRecognizerStateBegan) {
        
        //记住初始位置
        originCenter = ges.view.center;
        originPositionInView = [ges locationInView:self];
        originX = subview.x;
        originY = subview.y;
        originWidth = subview.width;
        originHeight = subview.height;
    }
    
    CGPoint positionInView = [ges locationInView:self];
    CGFloat xOffset = positionInView.x - originPositionInView.x;
    CGFloat yOffset = positionInView.y - originPositionInView.y;
    
    NSInteger index = [objc_getAssociatedObject(ges.view, &indexKey) integerValue];
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    switch (index) {
        case 0: {
            
            x = originX + xOffset;
            y = originY + yOffset;
            width = originWidth - xOffset;
            height = originHeight - yOffset;
            break;
        }
        case 1: {
            
            x = originX;
            y = originY + yOffset;
            width = originWidth + xOffset;
            height = originHeight - yOffset;
            break;
        }
        case 2: {
            
            x = originX;
            y = originY;
            width = originWidth + xOffset;
            height = originHeight + yOffset;
            break;
        }
        case 3: {
            
            x = originX + xOffset;
            y = originY;
            width = originWidth - xOffset;
            height = originHeight + yOffset;
            break;
        }
        case 4: {
            
            x = originX + xOffset;
            y = originY + yOffset;
            width = originWidth;
            height = originHeight;
            break;
        }
        default:
            break;
    }
    
    subview.frame = CGRectMake(x,y,width,height);
    [self setNeedsLayout];
}

- (void)addConstraintLines{
    if (self.viewController.selectView) {
        NSArray *models = [[DrawViewLineTool new] getDrawConstraintLine:self.viewController.selectModel models:self.viewController.drawViews];
        for (DrawConstraintLine *model in models) {
            [self addConstraintLine:model];
        }
    }
}
- (void)addConstraintLine:(DrawConstraintLine *)model{
    DrawConstraintLineView *view = [DrawConstraintLineView new];
    view.frame = CGRectMake(MIN(model.point1.x, model.point2.x), MIN(model.point1.y, model.point2.y),
                            ABS(model.point2.x - model.point1.x), ABS(model.point2.y - model.point1.y));
    if (view.width<=0) view.width = 1; if (view.height<=0) view.height = 1;
    [view cornerRadiusWithFloat:0.5];
    view.backgroundColor = model.color;
    view.userInteractionEnabled = NO;
    [self addSubview:view];
    [self.constraintLines addObject:view];
}
- (void)removeConstraintLines{
    for (UIView *view in self.constraintLines) [view removeFromSuperview];
    [self.constraintLines removeAllObjects];
}

#pragma mark - set get 懒加载

- (NSMutableArray*)controllers {
    return _controllers ?: (_controllers = [[NSMutableArray alloc] init]);
}

- (NSMutableArray*)constraintLines {
    return _constraintLines ?: (_constraintLines = [[NSMutableArray alloc] init]);
}

@end
