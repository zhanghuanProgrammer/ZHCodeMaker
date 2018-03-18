
@interface NSString (ZH)
NS_ASSUME_NONNULL_BEGIN

- (nullable NSString *)md2String;

- (nullable NSString *)md4String;

- (nullable NSString *)md5String;

- (nullable NSString *)sha1String;

- (nullable NSString *)sha224String;

- (nullable NSString *)sha256String;

- (nullable NSString *)sha384String;

- (nullable NSString *)sha512String;

- (nullable NSString *)hmacMD5StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA1StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA224StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA256StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA384StringWithKey:(NSString *)key;

- (nullable NSString *)hmacSHA512StringWithKey:(NSString *)key;

/**将<> "等字符串转换成XML中标准的字符串*/
- (NSString *)stringByEscapingHTML;

/**求文本的宽度*/
- (CGFloat)widthForFont:(UIFont *)font;

/**求文本的高度(在限制宽度的条件下)*/
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;


- (char)charValue;

- (unsigned char) unsignedCharValue;

- (short) shortValue;

- (unsigned short) unsignedShortValue;

- (unsigned int) unsignedIntValue;

- (long) longValue;

- (unsigned long) unsignedLongValue;

- (unsigned long long) unsignedLongLongValue;

- (NSUInteger) unsignedIntegerValue;


- (NSData *)dataValue;

- (NSRange)rangeOfAll;

- (id)jsonValueDecoded;


- (BOOL)containsString:(NSString *)string;
/**是否存在某些字符集*/
- (BOOL)containsCharacterSet:(NSCharacterSet *)set;

- (NSString *)stringByTrim;

/**是否不为空,比如里面只有空格换行等*/
- (BOOL)isNotBlank;

/**读取某个文件里面的字符串*/
+ (NSString *)stringNamed:(NSString *)name;

/**获取设备的UIID*/
+ (NSString *)stringWithUUID;


/**是否存在复合正则表达式的字符串,有则返回是*/
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;

/**用正则表达式遍历复合条件的字符串*/
- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;

/**用正则表达式替换字符串*/
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement;

/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)firstCharLower;

NS_ASSUME_NONNULL_END
@end
