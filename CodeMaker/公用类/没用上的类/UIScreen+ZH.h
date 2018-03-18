#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (ZH)

+ (CGFloat)screenScale;

- (CGRect)currentBounds;

- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;

/**分辨率*/
- (CGSize)sizeInPixel;

- (CGFloat)pixelsPerInch;

@end

NS_ASSUME_NONNULL_END
