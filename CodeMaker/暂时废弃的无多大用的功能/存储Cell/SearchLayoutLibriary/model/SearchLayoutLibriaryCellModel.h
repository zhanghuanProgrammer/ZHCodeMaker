#import <UIKit/UIKit.h>

@interface SearchLayoutLibriaryCellModel : NSObject
@property (nonatomic,copy)NSString *icon;
@property (nonatomic,copy)NSString *categoryView;
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,assign)BOOL isUseForOtherUIViewController;
@end
