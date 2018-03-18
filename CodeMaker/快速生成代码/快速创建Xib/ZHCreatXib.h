#import "CreatFatherFile.h"

@interface ZHCreatXib : CreatFatherFile
- (void)Begin:(NSString *)str toView:(UIView *)view;

- (NSString *)createXibCode_View_h:(NSString *)xibName;
- (NSString *)createXibCode_View_m:(NSString *)xibName;
- (NSString *)createXibCode_TableViewCell_h:(NSString *)xibName;
- (NSString *)createXibCode_TableViewCell_m:(NSString *)xibName;
- (NSString *)createXibCode_CollectionViewCell_h:(NSString *)xibName;
- (NSString *)createXibCode_CollectionViewCell_m:(NSString *)xibName;

@end
