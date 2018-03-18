#import "ZHDrawModel.h"

@implementation ZHDrawModel

- (void)ajustRect{
    CGFloat fatherRectWidth=self.fatherRect.size.width;
    CGFloat selfRectWidth=self.rect.size.width;
    if (fatherRectWidth>0&&selfRectWidth>0) {
        CGFloat percer=375/fatherRectWidth;
        if (percer!=1) {
            self.rect=CGRectMake(self.rect.origin.x*percer, self.rect.origin.y*percer, self.rect.size.width*percer, self.rect.size.height*percer);
        }
    }
}
- (NSInteger)SameLayerCountIndex{
    if (_SameLayerCountIndex<=0) {
        return 0;
    }
    return _SameLayerCountIndex;
}

@end
