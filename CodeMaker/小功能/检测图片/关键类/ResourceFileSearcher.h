
#import <UIKit/UIKit.h>

extern NSString * const kNotificationResourceFileQueryDone;


@interface ResourceFileInfo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) BOOL isDir;
@property (assign, nonatomic) uint64_t fileSize;

@end


@interface ResourceFileSearcher : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary *resNameInfoDict;

+ (instancetype)sharedObject;

- (void)startWithProjectPath:(NSString *)projectPath excludeFolders:(NSArray *)excludeFolders resourceSuffixs:(NSArray *)resourceSuffixs;

- (void)reset;

- (BOOL)isImageSetFolder:(NSString *)folder;

@end
