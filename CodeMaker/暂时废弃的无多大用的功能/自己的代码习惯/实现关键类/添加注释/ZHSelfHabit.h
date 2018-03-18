#import "CreatFatherFile.h"

@interface ZHSelfHabit : CreatFatherFile

/**自己的习惯注释*/
+ (void)selfHabitAnnotationForVC:(UIViewController *)vc;

/**添加习惯注释到代码文件中*/
+ (void)addSelfHabitAnnotation:(NSString *)filePath;

@end
