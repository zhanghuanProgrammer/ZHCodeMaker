#import "JKDBModel.h"

@interface ZHLayoutLibriaryTableViewCellModel : JKDBModel

@property (nonatomic,assign)CGFloat imageWidth;
@property (nonatomic,assign)CGFloat imageHeigh;

@property (nonatomic,copy)NSString *customClassName;//对应代码文件的地址
@property (nonatomic,copy)NSString *fileAddress;//对应cell代码文件的地址
@property (nonatomic,copy)NSString *modelAddress;//对应模型代码文件的地址
@property (nonatomic,copy)NSString *cellFileAddress;//自身Xml文件的地址
@property (nonatomic,copy)NSString *drawRectAddress;//对应描绘矩形图片的地址
@property (nonatomic,copy)NSString *drawViewAddress;//对应模拟控件还原的图片的地址
@property (nonatomic,copy)NSString *viewTypeAndCountJosn;//控件类型和对应个数的json
@property (nonatomic,assign)NSInteger useCount;//被使用过的次数
@property (nonatomic,copy)NSString *identityJosn;//控件唯一标识符集合json
@property (nonatomic,assign)NSInteger isDelete;//是否已经被删除

@end
