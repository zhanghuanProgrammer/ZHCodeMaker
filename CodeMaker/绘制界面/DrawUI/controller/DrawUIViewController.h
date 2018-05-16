#import <UIKit/UIKit.h>
@class DrawViewModel;

@interface DrawUIViewController : UIViewController
@property (nonatomic,strong)NSMutableArray *drawViews;
@property (nonatomic,strong)UIView *selectView;
@property (nonatomic,strong)NSMutableArray *selectViews;
- (void)addView:(CGRect)frame type:(NSString *)viewType;
- (void)removeView:(UIView *)view;
- (DrawViewModel *)selectModel;
@end
