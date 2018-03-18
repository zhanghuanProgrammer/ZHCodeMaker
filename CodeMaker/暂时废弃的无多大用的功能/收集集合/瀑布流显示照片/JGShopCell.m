#import "JGShopCell.h"
#import "JGShop.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ZHImageViewValue.h"
#import "UIImageView+PlayGIF.h"


@interface JGShopCell ()

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation JGShopCell

- (void)setShop:(JGShop *)shop {
    _shop = shop;
    // 1.图片
    
    if ([shop.img hasSuffix:@".gif"]) {
        if (self.imageView.gifPath.length<=0) {
            self.imageView.image=nil;
        }
        self.imageView.gifPath = shop.img;
        [self.imageView startGIF];
    }else{
        if (self.imageView.gifPath.length>0) {
            [self.imageView stopGIF];
            self.imageView.gifPath=nil;
        }
        [[SDImageCache sharedImageCache]removeImageForKey:shop.img fromDisk:YES withCompletion:^{
            [self.imageView imageWithURLString:shop.img];
        }];
    }
    
    // 2.价格
    self.priceLabel.text = shop.price;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.priceLabel.adjustsFontSizeToFitWidth=YES;
}

@end
