#import <Foundation/Foundation.h>

@interface NSData (ZH)

- (NSString *)utf8String;

- (NSString *)hexString;

+ (NSData *)dataWithHexString:(NSString *)hexStr;

- (id)jsonValueDecoded;

- (NSData *)gzipInflate;

- (NSData *)gzipDeflate;

- (NSData *)zlibInflate;

- (NSData *)zlibDeflate;

@end
