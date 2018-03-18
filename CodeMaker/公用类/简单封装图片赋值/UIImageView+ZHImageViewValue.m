

#import "UIImageView+ZHImageViewValue.h"

@implementation UIImageView (ZHImageViewValue)

+ (NSString *)getAdapterImageName:(NSString *)imageName ofType:(NSString *)ext{
    NSString *path;
    if ([imageName rangeOfString:@"."].location==NSNotFound) {
        ext=@"png";
    }else{
        ext=[imageName pathExtension];
        imageName=[imageName stringByDeletingPathExtension];
    }
    
    //如果本身就含有@3x或者@2x
    if ([imageName hasSuffix:@"@3x"]||[imageName hasSuffix:@"@2x"]) {
        imageName=[imageName substringToIndex:imageName.length-3];
    }
    
    imageName=[imageName stringByAppendingString:@"@3x"];
    path=[[NSBundle mainBundle]pathForResource:imageName ofType:ext];
    //如果@3x的图片不存在
    if (path==nil) {
        imageName=[imageName substringToIndex:imageName.length-3];
        
        //尝试@2x的图片
        imageName=[imageName stringByAppendingString:@"@2x"];
        path=[[NSBundle mainBundle]pathForResource:imageName ofType:ext];
        if (path==nil) {
            
            //尝试原来的无@nx的图片
            imageName=[imageName substringToIndex:imageName.length-3];
            path=[[NSBundle mainBundle]pathForResource:imageName ofType:ext];
            return path;
        }
        return path;
    }
    return path;
}
+ (BOOL)islocalFile:(NSString *)fileName{
    if ([fileName rangeOfString:@"http"].location!=NSNotFound||[fileName rangeOfString:@"www"].location!=NSNotFound) {
        return NO;
    }
    if ([self getAdapterImageName:fileName ofType:nil].length>0) {
        return YES;
    }
    return NO;
}
+ (BOOL)isAbsolutePath:(NSString *)fileName{
    if ([[NSFileManager defaultManager]fileExistsAtPath:fileName]) {
        return YES;
    }
    return NO;
}
- (BOOL)isPng:(NSString *)imageName{
    if ([imageName hasSuffix:@"png"]||[imageName hasPrefix:@"PNG"]||[imageName pathExtension].length<=0) {
        self.image=[UIImage imageNamed:imageName];
        return YES;
    }
    return NO;
}


- (void)imageWithURLString:(NSString *)url isLocalFile:(BOOL)localFile{
    
    if ([UIImageView isAbsolutePath:url]) {
        if ([self isPng:url])return;
        [self sd_setImageWithURL:[NSURL fileURLWithPath:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:nil];
        return;
    }
    
    if (localFile) {
        url=[UIImageView getAdapterImageName:url ofType:nil];
        if (url.length<=0) return;
        if ([self isPng:url])return;
        [self sd_setImageWithURL:[NSURL fileURLWithPath:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:nil];
        return;
    }
    if (url.length<=0) return;
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:nil];
}
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:fileName withCompleteBlock:nil isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:nil withCompleteBlock:block isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    if (fileName!=nil) {
        
        if ([UIImageView isAbsolutePath:url]) {
            if ([self isPng:url]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] placeholderImage:[UIImage imageWithContentsOfFile:fileName] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        
        NSString *filePath=[UIImageView getAdapterImageName:fileName ofType:nil];
        if (localFile) {
            
            url=[UIImageView getAdapterImageName:url ofType:nil];
            if (url.length<=0) return;
            if ([self isPng:url]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] placeholderImage:[UIImage imageWithContentsOfFile:filePath] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        if (url.length<=0) return;
        
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithContentsOfFile:filePath] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (block!=nil) {
                block();
            }
        }];
    }else{
        if ([UIImageView isAbsolutePath:url]) {
            if ([self isPng:url]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        
        if (localFile) {
            
            url=[UIImageView getAdapterImageName:url ofType:nil];
            if (url.length<=0) return;
            if ([self isPng:url]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        if (url.length<=0) return;
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (block!=nil) {
                block();
            }
        }];
    }
}

/**为UIImageView设置图片根据URL*/
- (void)imageWithURLString:(NSString *)url{
    if (url.length<=0)return;
    [self imageWithURLString:url isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIImageView设置图片根据URL 支持使用本地占位图*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName{
    if (url.length<=0)return;
    [self imageWithURLString:url placeholderImage:fileName isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIImageView设置图片根据URL 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self imageWithURLString:url withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIImageView设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self imageWithURLString:url placeholderImage:fileName withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}

@end


@implementation UIButton (ZHButtonValue)
- (BOOL)isPng:(NSString *)imageName isBackGround:(BOOL)backGround{
    if ([imageName hasSuffix:@"png"]||[imageName hasPrefix:@"PNG"]||[imageName pathExtension].length<=0) {
        if (backGround) {
            [self setBackgroundImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
        }else{
            [self setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
        }
        return YES;
    }
    return NO;
}
- (void)imageWithURLString:(NSString *)url isLocalFile:(BOOL)localFile{
    if ([UIImageView isAbsolutePath:url]) {
        if ([self isPng:url isBackGround:NO])return;
        [self sd_setImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
        }];
        return;
    }
    
    if (localFile) {
        url=[UIImageView getAdapterImageName:url ofType:nil];
        if (url.length<=0) return;
        if ([self isPng:url isBackGround:NO])return;
        [self sd_setImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
        }];
        return;
    }
    if (url.length<=0) return;
    [self sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:(UIControlStateNormal)];
    }];
}
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:fileName withCompleteBlock:nil isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:nil withCompleteBlock:block isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    if (fileName!=nil) {
        if ([UIImageView isAbsolutePath:url]) {
            if ([self isPng:url isBackGround:NO]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:fileName] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        
        NSString *filePath=[UIImageView getAdapterImageName:fileName ofType:nil];
        if (localFile) {
            
            url=[UIImageView getAdapterImageName:url ofType:nil];
            if (url.length<=0) return;
            if ([self isPng:url isBackGround:NO]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:filePath] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        if (url.length<=0) return;
        
        [self sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:filePath] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (block!=nil) {
                block();
            }
        }];
    }else{
        if ([UIImageView isAbsolutePath:url]) {
            if ([self isPng:url isBackGround:NO]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        if (localFile) {
            
            url=[UIImageView getAdapterImageName:url ofType:nil];
            if (url.length<=0) return;
            if ([self isPng:url isBackGround:NO]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        if (url.length<=0) return;
        [self sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (block!=nil) {
                block();
            }
        }];
    }
}

- (void)backgroundImageWithURLString:(NSString *)url isLocalFile:(BOOL)localFile{
    [self backgroundImageWithURLString:url placeholderImage:nil withCompleteBlock:nil isLocalFile:localFile];
}
- (void)backgroundImageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName isLocalFile:(BOOL)localFile{
    [self backgroundImageWithURLString:url placeholderImage:fileName withCompleteBlock:nil isLocalFile:localFile];
}
- (void)backgroundImageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    [self backgroundImageWithURLString:url placeholderImage:nil withCompleteBlock:block isLocalFile:localFile];
}
- (void)backgroundImageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    if (fileName!=nil) {
        if ([UIImageView isAbsolutePath:url]) {
            if ([self isPng:url isBackGround:YES]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setBackgroundImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:fileName] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        NSString *filePath=[UIImageView getAdapterImageName:fileName ofType:nil];
        if (localFile) {
            
            url=[UIImageView getAdapterImageName:url ofType:nil];
            if (url.length<=0) return;
            if ([self isPng:url isBackGround:YES]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setBackgroundImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:filePath] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            
            return;
        }
        
        [self sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageWithContentsOfFile:filePath] options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (block!=nil) {
                block();
            }
        }];
    }else{
        if ([UIImageView isAbsolutePath:url]) {
            if ([self isPng:url isBackGround:YES]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setBackgroundImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        if (localFile) {
            
            url=[UIImageView getAdapterImageName:url ofType:nil];
            if (url.length<=0) return;
            if ([self isPng:url isBackGround:YES]){
                if (block!=nil) {
                    block();
                }
                return;
            }
            [self sd_setBackgroundImageWithURL:[NSURL fileURLWithPath:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (block!=nil) {
                    block();
                }
            }];
            return;
        }
        [self sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageCacheMemoryOnly|SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (block!=nil) {
                block();
            }
        }];
    }
}

/**为UIButton的前景图片设置图片根据URL*/
- (void)imageWithURLString:(NSString *)url{
    if (url.length<=0)return;
    [self imageWithURLString:url isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIButton的前景图片设置图片根据URL 支持使用本地占位图*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName{
    if (url.length<=0)return;
    [self imageWithURLString:url placeholderImage:fileName isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIButton的前景图片设置图片根据URL 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self imageWithURLString:url withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIButton的前景图片设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self imageWithURLString:url placeholderImage:fileName withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}

/**为UIButton的背景图片:BackgroundImage设置图片根据URL*/
- (void)backgroundImageWithURLString:(NSString *)url{
    if (url.length<=0)return;
    [self backgroundImageWithURLString:url isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIButton的背景图片:BackgroundImage设置图片根据URL 支持使用本地占位图*/
- (void)backgroundImageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName{
    if (url.length<=0)return;
    [self backgroundImageWithURLString:url placeholderImage:fileName isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIButton的背景图片:BackgroundImage设置图片根据URL 支持加载完后回调block*/
- (void)backgroundImageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self backgroundImageWithURLString:url withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIButton的背景图片:BackgroundImage设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)backgroundImageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self backgroundImageWithURLString:url placeholderImage:fileName withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}
@end
@implementation UIView (ZHUIViewValue)
- (void)imageWithURLString:(NSString *)url isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:nil withCompleteBlock:nil isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:fileName withCompleteBlock:nil isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    [self imageWithURLString:url placeholderImage:nil withCompleteBlock:block isLocalFile:localFile];
}
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block isLocalFile:(BOOL)localFile{
    //实例化一个新的layer
    CALayer *imageLayer = [CALayer new];
    imageLayer.frame = self.layer.bounds;
    //在view1上添加一层信的layer
    [self.layer addSublayer:imageLayer];
    imageLayer.masksToBounds = YES;
    //显示图片
    
    if (fileName!=nil) {
        NSString *filePath=[UIImageView getAdapterImageName:fileName ofType:nil];
        imageLayer.contents = (id)[UIImage imageWithContentsOfFile:filePath].CGImage;
    }
    
    __block UIImageView *imageView=[[UIImageView alloc]initWithFrame:self.bounds];
    [imageView imageWithURLString:url withCompleteBlock:^{
        imageLayer.contents = (id)imageView.image.CGImage;
        if (block!=nil) {
            block();
        }
        imageView=nil;
    } isLocalFile:localFile];
}

/**为UIView的Layer图层设置图片根据URL*/
- (void)imageWithURLString:(NSString *)url{
    if (url.length<=0)return;
    [self imageWithURLString:url isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIView的Layer图层设置图片根据URL 支持使用本地占位图*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName{
    if (url.length<=0)return;
    [self imageWithURLString:url placeholderImage:fileName isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIView的Layer图层设置图片根据URL 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self imageWithURLString:url withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}
/**为UIView的Layer图层设置图片根据URL 支持使用本地占位图 支持加载完后回调block*/
- (void)imageWithURLString:(NSString *)url placeholderImage:(NSString *)fileName withCompleteBlock:(ZHImageViewBlock)block{
    if (url.length<=0)return;
    [self imageWithURLString:url placeholderImage:fileName withCompleteBlock:block isLocalFile:[UIImageView islocalFile:url]];
}
@end
