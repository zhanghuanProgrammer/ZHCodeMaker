#import <UIKit/UIKit.h>

@interface DrawUIViewController : UIViewController
@property (nonatomic,strong)NSMutableArray *drawViews;
@property (nonatomic,strong)UIView *selectView;
- (void)addView:(CGRect)frame type:(NSString *)viewType;
- (void)removeView:(UIView *)view;
@end
