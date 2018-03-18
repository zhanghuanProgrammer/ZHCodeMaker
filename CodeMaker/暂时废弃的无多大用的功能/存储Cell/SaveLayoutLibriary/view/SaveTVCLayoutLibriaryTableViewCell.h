#import <UIKit/UIKit.h>
#import "ZHLayoutLibriaryTableViewCellModel.h"

@interface SaveTVCLayoutLibriaryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (nonatomic,weak)ZHLayoutLibriaryTableViewCellModel *dataModel;

- (void)refreshUI:(ZHLayoutLibriaryTableViewCellModel *)dataModel;

@end
