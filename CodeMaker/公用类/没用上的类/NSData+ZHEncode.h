@interface NSData (ZHEncode)

- (NSString *)md2String;

- (NSString *)md4String;

- (NSString *)md5String;

- (NSString *)sha1String;

- (NSString *)sha224String;

- (NSString *)sha256String;

- (NSString *)sha384String;

- (NSString *)sha512String;

- (NSString *)hmacMD5StringWithKey:(NSString *)key;

- (NSString *)hmacSHA1StringWithKey:(NSString *)key;

- (NSString *)hmacSHA224StringWithKey:(NSString *)key;

- (NSString *)hmacSHA256StringWithKey:(NSString *)key;

- (NSString *)hmacSHA384StringWithKey:(NSString *)key;

- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

- (NSString *)base64EncodedString;







- (NSData *)md2Data;

- (NSData *)md4Data;

- (NSData *)md5Data;

- (NSData *)sha1Data;

- (NSData *)sha224Data;

- (NSData *)sha256Data;

- (NSData *)sha384Data;

- (NSData *)sha512Data;

- (NSData *)hmacMD5DataWithKey:(NSData *)key;

- (NSData *)hmacSHA1DataWithKey:(NSData *)key;

- (NSData *)hmacSHA224DataWithKey:(NSData *)key;

- (NSData *)hmacSHA256DataWithKey:(NSData *)key;

- (NSData *)hmacSHA384DataWithKey:(NSData *)key;

- (NSData *)hmacSHA512DataWithKey:(NSData *)key;

- (NSData *)aes256EncryptWithKey:(NSData *)key iv:(NSData *)iv;

- (NSData *)aes256DecryptWithkey:(NSData *)key iv:(NSData *)iv;

+ (NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;
@end
