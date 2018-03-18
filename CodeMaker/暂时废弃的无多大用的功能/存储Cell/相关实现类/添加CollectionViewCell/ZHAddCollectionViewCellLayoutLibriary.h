#import <Foundation/Foundation.h>

@interface ZHAddCollectionViewCellLayoutLibriary : NSObject

@property (nonatomic,copy)NSString *filePath;
@property (nonatomic,strong)NSArray *codeFilePath;

- (NSArray *)saveCollectionViewCellSubViewDraw;

@end
