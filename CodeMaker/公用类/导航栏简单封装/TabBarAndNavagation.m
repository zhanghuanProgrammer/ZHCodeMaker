
#import "TabBarAndNavagation.h"

@implementation ZHTabBarAndNavagation

- (void)initWithItem:(id)item color:(UIColor *)color action:(SEL)action{
    self.item=item;
    self.color=color;
    self.action=action;
}

@end

@implementation TabBarAndNavagation
+ (void)setOriginalImageFortabBarItem:(NSInteger)index toTarget:(UIViewController *)aTarget{
    UITabBar *tabBar = aTarget.tabBarController.tabBar;
    UITabBarItem *tabBarItem = [tabBar.items objectAtIndex:index];
    UIImage *image=tabBarItem.selectedImage;
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [tabBarItem setSelectedImage:image];
}

+ (void)setBackImageName:(NSString *)imageName ForNavagationBar:(UIViewController *)aTarget{
    [aTarget.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:imageName] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

+ (void)setBackImage:(UIImage *)image ForNavagationBar:(UIViewController *)aTarget{
    [aTarget.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

+ (void)setShadowImage:(UIImage *)image ForNavagationBar:(UIViewController *)aTarget{
    [aTarget.navigationController.navigationBar setShadowImage:image];
}

+ (void)setTitleColor:(UIColor *)color forNavagationBar:(UIViewController *)aTarget{
    [aTarget.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,nil]];
}

+ (UIBarButtonItem *)setLeftBarButtonItemTitle:(NSString *)title TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithTitle:title style:(UIBarButtonItemStylePlain) target:target action:action];
    leftButton.tintColor=color;
    target.navigationItem.leftBarButtonItem=leftButton;
    return leftButton;
}

+ (UIBarButtonItem *)setRightBarButtonItemTitle:(NSString *)title TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithTitle:title style:(UIBarButtonItemStylePlain) target:target action:action];
    rightButton.tintColor=color;
    target.navigationItem.rightBarButtonItem=rightButton;
    return rightButton;
}
+ (UIBarButtonItem *)setLeftBarButtonItemSystemItem:(UIBarButtonSystemItem)SystemItem TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:SystemItem target:target action:action];
    leftButton.tintColor=color;
    target.navigationItem.leftBarButtonItem=leftButton;
    return leftButton;
}
+ (UIBarButtonItem *)setRightBarButtonItemSystemItem:(UIBarButtonSystemItem)SystemItem TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:SystemItem target:target action:action];
    rightButton.tintColor=color;
    target.navigationItem.rightBarButtonItem=rightButton;
    return rightButton;
}
/**设置NavagationBar (Left或Right) Button*/
+ (UIBarButtonItem *)setLeftBarButtonItemImageName:(NSString *)imageName TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:imageName] style:(UIBarButtonItemStylePlain) target:target action:action];
    leftButton.tintColor=color;
    target.navigationItem.leftBarButtonItem=leftButton;
    return leftButton;
}
+ (UIBarButtonItem *)setLeftBarButtonItemImage:(UIImage *)image TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithImage:image style:(UIBarButtonItemStylePlain) target:target action:action];
    leftButton.tintColor=color;
    target.navigationItem.leftBarButtonItem=leftButton;
    return leftButton;
}
/**设置NavagationBar (Left或Right) Button*/
+ (UIBarButtonItem *)setRightBarButtonItemImage:(NSString *)imageName TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:imageName] style:(UIBarButtonItemStylePlain) target:target action:action];
    rightButton.tintColor=color;
    target.navigationItem.rightBarButtonItem=rightButton;
    return rightButton;
}
/**设置NavagationBar (Left或Right) Button*/
+ (UIBarButtonItem *)setLeftBarButtonItemCustom:(UIView *)customVIew TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithCustomView:customVIew];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [customVIew addGestureRecognizer:tap];
    customVIew.userInteractionEnabled=YES;
    leftButton.tintColor=color;
    target.navigationItem.leftBarButtonItem=leftButton;
    return leftButton;
}
/**设置NavagationBar (Left或Right) Button*/
+ (UIBarButtonItem *)setRightBarButtonItemCustom:(UIView *)customVIew TintColor:(UIColor *)color target:(UIViewController *)target action:(SEL)action{
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:customVIew];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [customVIew addGestureRecognizer:tap];
    customVIew.userInteractionEnabled=YES;
    rightButton.tintColor=color;
    target.navigationItem.rightBarButtonItem=rightButton;
    return rightButton;
}
/**设置NavagationBar Title 和 TabBar Title 的不同名字*/
+ (void)setNavagationBarTitle:(NSString *)navagationBarTitle tabBarTitle:(NSString *)tabBartitle target:(UIViewController *)target{
    target.title=navagationBarTitle;
    target.navigationController.title=tabBartitle;
}

/**从StoryBoard中根据标识符获取UIViewController*/
+ (UIViewController *)getViewControllerFromStoryBoardWithIdentity:(NSString *)Identity{
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:Identity];
    return vc;
}

+ (UIViewController *)getViewControllerFromStoryBoardWithIdentity:(NSString *)Identity withStoryBoardName:(NSString *)SBName{
    UIStoryboard *sb=[UIStoryboard storyboardWithName:SBName bundle:nil];
    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:Identity];
    return vc;
}

+ (void)pushViewController:(NSString *)viewController toTarget:(id)target  pushHideTabBar:(BOOL)pushHide backShowTabBar:(BOOL)backShow{
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:viewController];
    
    if ([target isKindOfClass:[UIViewController class]]) {
        if (pushHide) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=YES;
        }
        [((UIViewController *)target).navigationController pushViewController:vc animated:YES];
        if (backShow) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=NO;
        }
        
    }else if ([target isKindOfClass:[UITableViewCell class]]){
        if (pushHide) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=YES;
        }
        [[((UITableViewCell *)target) getViewController].navigationController pushViewController:vc animated:YES];
        if (backShow) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=NO;
        }
    }
}
+ (void)pushViewController:(NSString *)viewController toTarget:(id)target operation:(void (^)(UIViewController *vc))operation pushHideTabBar:(BOOL)pushHide backShowTabBar:(BOOL)backShow{
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:viewController];
    if (operation) {
        operation(vc);
    }
    if ([target isKindOfClass:[UIViewController class]]) {
        if (pushHide) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=YES;
        }
        
        [((UIViewController *)target).navigationController pushViewController:vc animated:YES];
        if (backShow) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=NO;
        }
        
    }else if ([target isKindOfClass:[UITableViewCell class]]){
        if (pushHide) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=YES;
        }
        [[((UITableViewCell *)target) getViewController].navigationController pushViewController:vc animated:YES];
        if (backShow) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=NO;
        }
    }
}
+ (void)pushViewControllerNoStroyBoard:(UIViewController *)viewController toTarget:(id)target pushHideTabBar:(BOOL)pushHide backShowTabBar:(BOOL)backShow{
    if ([target isKindOfClass:[UIViewController class]]) {
        if (pushHide) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=YES;
        }
        [((UIViewController *)target).navigationController pushViewController:viewController animated:YES];
        if (backShow) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=NO;
        }
        
    }else if ([target isKindOfClass:[UITableViewCell class]]){
        if (pushHide) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=YES;
        }
        [[((UITableViewCell *)target) getViewController].navigationController pushViewController:viewController animated:YES];
        if (backShow) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=NO;
        }
    }
}

+ (void)pushViewController:(NSString *)viewController toTarget:(id)target  pushHideTabBar:(BOOL)pushHide backShowTabBar:(BOOL)backShow withStoryBoardName:(NSString *)SBName{
    UIStoryboard *sb=[UIStoryboard storyboardWithName:SBName bundle:nil];
    if (sb==nil) {
        NSLog(@"%@StoryBoard不存在",SBName);
        return;
    }
    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:viewController];
    
    if ([target isKindOfClass:[UIViewController class]]) {
        if (pushHide) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=YES;
        }
        [((UIViewController *)target).navigationController pushViewController:vc animated:YES];
        if (backShow) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=NO;
        }
        
    }else if ([target isKindOfClass:[UITableViewCell class]]){
        if (pushHide) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=YES;
        }
        [[((UITableViewCell *)target) getViewController].navigationController pushViewController:vc animated:YES];
        if (backShow) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=NO;
        }
    }
}
+ (void)pushViewController:(NSString *)viewController toTarget:(id)target operation:(void (^)(UIViewController *vc))operation pushHideTabBar:(BOOL)pushHide backShowTabBar:(BOOL)backShow withStoryBoardName:(NSString *)SBName{
    UIStoryboard *sb=[UIStoryboard storyboardWithName:SBName bundle:nil];
    if (sb==nil) {
        NSLog(@"%@StoryBoard不存在",SBName);
        return;
    }
    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:viewController];
    if (operation) {
        operation(vc);
    }
    if ([target isKindOfClass:[UIViewController class]]) {
        if (pushHide) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=YES;
        }
        
        [((UIViewController *)target).navigationController pushViewController:vc animated:YES];
        if (backShow) {
            ((UIViewController *)target).hidesBottomBarWhenPushed=NO;
        }
        
    }else if ([target isKindOfClass:[UITableViewCell class]]){
        if (pushHide) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=YES;
        }
        [[((UITableViewCell *)target) getViewController].navigationController pushViewController:vc animated:YES];
        if (backShow) {
            [((UITableViewCell *)target) getViewController].hidesBottomBarWhenPushed=NO;
        }
    }
}

+ (void)setLeftItem:(ZHBarItem)leftBarItem rightItem:(ZHBarItem)rightBarItem target:(UIViewController *)target{
    ZHTabBarAndNavagation *leftItem=[ZHTabBarAndNavagation new];
    leftBarItem(leftItem);
    if (leftItem!=nil) {
        if ([leftItem.item isKindOfClass:[NSString class]]) {
            [self setLeftBarButtonItemTitle:leftItem.item TintColor:leftItem.color target:target action:leftItem.action];
        }else if ([leftItem.item isKindOfClass:[UIImage class]]){
            [self setLeftBarButtonItemImage:leftItem.item TintColor:leftItem.color target:target action:leftItem.action];
        }else if ([leftItem.item isKindOfClass:[UIView class]]){
            [self setLeftBarButtonItemCustom:leftItem.item TintColor:leftItem.color target:target action:leftItem.action];
        }else if ([leftItem.item isKindOfClass:[NSNumber class]]){
            [self setLeftBarButtonItemSystemItem:[leftItem.item integerValue] TintColor:leftItem.color target:target action:leftItem.action];
        }
    }
    
    ZHTabBarAndNavagation *rightItem=[ZHTabBarAndNavagation new];
    rightBarItem(rightItem);
    if (rightItem!=nil) {
        if ([rightItem.item isKindOfClass:[NSString class]]) {
            [self setRightBarButtonItemTitle:rightItem.item TintColor:rightItem.color target:target action:rightItem.action];
        }else if ([rightItem.item isKindOfClass:[UIImage class]]){
            [self setRightBarButtonItemImage:rightItem.item TintColor:rightItem.color target:target action:rightItem.action];
        }else if ([rightItem.item isKindOfClass:[UIView class]]){
            [self setRightBarButtonItemCustom:rightItem.item TintColor:rightItem.color target:target action:rightItem.action];
        }else if ([rightItem.item isKindOfClass:[NSNumber class]]){
            [self setRightBarButtonItemSystemItem:[rightItem.item integerValue] TintColor:rightItem.color target:target action:rightItem.action];
        }
    }
}

+ (void)popViewController:(NSString *)viewController toTarget:(UIViewController *)target{
    UIViewController *controllerTarget = nil;
    for (UIViewController * controller in target.navigationController.viewControllers) { //遍历
        if ([controller isKindOfClass:NSClassFromString(viewController)]) { //这里判断是否为你想要跳转的页面
            controllerTarget = controller;
        }
    }
    if (controllerTarget) {
        [target.navigationController popToViewController:controllerTarget animated:YES]; //跳转
    }
}

+ (UIView *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}
@end