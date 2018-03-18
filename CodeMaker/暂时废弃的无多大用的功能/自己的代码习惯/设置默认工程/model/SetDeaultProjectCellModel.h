#import <UIKit/UIKit.h>

@interface SetDeaultProjectCellModel : NSObject<NSCoding>

@property (nonatomic,assign)BOOL isSelect;//是否选中
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *subTitle;
@end
