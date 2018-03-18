
#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

typedef void(^ZHImageViewBlock)();

@interface UIImageView (ZHImageViewValue)
/**为UIImageView设置图片根据URL*/
- (void)imageWithURLString:(NSString *)url;

/**为UIImageView设置图片根据URL 支持使用本地占位图*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName;

/**为UIImageView设置图片根据URL 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block;

/**为UIImageView设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block;

@end
@interface UIButton (ZHButtonValue)
/**为UIButton的前景图片设置图片根据URL*/
- (void)imageWithURLString:(NSString *)url;

/**为UIButton的前景图片设置图片根据URL 支持使用本地占位图*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName;

/**为UIButton的前景图片设置图片根据URL 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block;

/**为UIButton的前景图片设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block;

/**为UIButton的背景图片:BackgroundImage设置图片根据URL*/
- (void)backgroundImageWithURLString:(NSString *)url;

/**为UIButton的背景图片:BackgroundImage设置图片根据URL 支持使用本地占位图*/
- (void)backgroundImageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName;

/**为UIButton的背景图片:BackgroundImage设置图片根据URL 支持加载完后回调block*/
- (void)backgroundImageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block;

/**为UIButton的背景图片:BackgroundImage设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)backgroundImageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block;

@end
@interface UIView (ZHUIViewValue)
/**为UIButton的Layer图层设置图片根据URL*/
- (void)imageWithURLString:(NSString *)url;

/**为UIButton的Layer图层设置图片根据URL 支持使用本地占位图*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName;

/**为UIButton的Layer图层设置图片根据URL 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block;

/**为UIButton的Layer图层设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block;

@end