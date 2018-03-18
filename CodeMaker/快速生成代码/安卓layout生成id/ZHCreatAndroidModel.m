#import "ZHCreatAndroidModel.h"

@implementation ZHCreatAndroidModel
- (NSString *)getAndroidModelWithParameter:(NSDictionary *)parameter{
    
    NSMutableString *textStrM=[NSMutableString string];
    [textStrM appendFormat:@"//----------对应的Model中的字段-----------\n\n"];
    if (parameter) {//如果含有子控件
        for (NSString *key in parameter) {
            [textStrM appendFormat:@"private String %@;\n\n",parameter[key]];
        }
        for (NSString *key in parameter) {
            [self mySetterGetter:parameter[key] type:@"String" ToSetterGetter:textStrM];
        }
    }
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
