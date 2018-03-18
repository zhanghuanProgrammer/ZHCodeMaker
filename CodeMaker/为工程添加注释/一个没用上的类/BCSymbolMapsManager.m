#import "BCSymbolMapsManager.h"


@implementation BCSymbolMapsManager

- (instancetype)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        self.filePath=filePath;
    }
    return self;
}

/**根据路径,获取内容*/
- (NSString *)getFileContent:(NSString *)filePath{
    NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if ([text hasSuffix:@"\n"]) {
        text=[text substringToIndex:text.length-1];
    }
    if (text.length<=0) text=@"";
    return text;
}

/**将后缀为BCSymbolMaps的文件提取里面的内容,主要包括去除掉一些不需要的信息,只获取文件路径和对应文件的类方法和实例方法的缩写函数名*/
- (void)getAllCompressionFuncNameAndRelatedFilePath{
    
    NSString *content=[self getFileContent:self.filePath];
    
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *splits=[content componentsSeparatedByString:@"\n"];
    
    for (NSString *str in splits) {
        if ([str hasPrefix:@"-["]||[str hasPrefix:@"+["]) {
            [arrM addObject:str];
        }else if ([str hasPrefix:@"/"]&&([str hasSuffix:@".h"]||[str hasSuffix:@".m"])&&[ZHFileManager fileExistsAtPath:str]) {
            [arrM addObject:str];
        }
    }
    self.allFuncNames=arrM;
}

/**将后缀为BCSymbolMaps的文件提取里面的内容,主要包括去除掉一些不需要的信息,只获取文件路径和对应文件的成员变量名*/
- (void)getAllPropertyAndRelatedFilePath{
    
    NSString *content=[self getFileContent:self.filePath];
    
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *splits=[content componentsSeparatedByString:@"\n"];
    
    for (NSString *str in splits) {
        if ([str hasPrefix:@"_OBJC_IVAR"]) {
            [arrM addObject:str];
        }else if ([str hasPrefix:@"/"]&&([str hasSuffix:@".h"]||[str hasSuffix:@".m"])&&[ZHFileManager fileExistsAtPath:str]) {
            [arrM addObject:str];
        }
    }
    self.allPropertys=arrM;
}

/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和类方法*/
- (NSDictionary *)getClassCompressionFuncNameAndRelatedFilePath{
    if (self.allFuncNames==nil) [self getAllCompressionFuncNameAndRelatedFilePath];
    NSArray *allFuncNames=self.allFuncNames;
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    NSMutableArray *funcNames=[NSMutableArray array];
    for (NSString *str in allFuncNames) {
        if ([str hasPrefix:@"-["]) continue;
        else if ([str hasPrefix:@"+["])[funcNames addObject:str];
        else if ([str hasPrefix:@"/"]){
            if ([str hasSuffix:@".h"]||[str hasSuffix:@".m"]) {
                NSString *filePath=[str substringToIndex:str.length-2];
                if (funcNames.count>0) {
                    [dicM setValue:funcNames forKey:filePath];
                    funcNames=[NSMutableArray array];
                }
            }
        }
    }
    return dicM;
}

/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和实例方法*/
- (NSDictionary *)getObjectCompressionFuncNameAndRelatedFilePath{
    if (self.allFuncNames==nil) [self getAllCompressionFuncNameAndRelatedFilePath];
    NSArray *allFuncNames=self.allFuncNames;
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    NSMutableArray *funcNames=[NSMutableArray array];
    for (NSString *str in allFuncNames) {
        if ([str hasPrefix:@"+["]) continue;
        else if ([str hasPrefix:@"-["])[funcNames addObject:str];
        else if ([str hasPrefix:@"/"]){
            if ([str hasSuffix:@".h"]||[str hasSuffix:@".m"]) {
                NSString *filePath=[str substringToIndex:str.length-2];
                if (funcNames.count>0) {
                    [dicM setValue:funcNames forKey:filePath];
                    funcNames=[NSMutableArray array];
                }
            }
        }
    }
    return dicM;
}

/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和实例方法(除去成员变量的getter和setter)*/
- (NSDictionary *)getObjectCompressionFuncNameNoContainGetterAndSetterAndRelatedFilePath{
    NSMutableDictionary *dicM=[[ZHJson new] copyMutableDicFromDictionary:[self getObjectCompressionFuncNameAndRelatedFilePath]];
    NSDictionary *propertys=[self getPropertyAndRelatedFilePath];
    for (NSString *key in dicM) {
        if (propertys[key]!=nil) {
            NSArray *subPropertys=propertys[key];
            NSArray *getterAndSetters=getterAndSetterFromPropertys(subPropertys);
            NSMutableArray *funcnames=dicM[key];
            for (NSInteger i=0; i<funcnames.count; i++) {
                if (funcNameContainGetterAndSetters(funcnames[i],getterAndSetters)) {
                    [funcnames removeObjectAtIndex:i];
                    i--;
                }
            }
        }
    }
    return dicM;
}

/**对获取到的函数缩写和路径进行细化处理,获取对应的路径和成员变量名*/
- (NSDictionary *)getPropertyAndRelatedFilePath{
    if (self.allPropertys==nil) [self getAllPropertyAndRelatedFilePath];
    NSArray *allPropertys=self.allPropertys;
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    NSMutableArray *propertys=[NSMutableArray array];
    for (NSString *str in allPropertys) {
        if ([str hasPrefix:@"_OBJC_IVAR"]){
            if ([str rangeOfString:@"._"].location!=NSNotFound) {
                [propertys addObject:[str substringFromIndex:[str rangeOfString:@"._" options:NSBackwardsSearch].location+2]];
            }
        }
        else if ([str hasPrefix:@"/"]){
            if ([str hasSuffix:@".h"]||[str hasSuffix:@".m"]) {
                NSString *filePath=[str substringToIndex:str.length-2];
                if (propertys.count>0) {
                    [dicM setValue:propertys forKey:filePath];
                    propertys=[NSMutableArray array];
                }
            }
        }
    }
    return dicM;
}


#pragma mark - Helpers
static BOOL funcNameContainGetterAndSetters(NSString *funcName,NSArray *getterAndSetters){
    
    for (NSString *getterAndSetter in getterAndSetters) {
        if ([funcName rangeOfString:getterAndSetter].location!=NSNotFound) {
            return YES;
        }
    }
    return NO;
}
static NSArray *getterAndSetterFromPropertys(NSArray *propertys){
    NSMutableArray *getterAndSetters=[NSMutableArray array];
    for (NSString *property in propertys) {
        [getterAndSetters addObject:[NSString stringWithFormat:@" %@",property]];
        [getterAndSetters addObject:[NSString stringWithFormat:@" %@",setterForGetter(property)]];
    }
    return getterAndSetters;
}
/**
 函数功能描述:示例:比如说setAge:   最后得到:age
 传进来一个set:方法名
 */
static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    // (取得中间的变量名)
    //比如说setAge:   最后得到:Age
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    //  (使得第一个字母小写) Age 变 age
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    return key;
}

/**
 函数功能描述:示例:比如说age:   最后得到: setAge:
 传进来一个set:方法名
 */
static NSString * setterForGetter(NSString *getter)
{
    if (getter.length <= 0) {
        return nil;
    }
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *remainingLetters = [getter substringFromIndex:1];
    
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetters];
    
    return setter;
}
@end
