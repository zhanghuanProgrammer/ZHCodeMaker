#import <Foundation/Foundation.h>

@interface ZHOutPutLayoutLibriary : NSObject

/**纯手写模式-marsony  TableViewCell*/
+ (NSString *)outPut_PureHand_marsonyCodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;
/**纯手写模式-frame  TableViewCell*/
+ (NSString *)outPut_PureHand_frameCodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;
/**非纯手写模式  TableViewCell*/
+ (NSString *)outPut_noPureHandCodePath_TableViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;

/**纯手写模式-marsony  CollectionViewCell*/
+ (NSString *)outPut_PureHand_marsonyCodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;
/**纯手写模式-frame  CollectionViewCell*/
+ (NSString *)outPut_PureHand_frameCodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;
/**非纯手写模式  CollectionViewCell*/
+ (NSString *)outPut_noPureHandCodePath_CollectionViewCell:(NSString *)xmlCodePath withCellName:(NSString *)cellName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress;

+ (void)changeFileNameWithFilesPath:(NSString *)filesPath showAlertToViewController:(UIViewController *)vc;
@end
