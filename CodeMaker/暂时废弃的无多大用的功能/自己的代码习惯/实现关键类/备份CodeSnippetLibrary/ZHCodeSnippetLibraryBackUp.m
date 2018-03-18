#import "ZHCodeSnippetLibraryBackUp.h"

@implementation ZHCodeSnippetLibraryBackUp

/**备份CodeSnippetLibrary到Mac文稿*/
+ (BOOL)codeSnippetLibraryBackUp{
    NSString *fromPath=[ZHFileManager getMacUserPath];
    fromPath = [fromPath stringByAppendingPathComponent:@"Library/Developer/Xcode/UserData/CodeSnippets"];
    NSString *toPath=[ZHFileManager getMacDocuments];
    //如果已经存在,先删除
    NSString *directorName=[ZHFileManager getFileNameNoPathComponentFromFilePath:fromPath];
    if (directorName.length>0) {
        NSString *targetPath=[toPath stringByAppendingPathComponent:directorName];
        if (![targetPath isEqualToString:toPath]&&[ZHFileManager fileExistsAtPath:targetPath]) {
            [ZHFileManager removeItemAtPath:targetPath];
        }
    }
    toPath = [toPath stringByAppendingPathComponent:[ZHFileManager getFileNameNoPathComponentFromFilePath:fromPath]];
    if ([ZHFileManager fileExistsAtPath:fromPath]) {
        return [ZHFileManager copyItemAtPath:fromPath toPath:toPath];
    }
    return NO;
}

@end
