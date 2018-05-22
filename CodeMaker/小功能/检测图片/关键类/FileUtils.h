
#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+ (uint64_t)fileSizeAtPath:(NSString *)path isDir:(BOOL *)isDir;

+ (uint64_t)folderSizeAtPath:(NSString *)path;

@end
