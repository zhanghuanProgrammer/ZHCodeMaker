#import "FatherClass.h"

@implementation FatherClass
- (void)Begin:(NSString *)str{
    [self saveData:str];
}
- (void)saveData:(NSString *)text{
    if (text.length<=0) {
        text=@"";
    }
    [ZHBlockSingleCategroy defaultMyblock][@"value"]=text;
}
- (NSString *)description{
    return @"你还没有对你的类进行方法描述";
}

@end
