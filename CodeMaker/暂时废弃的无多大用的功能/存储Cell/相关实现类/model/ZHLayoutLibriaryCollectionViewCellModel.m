#import "ZHLayoutLibriaryCollectionViewCellModel.h"

@implementation ZHLayoutLibriaryCollectionViewCellModel

- (void)setDrawViewAddress:(NSString *)drawViewAddress{
    _drawViewAddress=drawViewAddress;
    if(_imageHeigh<=0&&_imageWidth<=0){
        UIImage *image=[UIImage imageWithContentsOfFile:drawViewAddress];
        _imageHeigh=CGImageGetHeight(image.CGImage);
        _imageWidth=CGImageGetWidth(image.CGImage);
    }
}

@end
