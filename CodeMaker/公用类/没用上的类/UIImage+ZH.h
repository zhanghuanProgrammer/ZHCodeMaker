#import <UIKit/UIKit.h>

@interface UIImage (ZH)

/**加载GIF图片*/
+ (UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

/**是否是GIF图片数据*/
+ (BOOL)isAnimatedGIFData:(NSData *)data;

/**是否是GIF文件*/
+ (BOOL)isAnimatedGIFFile:(NSString *)path;

/**加载图片从PDF*/
+ (UIImage *)imageWithPDF:(id)dataOrPath resize:(BOOL)resize size:(CGSize)size;

/**加载图片从PDF*/
+ (UIImage *)imageWithPDF:(id)dataOrPath;

/**加载图片从PDF*/
+ (UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;

/**加载图片根据纯颜色*/
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**加载图片根据纯颜色*/
+ (UIImage *)imageWithColor:(UIColor *)color;


- (UIImage *)imageByTintColor:(UIColor *)color;

/**判断图片是否有Alpha通道*/
- (BOOL)hasAlphaChannel;

/**根据ContentMode来获取合适的Rect*/
CGRect CGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/**将自身按照contentMode和rect绘制在画布上*/
- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

/**设置图片按照原图渲染*/
- (instancetype)imageWithOriginalImageName;

/**重新调整图片的大小*/
- (UIImage *)imageByResizeToSize:(CGSize)size;

/**重新调整图片的大小根据ContentMode*/
- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

/**快速建议一张画布,并且返回画布上的图像为Image*/
+ (UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

/**给图片加个颜色边框*/
- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color;

/**裁剪图片*/
- (UIImage *)imageByCropToRect:(CGRect)rect;

/**给图片切圆角*/
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;

/**给图片切圆角*/
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;

/**给图片切圆角*/
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                              corners:(UIRectCorner)corners
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor
                       borderLineJoin:(CGLineJoin)borderLineJoin;

/**旋转图片*/
- (UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize;

CGFloat DegreesToRadians(CGFloat degrees);

- (UIImage *)imageByRotateLeft90;

- (UIImage *)imageByRotateRight90;

/**调整图片为横或者竖直*/
- (UIImage *)flipHorizontal:(BOOL)horizontal vertical:(BOOL)vertical;

/**旋转180度*/
- (UIImage *)imageByRotate180;

/**图片垂直*/
- (UIImage *)imageByFlipVertical;

/**图片横屏*/
- (UIImage *)imageByFlipHorizontal;

/**将文字变成图片*/
+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

/**高斯模糊图片*/
- (UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor *)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage *)maskImage;

- (UIImage *)mergeImageRef:(CGImageRef)effectCGImage
                 tintColor:(UIColor *)tintColor
             tintBlendMode:(CGBlendMode)tintBlendMode
                 maskImage:(UIImage *)maskImage
                    opaque:(BOOL)opaque;

/**Gray高斯模糊*/
- (UIImage *)imageByGrayscale;

/**Soft高斯模糊*/
- (UIImage *)imageByBlurSoft;

/**BlurLight高斯模糊*/
- (UIImage *)imageByBlurLight;

/**ExtraLight高斯模糊*/
- (UIImage *)imageByBlurExtraLight;

/**BlurDark高斯模糊*/
- (UIImage *)imageByBlurDark;

/**自定义高斯模糊*/
- (UIImage *)imageByBlurWithTint:(UIColor *)tintColor;

@end
