#import <UIKit/UIKit.h>

@interface UIColor (ZH)

@property (nonatomic, readonly) CGFloat red;

@property (nonatomic, readonly) CGFloat green;

@property (nonatomic, readonly) CGFloat blue;

@property (nonatomic, readonly) CGFloat alpha;

@property (nonatomic, readonly) CGFloat hue;//色调

@property (nonatomic, readonly) CGFloat saturation;//饱和

@property (nonatomic, readonly) CGFloat brightness;//亮度

/**反色*/
- (UIColor *)colorInvert;
@end
