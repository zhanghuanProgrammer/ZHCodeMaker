#import "ZHGetFunctionCall.h"

@interface ZHGetFunctionCall ()
@property (nonatomic,copy)NSString *fileContent;
@end

@implementation ZHGetFunctionCall

- (instancetype)initWithFilePath:(NSString *)filePath{
    self = [super init];
    if (self) {
        self.filePath=filePath;
    }
    return self;
}

/**根据路径,获取内容*/
- (NSString *)getFileContent{
    if (self.fileContent.length>0) {
        return self.fileContent;
    }
    NSString *text=[NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
    if ([text hasSuffix:@"\n"]) {
        text=[text substringToIndex:text.length-1];
    }
    if (text.length<=0) text=@"";
    self.fileContent=text;
    return text;
}

/**往某个文件里添加注释*/
- (ZHRepearDictionary *)addAnnotation{
    if([self.filePath hasSuffix:@".h"]){
        return nil;
    }
    ZHRepearDictionary *dicM=[ZHRepearDictionary new];
    /**保存正常的函数调用(在一行中)*/
    [self saveGetFunctionCall:@"\\[.*?\\];" toDicM:dicM];
    /**保存条件判断中的函数调用*/
    [self saveGetFunctionCall:@"\\[.*?\\].*?\\)" toDicM:dicM];
    /**保存正常的函数调用(]后面接的是},比如当做value值放在字典中)*/
    [self saveGetFunctionCall:@"\\[.*?\\]\\}" toDicM:dicM];
    /**保存正常的函数调用(在一行中,但是出现[obj new].属性调用)*/
    [self saveGetFunctionCall:@"\\[.*?\\].*?\\;" toDicM:dicM];
    /**保存正常的函数调用(在多行中)*/
    [self saveGetFunctionCall:@"\\[[\\w\\W]*?\\];" toDicM:dicM];
    /**保存正常的函数调用(在一行中,最后一击,不需要]的匹配了)*/
    [self saveGetFunctionCall:@"\\[.*?" toDicM:dicM];
    
    return dicM;
}

- (void)saveGetFunctionCall:(NSString *)regexStr toDicM:(ZHRepearDictionary *)dicM{
    NSString *searchText = [self getFileContent];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrResult=[regex matchesInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    NSMutableArray *arrMRange=[NSMutableArray array];
    for (NSTextCheckingResult *result in arrResult) {
        if (result) {
            [dicM setValue:[NSValue valueWithRange:result.range] forKey:[searchText substringWithRange:result.range]];
            [arrMRange addObject:[NSValue valueWithRange:result.range]];
        }
    }
    [arrMRange sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSRange range1=[obj1 rangeValue],range2=[obj2 rangeValue];
        return range1.location<range2.location;
    }];
    for (NSValue *value in arrMRange) {
        NSRange range=[value rangeValue];
        searchText=[searchText stringByReplacingCharactersInRange:range withString:[self getReplaceStrWithCount:range.length]];
    }
    self.fileContent=searchText;
}

- (NSString *)getReplaceStrWithCount:(NSInteger)count{
    NSMutableString *strM=[NSMutableString string];
    for (NSInteger i=0; i<count; i++) {
        [strM appendString:@"$"];
    }
    return strM;
}

@end
