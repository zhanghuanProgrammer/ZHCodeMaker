#import <UIKit/UIKit.h>

@interface ZHHelp : NSObject
+ (NSString *)getHomeDirector;
+(UIViewController *)getViewControllerForView:(UIView *)target;
+ (void)creatDirectorIfNotExsit:(NSString *)DirectorPath;
+ (BOOL)validateNumber:(NSString*)number;
+ (void)saveFileToApp:(NSString *)fileName withRealFilePath:(NSString *)realFilePath;
+ (NSString *)getFilePathFromApp:(NSString *)fileName;
+ (void)deleteFileFromApp:(NSString *)fileName;

/**获取一个独一无二的文件名*/
+ (NSString *)getOlnyOneFilePathToAppWithPathExtension:(NSString *)pathExtension;
+ (NSString *)getCurFilePathFromApp:(NSString *)filePath;
+ (NSString *)getTableView;
+ (NSString *)getCollectionView;


+ (NSString *)getTableCellsInsertCells:(NSArray *)textCell;
+ (NSString *)getCollectionCellsInsertCells:(NSArray *)textCell;

//如果主目录不存在,就创建主目录
+ (void)creatMainPath;

+ (NSString *)creatCurDataDirectorToMacDestop;
+ (NSString *)creatCurDataDirectorToMacDocuments;

+ (CGFloat)getCellHeight:(NSString *)CellText;
+ (CGFloat)getCellWidth:(NSString *)CellText;
@end
