
#import "DrawConstraintLine.h"

@implementation DrawConstraintLine

- (instancetype)initWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 color:(UIColor *)color{
    self = [super init];
    if (self) {
        self.point1 = point1;
        self.point2 = point2;
        self.color = color;
        if(!color)self.color = [UIColor greenColor];
    }
    return self;
}

- (instancetype)initWithPoint1:(CGPoint)point1 point2:(CGPoint)point2{
    self = [super init];
    if (self) {
        self.point1 = point1;
        self.point2 = point2;
        self.color = [UIColor greenColor];
    }
    return self;
}

@end

@implementation DrawConstraintLineView

@end
