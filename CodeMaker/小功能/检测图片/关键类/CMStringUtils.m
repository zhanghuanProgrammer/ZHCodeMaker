
#import "CMStringUtils.h"

static NSString * const kSuffix2x = @"@2x";
static NSString * const kSuffix3x = @"@3x";

@implementation CMStringUtils

+ (NSString *)stringByRemoveResourceSuffix:(NSString *)str {
    NSString *suffix = [str pathExtension];
    return [self stringByRemoveResourceSuffix:str suffix:suffix];
}

+ (NSString *)stringByRemoveResourceSuffix:(NSString *)str suffix:(NSString *)suffix {
    NSString *keyName = str;
    
    if (suffix.length && [keyName hasSuffix:suffix]) {
        keyName = [keyName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", suffix] withString:@""];
    }
    if ([keyName hasSuffix:kSuffix2x]) {
        keyName = [keyName stringByReplacingOccurrencesOfString:kSuffix2x withString:@""];
    } else if ([keyName hasSuffix:kSuffix3x]) {
        keyName = [keyName stringByReplacingOccurrencesOfString:kSuffix3x withString:@""];
    }
    return keyName;
}

+ (BOOL)isContainImage:(NSString *)imagePath inArr:(NSArray *)arr{
    NSString *fileName = [ZHFileManager getFileNameFromFilePath:imagePath];
    fileName = [self stringByRemoveResourceSuffix:fileName];
    for (NSString *filePath in arr) {
        NSString *fileNameTemp = [ZHFileManager getFileNameFromFilePath:filePath];
        fileNameTemp = [self stringByRemoveResourceSuffix:fileNameTemp];
        if ([fileNameTemp isEqualToString:fileName]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)creatEmportDirector{
    NSString *emportFilePath = [[ZHFileManager getMacDesktop] stringByAppendingPathComponent:@"未命名文件夹"];
    [ZHFileManager creatDirectorIfNotExsit:emportFilePath];
    return emportFilePath;
}
+ (NSArray *)images:(NSString *)project{
    return [ZHFileManager subPathFileArrInDirector:project hasPathExtension:@[@".png", @".jpg", @".jpeg", @".gif", @".bmp", @".pdf"]];
}
+ (NSArray *)codeFiles:(NSString *)project{
    return [ZHFileManager subPathFileArrInDirector:project hasPathExtension:@[@".h", @".m", @".mm", @".swift", @".xib", @".storyboard", @".strings", @".c", @".cpp"]];
}

/**导出所有切图*/
+ (void)emportAllImageFile:(NSString *)project{
    NSArray *images=[self images:project];
    NSString *emportFilePath = [self creatEmportDirector];
    [ZHFileManager removeItemAtPath:emportFilePath];
    emportFilePath = [self creatEmportDirector];
    for (NSString *filePath in images) {
        [ZHFileManager copyItemAtPath:filePath toPath:[emportFilePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]]];
    }
}

/**批量分类哪些可导入,哪些不能*/
+ (void)emportCategoryImageFile:(NSString *)project{
    NSArray *images=[self images:project];
    NSString *emportFilePath = [[ZHFileManager getMacDesktop] stringByAppendingPathComponent:@"未命名文件夹"];
    NSArray *emportImages = [ZHFileManager subPathFileArrInDirector:emportFilePath hasPathExtension:@[@".png", @".jpg", @".jpeg", @".gif", @".bmp", @".pdf"]];
    if (emportImages.count<=0) {
        return;
    }
    NSMutableArray *noUse = [NSMutableArray array];
    NSMutableArray *use = [NSMutableArray array];
    for (NSString *imagePath in emportImages) {
        if ([self isContainImage:imagePath inArr:images]) {
            [use addObject:imagePath];
        }else{
            [noUse addObject:imagePath];
        }
    }
    NSString *emportFilePathNoUse = [emportFilePath stringByAppendingPathComponent:@"NoUse"];
    NSString *emportFilePathUse = [emportFilePath stringByAppendingPathComponent:@"Use"];
    [ZHFileManager creatDirectorIfNotExsit:emportFilePathNoUse];
    [ZHFileManager creatDirectorIfNotExsit:emportFilePathUse];
    for (NSString *filePath in noUse) {
        [ZHFileManager copyItemAtPath:filePath toPath:[emportFilePathNoUse stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]]];
    }
    for (NSString *filePath in use) {
        [ZHFileManager copyItemAtPath:filePath toPath:[emportFilePathUse stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]]];
    }
    for (NSString *filePath in emportImages) {
        [ZHFileManager removeItemAtPath:filePath];
    }
}

@end
