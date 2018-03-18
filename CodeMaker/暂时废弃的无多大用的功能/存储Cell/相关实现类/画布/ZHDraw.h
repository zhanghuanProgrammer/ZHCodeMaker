#import <UIKit/UIKit.h>
#import "ZHDrawModel.h"

typedef NS_ENUM(NSUInteger, ZHDrawType) {
    ZHDrawTypeView=0,
    ZHDrawTypeDraw
};
@interface ZHDraw : UIView

@property (nonatomic,assign)ZHDrawType type;

- (void)clearData;

- (void)addZHDrawModel:(ZHDrawModel *)model;

/**脱屏渲染*/
- (void)takeOffScreenRendering;

/**获取模拟的界面*/
- (void)creatSubViews;
@end
