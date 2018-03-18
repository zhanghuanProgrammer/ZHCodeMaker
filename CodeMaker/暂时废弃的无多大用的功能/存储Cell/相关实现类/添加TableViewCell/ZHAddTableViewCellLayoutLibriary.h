#import <Foundation/Foundation.h>

@interface ZHAddTableViewCellLayoutLibriary : NSObject

@property (nonatomic,copy)NSString *filePath;
@property (nonatomic,strong)NSArray *codeFilePath;

- (NSArray *)saveTableViewCellSubViewDraw;

@end
