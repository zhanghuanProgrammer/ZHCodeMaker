#import "UIScreen+ZH.h"
#import "UIDevice+ZH.h"

@implementation UIScreen (ZH)

+ (CGFloat)screenScale {
    static CGFloat screenScale = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([NSThread isMainThread]) {
            screenScale = [[UIScreen mainScreen] scale];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                screenScale = [[UIScreen mainScreen] scale];
            });
        }
    });
    return screenScale;
}

- (CGRect)currentBounds {
    return [self boundsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation {
    CGRect bounds = [self bounds];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {//如果是横屏
        CGFloat buffer = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = buffer;
    }
    return bounds;
}

/**分辨率*/
- (CGSize)sizeInPixel {
    CGSize size = CGSizeZero;
    
    if ([[UIScreen mainScreen] isEqual:self]) {
        NSString *model = [UIDevice currentDevice].machineModel;
        
        if ([model hasPrefix:@"iPhone"]) {
            if ([model isEqualToString:@"iPhone7,1"]) return CGSizeMake(1080, 1920);
            if ([model isEqualToString:@"iPhone8,2"]) return CGSizeMake(1080, 1920);
            if ([model isEqualToString:@"iPhone9,2"]) return CGSizeMake(1080, 1920);
            if ([model isEqualToString:@"iPhone9,4"]) return CGSizeMake(1080, 1920);
        }
        if ([model hasPrefix:@"iPad"]) {
            if ([model hasPrefix:@"iPad6,7"]) size = CGSizeMake(2048, 2732);
            if ([model hasPrefix:@"iPad6,8"]) size = CGSizeMake(2048, 2732);
        }
    }
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        if ([self respondsToSelector:@selector(nativeBounds)]) {
            size = self.nativeBounds.size;
        } else {
            size = self.bounds.size;
            size.width *= self.scale;
            size.height *= self.scale;
        }
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    }
    return size;
}

- (CGFloat)pixelsPerInch {
    if (![[UIScreen mainScreen] isEqual:self]) {
        return 326;
    }
    
    static CGFloat ppi = 0;
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSDictionary<NSString*, NSNumber *> *dic = @{
                                                     @"Watch1,1" : @326,
                                                     @"Watch1,2" : @326,
                                                     @"Watch2,3" : @326,
                                                     @"Watch2,4" : @326,
                                                     @"Watch2,6" : @326,
                                                     @"Watch1,7" : @326,
                                                     
                                                     @"iPod1,1" : @163,
                                                     @"iPod2,1" : @163,
                                                     @"iPod3,1" : @163,
                                                     @"iPod4,1" : @326,
                                                     @"iPod5,1" : @326,
                                                     @"iPod7,1" : @326,
                                                     
                                                     @"iPhone1,1" : @163,
                                                     @"iPhone1,2" : @163,
                                                     @"iPhone2,1" : @163,
                                                     @"iPhone3,1" : @326,
                                                     @"iPhone3,2" : @326,
                                                     @"iPhone3,3" : @326,
                                                     @"iPhone4,1" : @326,
                                                     @"iPhone5,1" : @326,
                                                     @"iPhone5,2" : @326,
                                                     @"iPhone5,3" : @326,
                                                     @"iPhone5,4" : @326,
                                                     @"iPhone6,1" : @326,
                                                     @"iPhone6,2" : @326,
                                                     @"iPhone7,1" : @401,
                                                     @"iPhone7,2" : @326,
                                                     @"iPhone8,1" : @326,
                                                     @"iPhone8,2" : @401,
                                                     @"iPhone8,4" : @326,
                                                     @"iPhone9,1" : @326,
                                                     @"iPhone9,2" : @401, 
                                                     @"iPhone9,3" : @326, 
                                                     @"iPhone9,4" : @401, 
                                                     
                                                     @"iPad1,1" : @132, 
                                                     @"iPad2,1" : @132, 
                                                     @"iPad2,2" : @132, 
                                                     @"iPad2,3" : @132, 
                                                     @"iPad2,4" : @132, 
                                                     @"iPad2,5" : @264, 
                                                     @"iPad2,6" : @264, 
                                                     @"iPad2,7" : @264, 
                                                     @"iPad3,1" : @324, 
                                                     @"iPad3,2" : @324, 
                                                     @"iPad3,3" : @324, 
                                                     @"iPad3,4" : @324, 
                                                     @"iPad3,5" : @324, 
                                                     @"iPad3,6" : @324, 
                                                     @"iPad4,1" : @324, 
                                                     @"iPad4,2" : @324, 
                                                     @"iPad4,3" : @324, 
                                                     @"iPad4,4" : @264, 
                                                     @"iPad4,5" : @264, 
                                                     @"iPad4,6" : @264, 
                                                     @"iPad4,7" : @264, 
                                                     @"iPad4,8" : @264, 
                                                     @"iPad4,9" : @264, 
                                                     @"iPad5,1" : @264, 
                                                     @"iPad5,2" : @264, 
                                                     @"iPad5,3" : @324, 
                                                     @"iPad5,4" : @324, 
                                                     @"iPad6,3" : @324, 
                                                     @"iPad6,4" : @324, 
                                                     @"iPad6,7" : @264, 
                                                     @"iPad6,8" : @264, 
                                                     };
        NSString *model = [UIDevice currentDevice].machineModel;
        if (model) {
            ppi = dic[name].doubleValue;
        }
        if (ppi == 0) ppi = 326;
    });
    return ppi;
}


@end
