#import <UIKit/UIKit.h>
#import "DrawUIViewController.h"
#import "Custombutton.h"

@interface DrawBoard : UIView
@property (nonatomic, assign) BOOL onDraw;
@property (nonatomic,weak)DrawUIViewController *vc;
@property(nonatomic,strong)Custombutton *customBtn;
- (void)CustombuttonTap;
- (void)cancelClick;
@end
