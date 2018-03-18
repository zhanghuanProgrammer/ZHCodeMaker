#import "ZHAddLayoutViewRectModel.h"

@implementation ZHAddLayoutViewRectModel

- (void)setX:(NSString *)x{
    _x=x;
    _x_value=[x floatValue];
}
- (void)setY:(NSString *)y{
    _y=y;
    _y_value=[y floatValue];
}
- (void)setWidth:(NSString *)width{
    _width=width;
    _width_value=[width floatValue];
}
- (void)setHeight:(NSString *)height{
    _height=height;
    _height_value=[height floatValue];
}

/**防止崩溃*/
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (NSInteger)SameLayerCountIndex{
    if (_SameLayerCountIndex<=0) {
        return 0;
    }
    return _SameLayerCountIndex;
}

@end
