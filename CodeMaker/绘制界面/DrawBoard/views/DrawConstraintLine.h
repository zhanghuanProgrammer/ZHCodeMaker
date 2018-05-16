
#import <UIKit/UIKit.h>

@interface DrawConstraintLine : NSObject

@property (nonatomic,assign)CGPoint point1;
@property (nonatomic,assign)CGPoint point2;
@property (nonatomic,strong)UIColor *color;

- (instancetype)initWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
- (instancetype)initWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 color:(UIColor *)color;

@end

@interface DrawConstraintLineView : UIView

@property (nonatomic,weak)DrawConstraintLine *model;

@end
