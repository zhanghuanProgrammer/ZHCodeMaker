//
//  ZHImageCompression.m
//  代码助手
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 com/qianfeng/mac. All rights reserved.
//

#import "ZHImageCompression.h"

@implementation ZHImageCompression
+ (void)compresionImagePath:(NSString *)imagePath compresionPer:(CGFloat)compresionPer{
    UIImage *image=[UIImage imageNamed:imagePath];
    NSData *data=UIImageJPEGRepresentation(image, compresionPer);
    image = [UIImage imageWithData: data];
    data=UIImagePNGRepresentation(image);
    
    NSString *newFilePath=[ZHFileManager getFilePathRemoveFileName:imagePath];
    NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:imagePath];
    fileName=[fileName stringByAppendingString:@"备份"];
    newFilePath=[newFilePath stringByAppendingPathComponent:fileName];
    NSString *lastPathComponent=[ZHFileManager getFileNameFromFilePath:imagePath];
    lastPathComponent=[lastPathComponent pathExtension];
    if ([lastPathComponent hasPrefix:@"."]) {
        newFilePath =[newFilePath stringByAppendingString:lastPathComponent];
    }else{
        newFilePath=[newFilePath stringByAppendingString:@"."];
        newFilePath =[newFilePath stringByAppendingString:lastPathComponent];
    }
    [data writeToFile:newFilePath atomically:YES];
}

@end
