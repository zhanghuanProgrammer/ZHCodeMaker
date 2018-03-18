#import <Foundation/Foundation.h>

@interface ZHImage : NSObject
/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;

/**截取整个TableView的内容形成图片返回*/
+ (UIImage *)getImageFromTableView:(UITableView *)tableView;

/**截取整个view的内容形成图片返回*/
+ (UIImage *)getImageFromView:(UIView *)view;

/**保存image数据到指定文件(PNG格式)*/
+ (void)saveImage_PNG:(UIImage *)image toFile:(NSString *)filePath;

/**保存image数据到指定文件(JPG格式)*/
+ (void)saveImage_JPG:(UIImage *)image compressionQuality:(CGFloat)compressionQuality toFile:(NSString *)filePath;

@end
