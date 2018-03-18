#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface JKDBHelper : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;
@property (nonatomic,copy)NSString *directoryName;

+ (JKDBHelper *)shareInstance;

+ (NSString *)dbPath:(NSString *)directoryName;

- (BOOL)changeDBWithDirectoryName:(NSString *)directoryName;

- (void)close;

@end
