#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZHDrawModelType) {
    ZHDrawModelTypeRect,
    ZHDrawModelTypeString
};
@interface ZHDrawModel : NSObject
@property (nonatomic,copy)NSString *string;
@property (nonatomic,assign)CGRect fatherRect;
@property (nonatomic,assign)CGRect rect;
@property (nonatomic,copy)NSString *categoryView;
@property (nonatomic,assign)ZHDrawModelType type;
@property (nonatomic,assign)NSInteger layerCount;//处于第几层嵌套
@property (nonatomic,assign)NSInteger SameLayerCountIndex;//处于同一层位置上的上下级顺序

/**tableViewCell时调整为统一的iPhone6屏幕比例*/
- (void)ajustRect;

@end
