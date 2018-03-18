#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

@interface UIFont (ZH)

- (BOOL)isBold;

- (BOOL)isItalic;

- (BOOL)isMonoSpace;

- (BOOL)isColorGlyphs;

- (CGFloat)fontWeight;

- (UIFont *)fontWithBold;

- (UIFont *)fontWithItalic;

- (UIFont *)fontWithBoldItalic;

- (UIFont *)fontWithNormal;

+ (BOOL)loadFontFromPath:(NSString *)path;

+ (void)unloadFontFromPath:(NSString *)path;

@end
