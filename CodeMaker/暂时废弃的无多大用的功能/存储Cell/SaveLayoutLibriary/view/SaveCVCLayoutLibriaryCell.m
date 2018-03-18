#import "SaveCVCLayoutLibriaryCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ZHImageViewValue.h"
#import "UIImageView+PlayGIF.h"

@interface SaveCVCLayoutLibriaryCell ()

@end

@implementation SaveCVCLayoutLibriaryCell

- (void)setDataModel:(ZHLayoutLibriaryCollectionViewCellModel *)dataModel{
    _dataModel=dataModel;
    if ([_dataModel.drawViewAddress hasSuffix:@".gif"]) {
        if (self.imageView.gifPath.length<=0) {
            self.imageView.image=nil;
        }
        self.imageView.gifPath = _dataModel.drawViewAddress;
        [self.imageView startGIF];
    }else{
        if (self.imageView.gifPath.length>0) {
            [self.imageView stopGIF];
            self.imageView.gifPath=nil;
        }
        [[SDImageCache sharedImageCache]removeImageForKey:_dataModel.drawViewAddress fromDisk:YES withCompletion:^{
            [self.imageView imageWithURLString:_dataModel.drawViewAddress];
        }];
    }
}

@end
