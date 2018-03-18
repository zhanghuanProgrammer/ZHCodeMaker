#import <Foundation/Foundation.h>

@interface ZHAddLayoutViewRectModel : NSObject

@property (nonatomic,copy)NSString *categoryView;
@property (nonatomic,copy)NSString *x;
@property (nonatomic,copy)NSString *y;
@property (nonatomic,copy)NSString *width;
@property (nonatomic,copy)NSString *height;
@property (nonatomic,assign)CGFloat x_value;
@property (nonatomic,assign)CGFloat y_value;
@property (nonatomic,assign)CGFloat width_value;
@property (nonatomic,assign)CGFloat height_value;

@property (nonatomic,assign)NSInteger layerCount;//处于第几层嵌套
@property (nonatomic,assign)NSInteger SameLayerCountIndex;//处于同一层位置上的上下级顺序

@end
