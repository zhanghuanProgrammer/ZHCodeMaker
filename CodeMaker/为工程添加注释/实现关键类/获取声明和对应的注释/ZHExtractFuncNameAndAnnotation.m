#import "ZHExtractFuncNameAndAnnotation.h"
#import "ZHFuncNameAndAnnotation.h"
#import "ZHRemoveTheComments.h"
#import "ZHGetFuncCompressionName.h"

@interface ZHExtractFuncNameAndAnnotation ()
@property (nonatomic,copy)NSString *filterText;
@property (nonatomic,strong)NSArray *funcNamesSortByRange;
@property (nonatomic,strong)NSMutableDictionary *annotationDicM;
@end

@implementation ZHExtractFuncNameAndAnnotation
- (instancetype)initWithFilePath:(NSString *)filePath{
    self = [super init];
    if (self) {
        self.filePath=filePath;
    }
    return self;
}

- (NSMutableDictionary *)annotationDicM{
    if (!_annotationDicM) {
        _annotationDicM=[NSMutableDictionary dictionary];
    }
    return _annotationDicM;
}

/**根据正则表达式获取函数声明*/
- (NSDictionary *)getFuncNameAndAnnotationByRegex{
    NSMutableString *filterText=[NSMutableString stringWithString:[[[ZHFuncNameAndAnnotation alloc]initWithFilePath:self.filePath] removeImplementation]];
    NSMutableArray *removeArr=[NSMutableArray array];
    NSString *regexStr=@"(\\+|-)(\\s)*\\([\\w\\W]*?\\)[\\w\\W]*?;";//匹配.h文件夹里面的函数声明
    NSString *searchText =filterText;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrResult=[regex matchesInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    for (NSTextCheckingResult *result in arrResult) {
        if (result) {
            NSString *key=[searchText substringWithRange:result.range];
            if (![ZHNSString hasTarget:@"//" inTheRow:key]&&![ZHNSString hasTarget:@"}" inTheRow:key]) {
                [dicM setValue:[NSValue valueWithRange:result.range] forKey:key];
            }else{
                [removeArr addObject:key];
            }
        }
    }
    for (NSString *text in removeArr) {
        [filterText setString:[filterText stringByReplacingOccurrencesOfString:text withString:@""]];
    }
    self.filterText=[filterText copy];
    
    if (removeArr.count>0) {
        NSString *searchTextAgain =self.filterText;
        NSRegularExpression *regexAgain = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *arrResult=[regexAgain matchesInString:searchTextAgain options:0 range:NSMakeRange(0, [searchTextAgain length])];
        NSMutableDictionary *dicMAgain=[NSMutableDictionary dictionary];
        for (NSTextCheckingResult *result in arrResult) {
            if (result) {
                [dicMAgain setValue:[NSValue valueWithRange:result.range] forKey:[searchTextAgain substringWithRange:result.range]];
            }
        }
        return dicMAgain;
    }
    
    return dicM;
}

- (NSString *)filterText{
    return _filterText;
}

/**将函数声明的函数名和对应的range根据range排序*/
- (NSArray *)getFuncNamesSortByRange{
    if (self.funcNamesSortByRange.count>0) {
        return self.funcNamesSortByRange;
    }
    NSDictionary *dic=[self getFuncNameAndAnnotationByRegex];
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *key in dic) {
        [arrM addObject:[NSDictionary dictionaryWithObject:dic[key] forKey:key]];
    }
    [arrM sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dic1=obj1,*dic2=obj2;
        NSRange range1=NSMakeRange(0, 0),range2=NSMakeRange(0, 0);
        if ([dic1 allKeys].count>0) range1=[[dic1 allValues][0] rangeValue];
        if ([dic2 allKeys].count>0) range2=[[dic2 allValues][0] rangeValue];
        return range1.location>range2.location;
    }];
    self.funcNamesSortByRange=arrM;
    return arrM;
}

/**过滤不带带有注释的函数名*/
- (void)removeNoAnnotationFuncName{
    NSArray *arr=[self getFuncNamesSortByRange];
    NSString *text=self.filterText;
    NSDictionary *dicMid,*dicPre;
    for (NSInteger i=0; i<arr.count; i++) {
        dicMid=arr[i];
        NSRange rangeMid=[[dicMid allValues][0] rangeValue];
        NSString *keyMid=[dicMid allKeys][0];
        if (i==0) {
            [self addAnnotation:[text substringWithRange:NSMakeRange(0, rangeMid.location)] key:keyMid];
        }else{
            if (i-1>=0) dicPre=arr[i-1];
            NSRange rangePre=[[dicPre allValues][0] rangeValue];
            if(rangeMid.location-(rangePre.location+rangePre.length)>0)
                [self addAnnotation:[text substringWithRange:NSMakeRange(rangePre.location+rangePre.length, rangeMid.location-(rangePre.location+rangePre.length))] key:keyMid];
        }
    }
}

- (void)addAnnotation:(NSString *)containAnnotationText key:(NSString *)key{
    NSString *annotation=[self getAnnotationFromText:containAnnotationText];
    if (annotation.length>0) {
        [self.annotationDicM setValue:annotation forKey:[ZHGetFuncCompressionName getFuncCompressionName:key]];
    }
}

/**防止.h中,第一个函数定义或者函数定义写在@property的两个属性之间*/
- (NSString *)removeProperty:(NSString *)text{
    if ([text rangeOfString:@"@property"].location==NSNotFound) {
        return text;
    }
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    for (NSInteger i=arr.count-1; i>=0; i--) {
        NSString *str=arr[i];
        if ([str hasPrefix:@"@property"]||[str hasPrefix:@"//@property"]) {
            break;
        }else{
            [arrM addObject:str];
        }
    }
    [arrM reverse];
    return [arrM componentsJoinedByString:@"\n"];
}
/**防止.h中,第一个函数定义之间是{成员变量}*/
- (NSString *)removeMembers:(NSString *)text{
    if ([text rangeOfString:@"}"].location==NSNotFound) {
        return text;
    }
    //去找前面函数的}结尾花括号
    NSInteger endIndex=[[ZHFuncNameAndAnnotation new] getEndFuncIndex:text rangeLocation:text.length stopIndex:0];
    if (endIndex!=-1&&endIndex>=0&&endIndex<(text.length-1)) {
        return [text substringWithRange:NSMakeRange(endIndex, text.length-endIndex)];
    }
    return text;
}

- (NSString *)getAnnotationFromText:(NSString *)text{
    
    text=[self removeProperty:text];
    text=[self removeMembers:text];
    if([text rangeOfString:@"//"].location==NSNotFound&&[text rangeOfString:@"/*"].location==NSNotFound)
        return @"";
    
    NSMutableArray *annotations=[NSMutableArray array];
    [ZHRemoveTheComments removeAllComments:text saveAnnotations:annotations];
    
    #if 0
    {
    //下面是使用正则来获取注释,但是第一,准确度不高(不确定是什么时候),而且回溯长,导致效率慢,但是简洁
//    NSString *regexStr=@"(\".*?\")|((/{2,}).*?(\\r|\\n))|(/\\*[\\w\\W]*\\*/)";
//    NSString *searchText = text;
//    searchText=[searchText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"(((("];
//    searchText=[searchText stringByReplacingOccurrencesOfString:@"\\\n" withString:@"))))"];//注意这个替换是必要的,因为有些字符串用\来连接
//    
//    NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
//    NSArray *arrResult=[regex matchesInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
//    NSMutableArray *annotations=[NSMutableArray array];
//    for (NSTextCheckingResult *result in arrResult) {
//        if (result) {
//            if ([[searchText substringWithRange:result.range]hasPrefix:@"\""]==NO) {
//                [annotations addObject:[searchText substringWithRange:result.range]];
//            }
//        }
//    }
    }
    #endif
    
    if (annotations.count>0) {
        return [annotations componentsJoinedByString:@"\n"];
    }
    return @"";
}

@end
