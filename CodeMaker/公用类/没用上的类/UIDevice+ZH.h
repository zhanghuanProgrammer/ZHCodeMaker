#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIDevice (ZH)

#pragma mark - Device Information

+ (double)systemVersion;

@property (nonatomic, readonly) BOOL isPad;

@property (nonatomic, readonly) BOOL isSimulator;

@property (nonatomic, readonly) BOOL isJailbroken;

@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

@property (nullable, nonatomic, readonly) NSString *machineModel;//机器模型类型

@property (nullable, nonatomic, readonly) NSString *machineModelName;

@property (nonatomic, readonly) NSDate *systemUptime;


#pragma mark - Network Information

@property (nullable, nonatomic, readonly) NSString *ipAddressWIFI;

@property (nullable, nonatomic, readonly) NSString *ipAddressCell;

typedef NS_OPTIONS(NSUInteger, NetworkTrafficType) {
    NetworkTrafficTypeWWANSent     = 1 << 0,
    NetworkTrafficTypeWWANReceived = 1 << 1,
    NetworkTrafficTypeWIFISent     = 1 << 2,
    NetworkTrafficTypeWIFIReceived = 1 << 3,
    NetworkTrafficTypeAWDLSent     = 1 << 4,
    NetworkTrafficTypeAWDLReceived = 1 << 5,
    
    NetworkTrafficTypeWWAN = NetworkTrafficTypeWWANSent | NetworkTrafficTypeWWANReceived,
    NetworkTrafficTypeWIFI = NetworkTrafficTypeWIFISent | NetworkTrafficTypeWIFIReceived,
    NetworkTrafficTypeAWDL = NetworkTrafficTypeAWDLSent | NetworkTrafficTypeAWDLReceived,
    
    NetworkTrafficTypeALL = NetworkTrafficTypeWWAN |
    NetworkTrafficTypeWIFI |
    NetworkTrafficTypeAWDL,
};

- (uint64_t)getNetworkTrafficBytes:(NetworkTrafficType)types;

#pragma mark - Disk Space

@property (nonatomic, readonly) int64_t diskSpace;

@property (nonatomic, readonly) int64_t diskSpaceFree;

@property (nonatomic, readonly) int64_t diskSpaceUsed;

#pragma mark - Memory Information

@property (nonatomic, readonly) int64_t memoryTotal;

@property (nonatomic, readonly) int64_t memoryUsed;

@property (nonatomic, readonly) int64_t memoryFree;

@property (nonatomic, readonly) int64_t memoryActive;

@property (nonatomic, readonly) int64_t memoryInactive;

@property (nonatomic, readonly) int64_t memoryWired;

@property (nonatomic, readonly) int64_t memoryPurgable;

#pragma mark - CPU Information

@property (nonatomic, readonly) NSUInteger cpuCount;

@property (nonatomic, readonly) float cpuUsage;

@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *cpuUsagePerProcessor;

@end
NS_ASSUME_NONNULL_END
