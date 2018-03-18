#import <Foundation/Foundation.h>

@interface ZHCreatXibHelp : NSObject

+ (void)saveTableViewCellXmlCodePath:(NSString *)xmlCodePath withXibName:(NSString *)xibName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;

+ (void)saveCollectionViewCellXmlCodePath:(NSString *)xmlCodePath withXibName:(NSString *)xibName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;

@end
