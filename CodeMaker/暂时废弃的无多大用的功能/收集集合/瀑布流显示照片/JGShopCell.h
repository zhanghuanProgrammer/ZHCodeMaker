#import <UIKit/UIKit.h>
@class JGShop;

@interface JGShopCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 模型  */
@property (nonatomic, strong)JGShop *shop;

@end
