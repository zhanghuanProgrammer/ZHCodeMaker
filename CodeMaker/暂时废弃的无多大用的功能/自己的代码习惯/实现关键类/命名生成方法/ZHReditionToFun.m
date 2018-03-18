#import "ZHReditionToFun.h"

@implementation ZHReditionToFun

- (void)Begin:(NSString *)str{
    str=[ZHNSString removeSpacePrefix:str];
    str=[ZHNSString removeSpaceSuffix:str];
    if ([ZHFileManager fileExistsAtPath:str]) {
        NSString *text=[CodeAssistantFileManager getOtherFileContent:str];
        [self saveData:[self fun2:text]];
    }
}

//2.生成方法体结构
- (NSString *)fun2:(NSString *)input{
    
    unichar ch;
    
    input=[input stringByReplacingOccurrencesOfString:@";" withString:@"{\n}\n"];
    for (NSInteger i=0;i<input.length; i++) {
        ch=[input characterAtIndex:i];
        if (ch=='-'||ch=='+') {
            //1.判断是不是在注释里面
            
            unichar chTemp;
            for (NSInteger j=i-1;j>0; j--) {
                chTemp=[input characterAtIndex:j];
                if (chTemp=='\n') {
                    break;
                }else{
                    if (chTemp=='/') {
                        if (j>0) {
                            chTemp=[input characterAtIndex:j-1];
                            if (chTemp=='/') {
                                break;
                            }
                        }
                    }
                }
            }
            
            //2.拿取括号里面的字符串
            NSInteger leftKuoHao,rightKuoHao,HuaKuoHao;
            leftKuoHao=[input rangeOfString:@"(" options:NSCaseInsensitiveSearch range:NSMakeRange(i+1, input.length-i-1)].location;
            rightKuoHao=[input rangeOfString:@")" options:NSCaseInsensitiveSearch range:NSMakeRange(i+1, input.length-i-1)].location;
            
            HuaKuoHao=[input rangeOfString:@"{" options:NSCaseInsensitiveSearch range:NSMakeRange(i+1, input.length-i-1)].location;
            
            if (leftKuoHao!=NSNotFound&&rightKuoHao!=NSNotFound) {
                NSString *content=[input substringWithRange:NSMakeRange(leftKuoHao+1, rightKuoHao-leftKuoHao-1)];
                if ([content hasSuffix:@"*"]) {
                    content=[self removeSpace:content];
                }
                input =[input stringByReplacingCharactersInRange:NSMakeRange(HuaKuoHao, 1) withString:[@"{\n\t" stringByAppendingString:[self returnString:content]]];
            }else{
                NSLog(@"有严重BUG");
            }
        }
    }
    
    return input;
}
- (NSString *)returnString:(NSString *)content{
    NSArray *arrNoObject=@[@"BOOL",@"double",@"long long",@"float",@"CGFloat",@"bool",@"int",@"long"];
    if ([arrNoObject containsObject:content]) {
        return @"return 0;";
    }
    if ([content isEqualToString:@"void"]) {
        return @"";
    }
    return @"return nil;";
}
- (NSString *)removeSpace:(NSString *)text{
    if ([text hasPrefix:@" "]) {
        text=[text substringFromIndex:1];
        return [self removeSpace:text];
    }
    if ([text hasSuffix:@" "]) {
        text=[text substringToIndex:text.length-1];
        return [self removeSpace:text];
    }
    if ([text rangeOfString:@"\t"].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        return [self removeSpace:text];
    }
    if ([text hasSuffix:@"*"]) {
        text=[text substringToIndex:text.length-1];
        return [self removeSpace:text];
    }
    return text;
}
@end
