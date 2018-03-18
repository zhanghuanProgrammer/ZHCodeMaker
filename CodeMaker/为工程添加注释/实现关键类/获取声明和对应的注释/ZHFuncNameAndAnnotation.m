#import "ZHFuncNameAndAnnotation.h"

@interface ZHFuncNameAndAnnotation ()
@property (nonatomic,copy)NSString *fileContent;
@property (nonatomic,strong)NSArray *funcNamesSortByRange;
@end

@implementation ZHFuncNameAndAnnotation
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
    
    text=[text stringByReplacingOccurrencesOfString:@"-(" withString:@"- ("];
    text=[text stringByReplacingOccurrencesOfString:@"+(" withString:@"+ ("];
    
    if([self.filePath hasSuffix:@".h"]){
        if ([text rangeOfString:@"\n@interface"].location!=NSNotFound&&[text rangeOfString:@"\n@end"].location!=NSNotFound) {
            NSArray *arr=[ZHNSString getMidStringBetweenLeftString:@"\n@interface " RightString:@"\n@end" withText:text getOne:NO withIndexStart:0 stopString:nil];
            text= [arr componentsJoinedByString:@"\n"];
        }
    }
    else if ([self.filePath hasSuffix:@".m"]||[self.filePath hasSuffix:@".mm"]){
        if ([text rangeOfString:@"\n@implementation"].location!=NSNotFound&&[text rangeOfString:@"\n@end"].location!=NSNotFound) {
            NSArray *arr=[ZHNSString getMidStringBetweenLeftString:@"\n@implementation " RightString:@"\n@end" withText:text getOne:NO withIndexStart:0 stopString:nil];
            text= [arr componentsJoinedByString:@"\n"];
        }
        text=[self removeNullLine:text];
        text=[self dealWithText:text];
    }
    self.fileContent=text;
    return text;
}

/**通过正则获取函数声明的函数名和对应的range*/
- (NSDictionary *)funcNamesByRegex{
    NSString *regexStr=@"(\\+|-)(\\s)*\\([\\w\\W]*?\\)[\\w\\W]*?\\{";
    NSString *searchText =[self getFileContent];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrResult=[regex matchesInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    ZHRepearDictionary *repearDictionary=[ZHRepearDictionary new];
    for (NSTextCheckingResult *result in arrResult) {
        if (result) {
            [repearDictionary setValue:[NSValue valueWithRange:result.range] forKey:[searchText substringWithRange:result.range]];
        }
    }
    return repearDictionary.dicM;
}

/**过滤掉注释中的函数声明的函数名和对应的range*/
- (NSDictionary *)filterFuncNames{
    NSMutableDictionary *dicM=[[ZHJson new] copyMutableDicFromDictionary:[self funcNamesByRegex]];
    NSArray *funcNames=[dicM allKeys];
    NSArray *newFuncNames=[self getRowsSeparatedByLineAndRemoveSpacePrefixSuffix:[self getFileContent]];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(SELF IN %@)",funcNames];
    NSArray *resultArray = [newFuncNames filteredArrayUsingPredicate:filterPredicate];//过滤数组
    
    NSPredicate *filterPredicateNotIn = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",resultArray];
    NSArray *notInKeys = [funcNames filteredArrayUsingPredicate:filterPredicateNotIn];//过滤数组
    [dicM removeObjectsForKeys:notInKeys];
    return dicM;
}

/**将代码所有+() -()之前的空格删除,并且添加到数组中*/
- (NSArray *)getRowsSeparatedByLineAndRemoveSpacePrefixSuffix:(NSString *)text{
    ZHRepeatNSArray *repeatNSArray=[ZHRepeatNSArray new];
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpacePrefix:str];
        if ([tempStr hasPrefix:@"-"]||[tempStr hasPrefix:@"+"]) {
            [repeatNSArray addObject:tempStr];
        }
    }
    return repeatNSArray.arrM;
}

/**将函数声明的函数名和对应的range根据range排序*/
- (NSArray *)getFuncNamesSortByRange{
    if (self.funcNamesSortByRange.count>0) {
        return self.funcNamesSortByRange;
    }
    NSDictionary *dic=[self filterFuncNames];
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *key in dic) {
        [arrM addObject:[NSDictionary dictionaryWithObject:dic[key] forKey:key]];
    }
    [arrM sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dic1=obj1,*dic2=obj2;
        NSRange range1=NSMakeRange(0, 0),range2=NSMakeRange(0, 0);
        if ([dic1 allKeys].count>0) range1=[[dic1 allValues][0] rangeValue];
        if ([dic2 allKeys].count>0) range2=[[dic2 allValues][0] rangeValue];
        return range1.location<range2.location;
    }];
    self.funcNamesSortByRange=arrM;
    return arrM;
}
- (NSString *)removeImplementation{
    if([self.filePath hasSuffix:@".h"]){
        [self getFileContent];
        return self.fileContent;
    }
    
    NSArray *arr=[self getFuncNamesSortByRange];
    NSMutableString *text=[NSMutableString stringWithString:self.fileContent];
    NSDictionary *dicMid,*dicPre;
    for (NSInteger i=0; i<arr.count; i++) {
        dicMid=arr[i];
        NSRange rangeMid=[[dicMid allValues][0] rangeValue];
        if (i==0) {
            if(text.length-(rangeMid.location+rangeMid.length)>0)
                [text replaceCharactersInRange:NSMakeRange(rangeMid.location+rangeMid.length-1, text.length-(rangeMid.location+rangeMid.length)+1) withString:@";"];
        }else{
            
            if (i-1>=0) dicPre=arr[i-1];
            NSRange rangeNext=[[dicPre allValues][0] rangeValue];
            //去找前面函数的}结尾花括号
            NSInteger endIndex=[self getEndFuncIndex:text rangeLocation:rangeNext.location stopIndex:rangeMid.location+rangeMid.length];
            if (endIndex!=-1&&endIndex>=0&&endIndex<(text.length-1)) {
                if(endIndex-(rangeMid.location+rangeMid.length)>0)
                    [text replaceCharactersInRange:NSMakeRange(rangeMid.location+rangeMid.length-1, endIndex-(rangeMid.location+rangeMid.length)+2) withString:@";"];
            }
        }
    }
    return text;
}

- (NSInteger)getEndFuncIndex:(NSString *)text rangeLocation:(NSInteger)rangeLocation stopIndex:(NSInteger)stopIndex{
    NSInteger index=[text rangeOfString:@"}" options:NSBackwardsSearch range:NSMakeRange(0, rangeLocation)].location;
    if (index==NSNotFound||index<=stopIndex)
        return -1;
    //判断}是否在/**/里
    NSString *tempStr=[text substringWithRange:NSMakeRange(index, rangeLocation-index)];
    NSInteger countAnnotationBegin=[ZHNSString getCountTargetString:@"/*" inText:tempStr];
    NSInteger countAnnotationEnd=[ZHNSString getCountTargetString:@"*/" inText:tempStr];
    if (countAnnotationEnd>countAnnotationBegin) {//说明在/**/里
        return [self getEndFuncIndex:text rangeLocation:index-1 stopIndex:stopIndex];
    }
    //判断}是否在//里
    if([ZHNSString hasTarget:@"//" inTheRow:[text substringWithRange:NSMakeRange(0, index+1)]]){
        return [self getEndFuncIndex:text rangeLocation:index-1 stopIndex:stopIndex];
    }
    return index;
}

- (NSString *)removeNullLine:(NSString *)text{
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        NSString *newStr=[ZHNSString removeSpacePrefix:[ZHNSString removeSpaceSuffix:str]];
        if (newStr.length>0) {
            [arrM addObject:str];
        }
    }
    return [arrM componentsJoinedByString:@"\n"];
}

- (NSString *)dealWithText:(NSString *)text{
    NSMutableArray *arrM=[NSMutableArray array];
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    for (NSInteger i=0; i<arr.count; i++) {
        NSString *str=arr[i];
        NSMutableString *tempStrM=[NSMutableString stringWithString:[ZHNSString removeSpacePrefix:[ZHNSString removeSpaceSuffix:str]]];
        if ([tempStrM hasPrefix:@"- ("]||[tempStrM hasPrefix:@"+ ("]) {
            if ([tempStrM hasSuffix:@"{"]) {
                [arrM addObject:tempStrM];
            }else{
                if (i+1<arr.count) {
                    NSString *strNext=arr[i+1];
                    strNext=[ZHNSString removeSpacePrefix:strNext];
                    if ([strNext hasSuffix:@"{"]) {
                        strNext=[strNext substringFromIndex:1];
                        [tempStrM appendString:@"{"];
                        [arrM addObject:tempStrM];
                        [arrM addObject:strNext];
                        i++;
                    }
                }else{
                    [arrM addObject:tempStrM];
                }
            }
        }else{
            [arrM addObject:str];
        }
    }
    return [arrM componentsJoinedByString:@"\n"];
}

@end
