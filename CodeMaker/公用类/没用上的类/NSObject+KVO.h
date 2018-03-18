#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (KVO)

- (void)addObserverBlockForKeyPath:(NSString*)keyPath block:(void (^)(id _Nonnull obj, _Nullable id oldVal, _Nullable id newVal))block;

- (void)removeObserverBlocksForKeyPath:(NSString*)keyPath;

- (void)removeObserverBlocks;

@end

NS_ASSUME_NONNULL_END
