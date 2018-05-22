
#import <Foundation/Foundation.h>

#pragma mark - ResourceSettings

@interface ResourceSettings : NSObject

@property (strong, nonatomic) NSString *projectPath;
@property (strong, nonatomic) NSArray *excludeFolders; /**< <NSString *> */
@property (strong, nonatomic) NSArray *resourceSuffixs; /**< <NSString *> */
@property (strong, nonatomic) NSArray *resourcePatterns; /**< <NSDictionary *> */
@property (strong, nonatomic) NSNumber *matchSimilarName;

+ (instancetype)sharedObject;

- (void)updateResourcePatternAtIndex:(NSInteger)index withObject:(id)obj forKey:(NSString *)key;

- (void)addResourcePattern:(NSDictionary *)pattern;

- (void)removeResourcePatternAtIndex:(NSInteger)index;

@end
