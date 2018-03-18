#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (ZH)

- (NSURL *)documentsURL;

- (NSString *)documentsPath;

- (NSURL *)cachesURL;

- (NSString *)cachesPath;

- (NSURL *)libraryURL;

- (NSString *)libraryPath;

- (NSString *)appBundleName;

- (NSString *)appBundleID;

- (NSString *)appVersion;

- (NSString *)appBuildVersion;

- (int64_t)memoryUsage;

- (float)cpuUsage;

/**是否是盗版*/
- (BOOL)isPirated;

- (BOOL)fileExistInMainBundle:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
