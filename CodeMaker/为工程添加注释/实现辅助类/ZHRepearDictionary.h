#import <Foundation/Foundation.h>

@interface ZHRepearDictionary : NSObject

@property (nonatomic,strong)NSMutableDictionary *dicM;

- (void)setValue:(id)value forKey:(NSString *)key;
+ (NSString *)getKeyForKey:(NSString *)key;
@end
