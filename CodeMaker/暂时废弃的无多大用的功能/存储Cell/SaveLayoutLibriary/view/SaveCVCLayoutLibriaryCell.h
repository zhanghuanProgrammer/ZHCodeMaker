#import <UIKit/UIKit.h>
#import "ZHLayoutLibriaryCollectionViewCellModel.h"

@interface SaveCVCLayoutLibriaryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 模型  */
@property (nonatomic, weak)ZHLayoutLibriaryCollectionViewCellModel *dataModel;

@end
