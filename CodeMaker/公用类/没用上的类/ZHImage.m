#import "ZHImage.h"

@implementation ZHImage

/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

/**截取整个TableView的内容形成图片返回*/
+ (UIImage *)getImageFromTableView:(UITableView *)tableView{
    UIImage* viewImage = nil;
    UITableView *scrollView = tableView;
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, scrollView.opaque, 0.0);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    return viewImage;
}

/**截取整个view的内容形成图片返回*/
+ (UIImage *)getImageFromView:(UIView *)view{
    UIImage* viewImage = nil;
    UIGraphicsBeginImageContextWithOptions(view.size, view.opaque, 0.0);
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

/**保存image数据到指定文件(PNG格式)*/
+ (void)saveImage_PNG:(UIImage *)image toFile:(NSString *)filePath{
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

/**保存image数据到指定文件(JPG格式)*/
+ (void)saveImage_JPG:(UIImage *)image compressionQuality:(CGFloat)compressionQuality toFile:(NSString *)filePath{
    [UIImageJPEGRepresentation(image,compressionQuality) writeToFile:filePath atomically:YES];
}


@end
