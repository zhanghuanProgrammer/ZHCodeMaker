#import <Foundation/Foundation.h>

@interface CreatJaveModel : NSObject
@property (nonatomic,assign) BOOL NSNULL;
@property (nonatomic,assign) BOOL NSDATE;
@property (nonatomic,assign) BOOL NSNUMBER;
@property (nonatomic,assign) BOOL BOOLEAN;
+ (void)creatProperty:(id)obj fileName:(NSString *)fileName WithContext:(NSString *)context savePath:(NSString *)savePath withNSNULL:(BOOL)NSNULL withNSDATE:(BOOL)NSDATE withNSNUMBER:(BOOL)NSNUMBER withModelName:(NSString *)modelName withFatherClass:(NSString *)className;

@end
