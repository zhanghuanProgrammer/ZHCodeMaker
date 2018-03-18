#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ZHRemoveTheCommentsTypeAllComments,//删除全部注释
    ZHRemoveTheCommentsTypeFileInstructionsComments,//删除文件说明注释
    ZHRemoveTheCommentsTypeEnglishComments,//删除英文注释
    ZHRemoveTheCommentsTypeDoubleSlashComments,//删除//注释
    ZHRemoveTheCommentsTypeFuncInstructionsComments//删除/ **\/或\/ ***\/注释
} ZHRemoveTheCommentsType;

@interface ZHRemoveTheComments : NSObject

+ (NSString *)BeginWithFilePath:(NSString *)filePath type:(ZHRemoveTheCommentsType)type;

/**    删除所有注释并且提取出注释   */
+ (NSString *)removeAllComments:(NSString *)text saveAnnotations:(NSMutableArray *)annotations;

/**获取//注释*/
+ (NSString *)removeDoubleSlashComments:(NSString *)text saveAnnotations:(NSMutableArray *)annotations;

/**获取/ **\/或\/ ***\/注释*/
+ (NSString *)removeFuncInstructionsComments:(NSString *)text saveAnnotations:(NSMutableArray *)annotations;

@end
