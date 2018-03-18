#import "ZHFunToRedition.h"

@implementation ZHFunToRedition

- (void)Begin:(NSString *)str{
    str=[ZHNSString removeSpacePrefix:str];
    str=[ZHNSString removeSpaceSuffix:str];
    if ([ZHFileManager fileExistsAtPath:str]) {
        NSString *text=[CodeAssistantFileManager getOtherFileContent:str];
        [self saveData:[self funToRedition:text]];
    }
}

//3.生成方法声明
- (NSString *)funToRedition:(NSString *)text{
    NSString *input=text;
    unichar ch;
    
    NSInteger start=-1,end=-1;
    NSInteger count=0;
    for (NSInteger i=0;i<input.length; i++) {
        ch=[input characterAtIndex:i];
        if (ch=='{') {
            if (start==-1) {
                start=i;
            }
            count++;
        }else if (ch=='}'){
            count--;
            if (count==0) {
                end=i;
                
                input=[input stringByReplacingCharactersInRange:NSMakeRange(start, end-start+1) withString:@";"];
                
                i-=(end-start+1);
                start=-1,end=-1;
            }
        }
    }
    input=[input stringByReplacingOccurrencesOfString:@" ;" withString:@";"];
    return input;
}

@end
