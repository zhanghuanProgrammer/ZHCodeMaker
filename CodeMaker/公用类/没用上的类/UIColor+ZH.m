#import "UIColor+ZH.h"

@implementation UIColor (ZH)

- (CGFloat)red {
    CGFloat r = 0, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return r;
}

- (CGFloat)green {
    CGFloat r, g = 0, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return g;
}

- (CGFloat)blue {
    CGFloat r, g, b = 0, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return b;
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (CGFloat)hue {
    CGFloat h = 0, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return h;
}

- (CGFloat)saturation {
    CGFloat h, s = 0, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return s;
}

- (CGFloat)brightness {
    CGFloat h, s, b = 0, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return b;
}

/**反色*/
- (UIColor *)colorInvert{
    CGFloat r = 0, g=0, b=0, a=0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    r*=255;g*=255;b*=255;
    if (fabs(r-(255-r))>50) r=255-r; else r=(int)(255-r+50)%255;
    if (fabs(g-(255-g))>50) g=255-g; else g=(int)(255-g+50)%255;
    if (fabs(b-(255-b))>50) b=255-b; else b=(int)(255-b+50)%255;
    r=fabs(r);g=fabs(g);b=fabs(b);
    return RGB(r, g, b);
}

@end
