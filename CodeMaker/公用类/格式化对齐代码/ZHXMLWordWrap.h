#import "CreatFatherFile.h"

@interface ZHXMLWordWrap : CreatFatherFile

/**把你要排版的文件或工程进行排版*/
- (void)wordWrap:(NSString *)path;

/**把你要排版的代码进行排版*/
- (NSString *)wordWrapText:(NSString *)text;

@end
