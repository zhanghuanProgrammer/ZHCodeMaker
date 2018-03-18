#import "ZHAndroidModel.h"

@implementation ZHAndroidModel
- (NSString *)getAndroidModelWithModelName:(NSString *)modelName package:(NSString *)package fileDirector:(NSString *)fileDirector WithParameter:(NSDictionary *)parameter{
    
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"package %@.%@;",package,fileDirector],@""] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[
                                   [NSString stringWithFormat:@"/**\n\
                                    * Created by mac on %@.\n\
                                    */",[DateTools currentDate_yyyy_MM_dd]],
                                   [NSString stringWithFormat:@"public class %@Model {\n",modelName]] ToStrM:textStrM];
    
    if (parameter) {//如果含有子控件
        for (NSString *key in parameter) {
            NSString *values=parameter[key];
            NSArray *arrValues=[values componentsSeparatedByString:@","];
            if ([self judge:values]) {
                for (NSString *value in arrValues) {
                    [textStrM appendFormat:@"private String %@;\n\n",value];
                }
            }
        }
        for (NSString *key in parameter) {
            NSString *values=parameter[key];
            NSArray *arrValues=[values componentsSeparatedByString:@","];
            if ([self judge:values]) {
                for (NSString *value in arrValues) {
                    [self mySetterGetter:value type:@"String" ToSetterGetter:textStrM];
                }
            }
        }
    }
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    return textStrM;
}
- (void)mySetterGetter:(NSString *)tempStr type:(NSString *)type ToSetterGetter:(NSMutableString *)setterGetter {
    [setterGetter appendFormat:@"public %@ get%@(){\n\
     return this.%@;\n\
     }\n\
     public void set%@(%@ %@){\n\
     this.%@ = %@;\n\
     }\n\n",type,[ZHNSString upFirstCharacter:tempStr],tempStr,[ZHNSString upFirstCharacter:tempStr],type,[ZHNSString lowerFirstCharacter:tempStr],tempStr,[ZHNSString lowerFirstCharacter:tempStr]];
}
@end
