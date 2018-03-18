#import <UIKit/UIKit.h>

@interface SearchChangeFileCellModel : NSObject
@property (nonatomic,copy)NSString *iconImageName;
@property (nonatomic,assign)BOOL isSelect;
@property (nonatomic,assign)BOOL shouldShowImage;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *searchText;
@property (nonatomic,copy)NSString *path;

@property (nonatomic,copy)NSString *content;
@property (nonatomic,assign)CGSize size;
@property (nonatomic,assign)CGFloat width;
@property (nonatomic,strong)NSMutableArray *dataArr;
@end
