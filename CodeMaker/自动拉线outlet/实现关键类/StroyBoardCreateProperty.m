#import "StroyBoardCreateProperty.h"
#import "StroyBoardPropertySetValue.h"
#import "StroyBoardCreateConstant.h"

static NSMutableDictionary *ZHStroyBoardCreateProperty;
static NSMutableDictionary *ZHStroyBoardCreateCategory;
static NSMutableDictionary *ZHStroyBoardCreateId;
static NSMutableDictionary *ZHStroyBoardCreateFile;
static NSMutableDictionary *ZHStroyBoardCreateContent;
static NSMutableDictionary *ZHStroyBoardCreateReuse;

static NSMutableArray *ZHPushCellFileName;
static NSMutableArray *ZHPushTempCellName;
static NSMutableArray *ZHPushTempControllerName;

static NSString *ZHProjectPath;

static NSInteger customCount;

@interface StroyBoardCreateProperty ()

@end

@implementation StroyBoardCreateProperty


#pragma mark 懒加载
+ (NSMutableDictionary *)defalutCreateProperty{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStroyBoardCreateProperty==nil) {
            ZHStroyBoardCreateProperty=[NSMutableDictionary dictionary];
        }
    });
    return ZHStroyBoardCreateProperty;
}
+ (NSMutableDictionary *)defalutCreateCategory{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStroyBoardCreateCategory==nil) {
            ZHStroyBoardCreateCategory=[NSMutableDictionary dictionary];
        }
    });
    return ZHStroyBoardCreateCategory;
}
+ (NSMutableDictionary *)defalutCreateFile{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStroyBoardCreateFile==nil) {
            ZHStroyBoardCreateFile=[NSMutableDictionary dictionary];
        }
    });
    return ZHStroyBoardCreateFile;
}
+ (NSMutableDictionary *)defalutCreateContent{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStroyBoardCreateContent==nil) {
            ZHStroyBoardCreateContent=[NSMutableDictionary dictionary];
        }
    });
    return ZHStroyBoardCreateContent;
}
+ (NSMutableDictionary *)defalutCreateId{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStroyBoardCreateId==nil) {
            ZHStroyBoardCreateId=[NSMutableDictionary dictionary];
        }
    });
    return ZHStroyBoardCreateId;
}
+ (NSMutableDictionary *)defalutCreateReuse{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHStroyBoardCreateReuse==nil) {
            ZHStroyBoardCreateReuse=[NSMutableDictionary dictionary];
        }
    });
    return ZHStroyBoardCreateReuse;
}
+ (NSMutableArray *)defalutCellFileName{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHPushCellFileName==nil) {
            ZHPushCellFileName=[NSMutableArray array];
        }
    });
    return ZHPushCellFileName;
}
+ (NSMutableArray *)defalutTempCellName{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHPushTempCellName==nil) {
            ZHPushTempCellName=[NSMutableArray array];
        }
    });
    return ZHPushTempCellName;
}
+ (NSMutableArray *)defalutTempControllerName{
    //添加线程锁
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ZHPushTempControllerName==nil) {
            ZHPushTempControllerName=[NSMutableArray array];
        }
    });
    return ZHPushTempControllerName;
}

+ (NSString *)getConstantTypeFromFirstAttribute:(NSString *)firstAttribute{
    if ([firstAttribute isEqualToString:@"top"]) {
        return @"t";
    }
    if ([firstAttribute isEqualToString:@"bottom"]) {
        return @"b";
    }
    if ([firstAttribute isEqualToString:@"leading"]) {
        return @"l";
    }
    if ([firstAttribute isEqualToString:@"trailing"]) {
        return @"r";
    }
    if ([firstAttribute isEqualToString:@"width"]) {
        return @"w";
    }
    if ([firstAttribute isEqualToString:@"height"]) {
        return @"h";
    }
    if ([firstAttribute isEqualToString:@"centerX"]) {
        return @"x";
    }
    if ([firstAttribute isEqualToString:@"centerY"]) {
        return @"y";
    }
    return @"";
}

+ (NSDictionary *)getConstantTypeAndIds:(NSDictionary *)ConstantDic{
    if (ConstantDic==nil) {
        return nil;
    }
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    for (NSString *key in ConstantDic) {
        
        NSArray *arrTemp=ConstantDic[key];
        NSMutableArray *arrM=[NSMutableArray array];
        
        for (NSDictionary *dicTemp in arrTemp) {
            if (dicTemp!=nil) {
                NSString *type=[self getConstantTypeFromFirstAttribute:dicTemp[@"firstAttribute"]];
                if (type.length>0) {
                    [arrM addObject:type];
                }
            }
        }
        
        [dicM setValue:arrM forKey:key];
    }
    
    return dicM;
}

+ (void)repalceViewToViewController:(NSString *)stroyBoardPath{
    NSString *fileName = [ZHFileManager getFileNameNoPathComponentFromFilePath:stroyBoardPath];
    NSString *textOrginal=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    BOOL isXib = [textOrginal rangeOfString:@"CocoaTouch.XIB"].location != NSNotFound;
    if(isXib){
        NSInteger count = -1;
        NSArray *arr = [textOrginal componentsSeparatedByString:@"\n"];
        NSMutableArray *arrM = [NSMutableArray array];
        for (NSString *str in arr) {
            NSString *replaceStr = str;
            NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
            tempStr = [ZHNSString removeSpacePrefix:tempStr];
            tempStr = [ZHNSString removeSpaceSuffix:tempStr];
            if ([tempStr hasPrefix:@"<view "]) {
                if ([tempStr rangeOfString:@"customClass=\""].location!=NSNotFound) {
                    NSString *customClass = [tempStr substringFromIndex:[tempStr rangeOfString:@"customClass=\""].location+@"customClass=\"".length];
                    customClass = [customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                    if ([fileName isEqualToString:customClass]) {
                        count = 0;
                        replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@"<view " withString:@"<viewController "];
                    }
                }
                if(count>=0)count++;
            }
            if ([tempStr hasPrefix:@"</view>"]) {
                if (count==1) {
                    replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@"</view>" withString:@"</viewController>"];
                    count=-1;
                }
                count--;if(count<0)count=-1;
            }
            [arrM addObject:replaceStr];
        }
        [[arrM componentsJoinedByString:@"\n"] writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (void)repalceViewControllerToView:(NSString *)stroyBoardPath{
    NSString *fileName = [ZHFileManager getFileNameNoPathComponentFromFilePath:stroyBoardPath];
    NSString *textOrginal=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    BOOL isXib = [textOrginal rangeOfString:@"CocoaTouch.XIB"].location != NSNotFound;
    if(isXib){
        NSInteger count = -1;
        NSArray *arr = [textOrginal componentsSeparatedByString:@"\n"];
        NSMutableArray *arrM = [NSMutableArray array];
        for (NSString *str in arr) {
            NSString *replaceStr = str;
            NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
            tempStr = [ZHNSString removeSpacePrefix:tempStr];
            tempStr = [ZHNSString removeSpaceSuffix:tempStr];
            if ([tempStr hasPrefix:@"<viewController "]) {
                if ([tempStr rangeOfString:@"customClass=\""].location!=NSNotFound) {
                    NSString *customClass = [tempStr substringFromIndex:[tempStr rangeOfString:@"customClass=\""].location+@"customClass=\"".length];
                    customClass = [customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                    if ([fileName isEqualToString:customClass]) {
                        count = 0;
                        replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@"<viewController " withString:@"<view "];
                    }
                }
                if(count>=0)count++;
            }
            if ([tempStr hasPrefix:@"</viewController>"]) {
                if (count==1) {
                    replaceStr = [replaceStr stringByReplacingOccurrencesOfString:@"</viewController>" withString:@"</view>"];
                    count=-1;
                }
                count--;if(count<0)count=-1;
            }
            [arrM addObject:replaceStr];
        }
        [[arrM componentsJoinedByString:@"\n"] writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (NSInteger)createPropertyWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    
    if ([ZHFileManager fileExistsAtPath:stroyBoardPath]==NO||[ZHFileManager fileExistsAtPath:projectPath]==NO) {
        return -1;
    }
    ZHProjectPath=projectPath;
    
    [self repalceViewToViewController:stroyBoardPath];
    
    //开始备份一份StroyBoard
//    [self backupNewStroyBoard:stroyBoardPath];//还是不备份了
    
    NSMutableDictionary *resultDicM=[NSMutableDictionary dictionary];
    [[StroyBoardCreateConstant new]getConstant:stroyBoardPath toConstantDicM:resultDicM];
    
    NSDictionary *useConstantIdDic=[self getConstantTypeAndIds:resultDicM];
    
    //开始查找出自定义属性
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    
    customCount=0;
    
    text=[self getCustomClassFromAllViews:text withUseConstantIdDic:useConstantIdDic];
    
    [[self defalutCellFileName]removeAllObjects];
    
    NSInteger count=[self defalutCreateCategory].count;
    
    if (count==0&&customCount==0) {
        [self repalceViewControllerToView:stroyBoardPath];
        return 0;
    }
    
    text=[self addOutletProperty:text withUseConstantIdDic:useConstantIdDic withResultDicM:resultDicM];
    
    text=[self removeTempCustomClass:text];
    
    NSArray *files=[ZHFileManager subPathFileArrInDirector:projectPath hasPathExtension:@[@".m"]];
    
    for (NSString *fileName in [self defalutCreateProperty]) {
        for (NSString *realFileName in files) {
            NSString *tempFileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:realFileName];
            if ([tempFileName isEqualToString:fileName]) {
                [[self defalutCreateFile]setValue:realFileName forKey:fileName];
                [[self defalutCreateContent]setValue:[NSMutableString stringWithString:[NSString stringWithContentsOfFile:realFileName encoding:NSUTF8StringEncoding error:nil]] forKey:realFileName];
                break;
            }
        }
    }
    //开始真正的插入代码
    [self insertCode];
    
    //这个要放在最后面在运行,因为如果这个StroyBoard是XCode正在打开的文件,那么一旦改变,Xcode会重新加载一遍,StroyBoard文件比较大,加载时间会有点长,导致有点卡,担心影响执行再下面的代码
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self repalceViewControllerToView:stroyBoardPath];
    
    [self done];
    customCount=0;
    return count;
}

+ (NSString *)setProperty:(NSString *)property forKey:(NSString *)key{
    NSString *returnStr=@"";
    if ([self defalutCreateReuse][key]==nil) {
        [self defalutCreateReuse][key]=[NSNumber numberWithInteger:0];
        [[self defalutCreateId]setValue:property forKey:key];
        returnStr=key;
        return returnStr;
    }else{
        NSNumber *num=[self defalutCreateReuse][key];
        NSInteger tempValue=[num integerValue];
        tempValue++;
        [self defalutCreateReuse][key]=[NSNumber numberWithInteger:tempValue];
        [[self defalutCreateId]setValue:property forKey:[key stringByAppendingFormat:@"(&$&)%ld",tempValue]];
        returnStr=[key stringByAppendingFormat:@"(&$&)%ld",tempValue];
        return returnStr;
    }
    return returnStr;
}
+ (NSString *)getRealKey:(NSString *)key{
    NSString *result=key;
    if (result.length<=0) {
        return @"";
    }
    if ([result rangeOfString:@"(&$&)"].location!=NSNotFound) {
        return [result substringToIndex:[result rangeOfString:@"(&$&)"].location];
    }
    return result;
}
+ (NSString *)removeSpaceSuffix:(NSString *)text{
    if ([text hasSuffix:@" "]) {
        text=[text substringToIndex:text.length-1];
        return [self removeSpaceSuffix:text];
    }
    else return text;
}

/**去除临时的标识符*/
+ (NSString *)removeTempCustomClass:(NSString *)text{
    for (NSString *cellName in [self defalutTempCellName]) {
        text=[text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" customClass=\"%@\">",cellName] withString:@">"];
    }
    for (NSString *controllerName in [self defalutTempControllerName]) {
        text=[text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" customClass=\"%@\">",controllerName] withString:@">"];
    }
    return text;
}
/**判断是否是约束*/
+ (BOOL)isConstain:(NSString *)text{
    if (text.length>2) {
        unichar ch=[text characterAtIndex:1];
        if (ch=='_') {
            return YES;
        }
    }
    return NO;
}
/**拿取约束类型*/
+ (NSString *)getConstainType:(NSString *)text{
    if (text.length>2) {
        unichar ch=[text characterAtIndex:1];
        if (ch=='_') {
            ch=[text characterAtIndex:0];
            NSString *constainType=[NSString stringWithFormat:@"%C",ch];
            constainType=[constainType lowercaseString];
            ch=[constainType characterAtIndex:0];
            if(ch=='w'||ch=='h'||ch=='t'||ch=='b'||ch=='l'||ch=='r'||ch=='x'||ch=='y'){
                return constainType;
            }
        }
    }
    return @"";
}

+ (NSString *)getValueWithConstantType:(NSString *)constantType withIds:(NSString *)ids withResultDicM:(NSDictionary *)resultDicM{
    if (resultDicM[ids]!=nil) {
        NSArray *arr=resultDicM[ids];
        for (NSDictionary *dicTemp in arr) {
            if (dicTemp!=nil) {
                
                NSString *type=[self getConstantTypeFromFirstAttribute:dicTemp[@"firstAttribute"]];
                
                if ([type isEqualToString:constantType]) {
                    return dicTemp[@"id"];
                }
            }
        }
    }
    return @"";
}

/**获取所有控件自己打上的标识符*/
+ (NSString *)getCustomClassFromAllViews:(NSString *)text withUseConstantIdDic:(NSDictionary *)useConstantIdDic{
    NSArray *allIds=[useConstantIdDic allKeys];
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM=[NSMutableArray array];
    NSString *rowStr,*viewIdenity;
    NSString *ViewControllerFileName=@"noExsit",*CellFileName=@"noExsit";  //要么是ViewController 要么是tableViewCell或者collectionViewCell
    
    for (NSInteger i=0; i<arr.count; i++) {
        rowStr=arr[i];
        
        viewIdenity=[ZHStoryboardTextManager isView:rowStr];
        
        //如果这一行代表的是控件
        if (viewIdenity.length>0) {
            if ([viewIdenity isEqualToString:@"<view "]&&i>0&&([arr[i-1] rangeOfString:@"key=\""].location!=NSNotFound||[arr[i-1] rangeOfString:@"</layoutGuides>"].location!=NSNotFound)) {
                
                //为了后面好设置约束,需要将这类view的id值设成特殊可识别的标识符
                //取出id值
                if ([rowStr rangeOfString:@"customClass=\""].location!=NSNotFound) {
                    NSString *customStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                    customStr=[customStr substringToIndex:[customStr rangeOfString:@"\""].location];
                    
                    if ([customStr hasPrefix:@"_"]) {
                        
                        NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                        idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                        
                        NSString *tempCustomStr=[self setProperty:idStr forKey:customStr];
                        
                        [self addCustomClassProperty:tempCustomStr withCellFileName:CellFileName withViewControllerFileName:ViewControllerFileName];
                        [[self defalutCreateCategory]setValue:[viewIdenity substringFromIndex:1] forKey:tempCustomStr];
                        /**< <label <button <imageView*/
                        
                        NSString *removeCustom=[NSString stringWithFormat:@" customClass=\"%@\"",customStr];
                        [arrM addObject:[rowStr stringByReplacingOccurrencesOfString:removeCustom withString:@""]];
                        
                        continue;
                    }else if ([self isConstain:customStr]){//如果是约束
                        NSString *constainType=[self getConstainType:customStr];
                        
                        if (constainType.length==1) {
                            NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                            idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                            
                            if([allIds containsObject:idStr]==YES){
                                
                                NSArray *arr=useConstantIdDic[idStr];
                                if ([arr containsObject:constainType]) {
                                    
                                    NSString *tempCustomStr=[self setProperty:idStr forKey:customStr];
                                    
                                    [self addCustomClassProperty:tempCustomStr withCellFileName:CellFileName withViewControllerFileName:ViewControllerFileName];
                                    [[self defalutCreateCategory]setValue:[viewIdenity substringFromIndex:1] forKey:tempCustomStr];//<view <label <button <imageView
                                    
                                }
                            }
                            
                            customCount ++;
                            NSString *removeCustom=[NSString stringWithFormat:@" customClass=\"%@\"",customStr];
                            [arrM addObject:[rowStr stringByReplacingOccurrencesOfString:removeCustom withString:@""]];
                            continue;
                        }
                    }
                }
            }
            
            //判断是不是Cell
            if ([self isCell:rowStr]) {
                NSString *customClass;
                if ([rowStr rangeOfString:@"customClass=\""].location!=NSNotFound) {
                    customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                }else{
                    //强行加个临时的customClass
                    customClass=[NSString stringWithFormat:@"&&&$$%ld$$&&&TempCell>",[self defalutTempCellName].count+1];
                    [[self defalutTempCellName] addObject:customClass];
                    rowStr = [self removeSpaceSuffix:rowStr];
                    if ([rowStr hasSuffix:@">"]) {
                        rowStr=[rowStr substringToIndex:rowStr.length-1];
                        rowStr=[rowStr stringByAppendingFormat:@" customClass=\"%@\">",customClass];
                    }
                }
                if (customClass.length>0) {
                    [[self defalutCellFileName]addObject:customClass];
                    CellFileName=customClass;
                }else{
                    CellFileName=@"noExsit";
                }
            }else{
            
                //如果这一行里面有标识符CustomClass
                if ([rowStr rangeOfString:@" customClass=\""].location!=NSNotFound&&[rowStr rangeOfString:@" id=\""].location!=NSNotFound) {
                    NSString *customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                    
                    if ([customClass hasPrefix:@"_"]) {
                        
                        NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                        idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                        
                        NSString *tempCustomStr=[self setProperty:idStr forKey:customClass];
                        [self addCustomClassProperty:tempCustomStr withCellFileName:CellFileName withViewControllerFileName:ViewControllerFileName];
                        [[self defalutCreateCategory]setValue:[viewIdenity substringFromIndex:1] forKey:tempCustomStr];//<view <label <button <imageView
                        
                        NSString *removeCustom=[NSString stringWithFormat:@" customClass=\"%@\"",customClass];
                        [arrM addObject:[rowStr stringByReplacingOccurrencesOfString:removeCustom withString:@""]];
                        
                        continue;
                    }else if ([self isConstain:customClass]){//如果是约束
                        NSString *constainType=[self getConstainType:customClass];
                        
                        if (constainType.length==1) {
                            
                            NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                            idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                            
                            if([allIds containsObject:idStr]==YES){
                                NSArray *arr=useConstantIdDic[idStr];
                                if ([arr containsObject:constainType]) {
                                    NSString *tempCustomStr=[self setProperty:idStr forKey:customClass];
                                    [self addCustomClassProperty:tempCustomStr withCellFileName:CellFileName withViewControllerFileName:ViewControllerFileName];
                                    [[self defalutCreateCategory]setValue:[viewIdenity substringFromIndex:1] forKey:tempCustomStr];//<view <label <button <imageView
                                }
                            }
                            customCount ++;
                            
                            NSString *removeCustom=[NSString stringWithFormat:@" customClass=\"%@\"",customClass];
                            [arrM addObject:[rowStr stringByReplacingOccurrencesOfString:removeCustom withString:@""]];
                            continue;
                        }
                    }
                }
            }
        }
        else{
            
            NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
            if([tempStr hasPrefix:@"<viewController "]){
                NSString *customClass=@"";
                if([tempStr rangeOfString:@" customClass=\""].location!=NSNotFound){
                    customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                }else{
                    //强行加个临时的customClass
                    customClass=[NSString stringWithFormat:@"&&&$$%ld$$&&&ViewController>",[self defalutTempControllerName].count+1];
                    [[self defalutTempControllerName] addObject:customClass];
                    rowStr = [self removeSpaceSuffix:rowStr];
                    if ([rowStr hasSuffix:@">"]) {
                        rowStr=[rowStr substringToIndex:rowStr.length-1];
                        rowStr=[rowStr stringByAppendingFormat:@" customClass=\"%@\">",customClass];
                    }
                }
                if (customClass.length>0) {
                    ViewControllerFileName=customClass;
                }else{
                    ViewControllerFileName=@"noExsit";
                }
            }
            if ([tempStr hasPrefix:@"</viewController>"]) {
                ViewControllerFileName=@"noExsit";
            }
            
            if ([tempStr hasPrefix:@"</tableViewCell"]||[tempStr hasPrefix:@"</collectionViewCell"]) {
                if ([self defalutCellFileName].count>0) {
                    [[self defalutCellFileName]removeLastObject];
                    if ([self defalutCellFileName].count>0) {
                        CellFileName=[[self defalutCellFileName] lastObject];
                    }else
                        CellFileName=@"noExsit";
                }else{
                    CellFileName=@"noExsit";
                }
            }
        }
        [arrM addObject:rowStr];
    }
    
    return [arrM componentsJoinedByString:@"\n"];
}

/**为StroyBoard添加真的outlet property*/
+ (NSString *)addOutletProperty:(NSString *)text withUseConstantIdDic:(NSDictionary *)useConstantIdDic withResultDicM:(NSDictionary *)resultDicM{
    BOOL isXib = [text rangeOfString:@"CocoaTouch.XIB"].location != NSNotFound;
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM=[NSMutableArray array];
    NSString *rowStr,*viewIdenity;
    
    NSArray *cellPropertys,*viewControllerPropertys;
    
    NSInteger isTableViewCell=0;
    
    for (NSInteger i=0; i<arr.count; i++) {
        rowStr=arr[i];
        
        viewIdenity=[ZHStoryboardTextManager isView:rowStr];
        
        //如果这一行代表的是控件
        if (viewIdenity.length>0) {
            //判断是不是Cell
            if ([self isCell:rowStr]) {
                NSString *customClass;
                if ([rowStr rangeOfString:@"customClass=\""].location!=NSNotFound) {
                    customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                }
                if (customClass.length>0) {
                    [[self defalutCellFileName]addObject:customClass];
                    if ([self defalutCreateProperty][customClass]!=nil) {
                        cellPropertys =[self defalutCreateProperty][customClass];
                    }else{
                        cellPropertys=nil;
                    }
                }else{
                    cellPropertys=nil;
                }
                
                if ([rowStr rangeOfString:@"<tableViewCell "].location!=NSNotFound) {
                    isTableViewCell=1;
                    [[self defalutCellFileName]addObject:@"1"];
                }else if([rowStr rangeOfString:@"<collectionViewCell "].location!=NSNotFound){
                    isTableViewCell=2;
                    [[self defalutCellFileName]addObject:@"2"];
                }
            }
        }
        else{
            NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
            if([tempStr hasPrefix:@"<viewController "]){
                if([tempStr rangeOfString:@" customClass=\""].location!=NSNotFound){
                    NSString *customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                    customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                    
                    if (customClass.length>0) {
                        if ([self defalutCreateProperty][customClass]!=nil) {
                            viewControllerPropertys =[self defalutCreateProperty][customClass];
                        }
                    }else{
                        viewControllerPropertys=nil;
                    }
                }
            }
            
            if ([tempStr hasPrefix:@"</tableViewCell>"]) {
                if(isTableViewCell==1){
                    //说明这个cell之前没有拉过约束
                    if (i>0&&[arr[i-1] rangeOfString:@"</connections>"].location==NSNotFound) {
                        NSMutableString *connections=[NSMutableString string];
                        [connections appendString:@"<connections>\n"];
                        
                        NSInteger realInsert=0;
                        for (NSString *property in cellPropertys) {
                            NSString *newProperty=property;
                            newProperty=[self getRealKey:newProperty];
                            
                            NSString *destinationStr=[self defalutCreateId][property];
                            if ([newProperty hasPrefix:@"_"]) {
                                newProperty=[newProperty substringFromIndex:1];
                            }else if ([self isConstain:newProperty]){
                                NSString *constainType=[self getConstainType:newProperty];
                                if (constainType.length==1) {
                                    destinationStr=[self getValueWithConstantType:constainType withIds:[self defalutCreateId][property] withResultDicM:resultDicM];
                                    newProperty=[newProperty substringFromIndex:2];
                                }
                            }
                            
                            if (destinationStr.length<=0) {
                                continue;
                            }
                            
                            NSString *storyBoardIdString=[self getStoryBoardIdString];
                            while ([text rangeOfString:storyBoardIdString].location!=NSNotFound) {
                                storyBoardIdString=[self getStoryBoardIdString];
                            }
                            
                            NSString *outlet=[NSString stringWithFormat:@"<outlet property=\"%@\" destination=\"%@\" id=\"%@\"/>\n",newProperty,destinationStr,storyBoardIdString];
                            
                            if ([ZHNSString getCountLeftString:@"<outlet property=\"" rightString:[NSString stringWithFormat:@"destination=\"%@\"",destinationStr] priorityIsLeft:NO notContainStringArr:@[@"<",@">"] inText:text]==0) {
                                [connections appendString:outlet];
                                realInsert++;
                            }else{
                                [[self defalutCreateId]removeObjectForKey:property];
                                [[self defalutCreateCategory]removeObjectForKey:property];
                            }
                            
                        }
                        [connections appendString:@"</connections>"];
                        if (cellPropertys.count>0&&realInsert>0) {
                            [arrM insertObject:connections atIndex:arrM.count];
                        }
                    }
                    //说明这个cell之前有拉过约束
                    else if(i>0&&[arr[i-1] rangeOfString:@"</connections>"].location!=NSNotFound){
                        for (NSString *property in cellPropertys) {
                            NSString *newProperty=property;
                            newProperty=[self getRealKey:newProperty];
                            NSString *destinationStr=[self defalutCreateId][property];
                            if ([newProperty hasPrefix:@"_"]) {
                                newProperty=[newProperty substringFromIndex:1];
                            }else if ([self isConstain:newProperty]){
                                NSString *constainType=[self getConstainType:newProperty];
                                if (constainType.length==1) {
                                    NSString *constainType=[self getConstainType:newProperty];
                                    if (constainType.length==1) {
                                        destinationStr=[self getValueWithConstantType:constainType withIds:[self defalutCreateId][property] withResultDicM:resultDicM];
                                        newProperty=[newProperty substringFromIndex:2];
                                    }
                                }
                            }
                            
                            if (destinationStr.length<=0) {
                                continue;
                            }
                            NSString *storyBoardIdString=[self getStoryBoardIdString];
                            while ([text rangeOfString:storyBoardIdString].location!=NSNotFound) {
                                storyBoardIdString=[self getStoryBoardIdString];
                            }
                            NSString *outlet=[NSString stringWithFormat:@"<outlet property=\"%@\" destination=\"%@\" id=\"%@\"/>",newProperty,destinationStr,storyBoardIdString];
                            if ([ZHNSString getCountLeftString:@"<outlet property=\"" rightString:[NSString stringWithFormat:@"destination=\"%@\"",destinationStr] priorityIsLeft:NO notContainStringArr:@[@"<",@">"] inText:text]==0) {
                                [arrM insertObject:outlet atIndex:arrM.count-1];
                            }else{
                                [[self defalutCreateId]removeObjectForKey:property];
                                [[self defalutCreateCategory]removeObjectForKey:property];
                            }
                        }
                    }
                    
                    isTableViewCell=0;
                }
                if ([self defalutCellFileName].count>2) {
                    [[self defalutCellFileName]removeLastObject];
                    [[self defalutCellFileName]removeLastObject];
                    if ([self defalutCellFileName].count>2) {
                        NSString *isTableViewCellTemp=[[self defalutCellFileName] lastObject];
                        isTableViewCell=[isTableViewCellTemp integerValue];
                        cellPropertys =[self defalutCreateProperty][[self defalutCellFileName][[self defalutCellFileName].count-2]];
                    }else{
                        cellPropertys=nil;
                    }
                }else{
                    cellPropertys=nil;
                }
            }
            if ([tempStr hasPrefix:@"</collectionViewCell>"]) {
                if (isTableViewCell==2) {
                    //说明这个cell之前没有拉过约束
                    if (i>0&&[arr[i-1] rangeOfString:@"</connections>"].location==NSNotFound) {
                        NSMutableString *connections=[NSMutableString string];
                        [connections appendString:@"<connections>\n"];
                        
                        NSInteger realInsert=0;
                        for (NSString *property in cellPropertys) {
                            NSString *newProperty=property;
                            newProperty=[self getRealKey:newProperty];
                            NSString *destinationStr=[self defalutCreateId][property];
                            if ([newProperty hasPrefix:@"_"]) {
                                newProperty=[newProperty substringFromIndex:1];
                            }else if ([self isConstain:newProperty]){
                                NSString *constainType=[self getConstainType:newProperty];
                                if (constainType.length==1) {
                                    NSString *constainType=[self getConstainType:newProperty];
                                    if (constainType.length==1) {
                                        destinationStr=[self getValueWithConstantType:constainType withIds:[self defalutCreateId][property] withResultDicM:resultDicM];
                                        newProperty=[newProperty substringFromIndex:2];
                                    }
                                }
                            }
                            
                            if (destinationStr.length<=0) {
                                continue;
                            }
                            NSString *storyBoardIdString=[self getStoryBoardIdString];
                            while ([text rangeOfString:storyBoardIdString].location!=NSNotFound) {
                                storyBoardIdString=[self getStoryBoardIdString];
                            }
                            NSString *outlet=[NSString stringWithFormat:@"<outlet property=\"%@\" destination=\"%@\" id=\"%@\"/>\n",newProperty,destinationStr,storyBoardIdString];
                            if ([ZHNSString getCountLeftString:@"<outlet property=\"" rightString:[NSString stringWithFormat:@"destination=\"%@\"",destinationStr] priorityIsLeft:NO notContainStringArr:@[@"<",@">"] inText:text]==0) {
                                [connections appendString:outlet];
                                realInsert++;
                            }else{
                                [[self defalutCreateId]removeObjectForKey:property];
                                [[self defalutCreateCategory]removeObjectForKey:property];
                            }
                        }
                        [connections appendString:@"</connections>"];
                        if (cellPropertys.count>0&&realInsert>0) {
                            [arrM insertObject:connections atIndex:arrM.count];
                        }
                    }
                    //说明这个cell之前有拉过约束
                    else if(i>0&&[arr[i-1] rangeOfString:@"</connections>"].location!=NSNotFound){
                        for (NSString *property in cellPropertys) {
                            NSString *newProperty=property;
                            newProperty=[self getRealKey:newProperty];
                            NSString *destinationStr=[self defalutCreateId][property];
                            if ([newProperty hasPrefix:@"_"]) {
                                newProperty=[newProperty substringFromIndex:1];
                            }else if ([self isConstain:newProperty]){
                                NSString *constainType=[self getConstainType:newProperty];
                                if (constainType.length==1) {
                                    NSString *constainType=[self getConstainType:newProperty];
                                    if (constainType.length==1) {
                                        destinationStr=[self getValueWithConstantType:constainType withIds:[self defalutCreateId][property] withResultDicM:resultDicM];
                                        newProperty=[newProperty substringFromIndex:2];
                                    }
                                }
                            }
                            
                            if (destinationStr.length<=0) {
                                continue;
                            }
                            NSString *storyBoardIdString=[self getStoryBoardIdString];
                            while ([text rangeOfString:storyBoardIdString].location!=NSNotFound) {
                                storyBoardIdString=[self getStoryBoardIdString];
                            }
                            NSString *outlet=[NSString stringWithFormat:@"<outlet property=\"%@\" destination=\"%@\" id=\"%@\"/>",newProperty,destinationStr,storyBoardIdString];
                            if ([ZHNSString getCountLeftString:@"<outlet property=\"" rightString:[NSString stringWithFormat:@"destination=\"%@\"",destinationStr] priorityIsLeft:NO notContainStringArr:@[@"<",@">"] inText:text]==0) {
                                [arrM insertObject:outlet atIndex:arrM.count-1];
                            }else{
                                [[self defalutCreateId]removeObjectForKey:property];
                                [[self defalutCreateCategory]removeObjectForKey:property];
                            }
                        }
                    }
                    
                    isTableViewCell=0;
                }
                if ([self defalutCellFileName].count>2) {
                    [[self defalutCellFileName]removeLastObject];
                    [[self defalutCellFileName]removeLastObject];
                    if ([self defalutCellFileName].count>2) {
                        NSString *isTableViewCellTemp=[[self defalutCellFileName] lastObject];
                        isTableViewCell=[isTableViewCellTemp integerValue];
                        cellPropertys =[self defalutCreateProperty][[self defalutCellFileName][[self defalutCellFileName].count-2]];
                    }else{
                        cellPropertys=nil;
                    }
                }else{
                    cellPropertys=nil;
                }
            }
            if ([tempStr hasPrefix:@"</viewController>"]) {
                BOOL isContain = NO;
                if (isXib && i>=2) {
                    isContain = [arr[i-2] rangeOfString:@"</connections>"].location!=NSNotFound;
                }
                //说明这个viewController之前没有拉过约束
                if (i>0&&[arr[i-1] rangeOfString:@"</connections>"].location==NSNotFound&&!isContain) {
                    NSMutableString *connections=[NSMutableString string];
                    [connections appendString:@"<connections>\n"];
                    
                    NSInteger realInsert=0;
                    for (NSString *property in viewControllerPropertys) {
                        NSString *newProperty=property;
                        newProperty=[self getRealKey:newProperty];
                        NSString *destinationStr=[self defalutCreateId][property];
                        if ([newProperty hasPrefix:@"_"]) {
                            newProperty=[newProperty substringFromIndex:1];
                        }else if ([self isConstain:newProperty]){
                            NSString *constainType=[self getConstainType:newProperty];
                            if (constainType.length==1) {
                                NSString *constainType=[self getConstainType:newProperty];
                                if (constainType.length==1) {
                                    destinationStr=[self getValueWithConstantType:constainType withIds:[self defalutCreateId][property] withResultDicM:resultDicM];
                                    newProperty=[newProperty substringFromIndex:2];
                                }
                            }
                        }
                        
                        if (destinationStr.length<=0) {
                            continue;
                        }
                        NSString *storyBoardIdString=[self getStoryBoardIdString];
                        while ([text rangeOfString:storyBoardIdString].location!=NSNotFound) {
                            storyBoardIdString=[self getStoryBoardIdString];
                        }
                        NSString *outlet=[NSString stringWithFormat:@"<outlet property=\"%@\" destination=\"%@\" id=\"%@\"/>\n",newProperty,destinationStr,storyBoardIdString];
                        if ([ZHNSString getCountLeftString:@"<outlet property=\"" rightString:[NSString stringWithFormat:@"destination=\"%@\"",destinationStr]  priorityIsLeft:NO notContainStringArr:@[@"<",@">"] inText:text]==0) {
                            [connections appendString:outlet];
                            realInsert++;
                        }else{
                            [[self defalutCreateId]removeObjectForKey:property];
                            [[self defalutCreateCategory]removeObjectForKey:property];
                        }
                    }
                    [connections appendString:@"</connections>"];
                    if (viewControllerPropertys.count>0&&realInsert>0) {
                        [arrM insertObject:connections atIndex:arrM.count];
                    }
                }
                //说明这个viewController之前有拉过约束
                else if((i>0&&[arr[i-1] rangeOfString:@"</connections>"].location!=NSNotFound)||isContain){
                    for (NSString *property in viewControllerPropertys) {
                        NSString *newProperty=property;
                        newProperty=[self getRealKey:newProperty];
                        NSString *destinationStr=[self defalutCreateId][property];
                        if ([newProperty hasPrefix:@"_"]) {
                            newProperty=[newProperty substringFromIndex:1];
                        }else if ([self isConstain:newProperty]){
                            NSString *constainType=[self getConstainType:newProperty];
                            if (constainType.length==1) {
                                NSString *constainType=[self getConstainType:newProperty];
                                if (constainType.length==1) {
                                    destinationStr=[self getValueWithConstantType:constainType withIds:[self defalutCreateId][property] withResultDicM:resultDicM];
                                    newProperty=[newProperty substringFromIndex:2];
                                }
                            }
                        }
                        
                        if (destinationStr.length<=0) {
                            continue;
                        }
                        NSString *storyBoardIdString=[self getStoryBoardIdString];
                        while ([text rangeOfString:storyBoardIdString].location!=NSNotFound) {
                            storyBoardIdString=[self getStoryBoardIdString];
                        }
                        NSString *outlet=[NSString stringWithFormat:@"<outlet property=\"%@\" destination=\"%@\" id=\"%@\"/>",newProperty,destinationStr,storyBoardIdString];
                        if ([ZHNSString getCountLeftString:@"<outlet property=\"" rightString:[NSString stringWithFormat:@"destination=\"%@\"",destinationStr]  priorityIsLeft:NO notContainStringArr:@[@"<",@">"] inText:text]==0) {
                            if (isXib&&isContain) {
                                [arrM insertObject:outlet atIndex:arrM.count-2];
                            }else{
                                [arrM insertObject:outlet atIndex:arrM.count-1];
                            }
                            
                        }else{
                            [[self defalutCreateId]removeObjectForKey:property];
                            [[self defalutCreateCategory]removeObjectForKey:property];
                        }
                    }
                }
                viewControllerPropertys=nil;
            }
        }
        [arrM addObject:rowStr];
    }
    return [arrM componentsJoinedByString:@"\n"];
}

+ (void)insertCode{
    for (NSString *fileName in [self defalutCreateProperty]) {
        if([self defalutCreateFile][fileName]!=nil){
            [self insertCodePropertys:[self defalutCreateProperty][fileName] toStrM:[self defalutCreateContent][[self defalutCreateFile][fileName]] withFileName:fileName];
            [self insertModelPropertyString:[self defalutCreateProperty][fileName] withFileName:fileName];
        }
    }
}

+ (void)insertCodePropertys:(NSArray *)propertys toStrM:(NSMutableString *)strM withFileName:(NSString *)fileName{
    //首先判断里面有没有类扩展
//    @interface
    if ([strM rangeOfString:@"@interface"].location==NSNotFound) {
        NSString *interface=[NSString stringWithFormat:@"@interface %@ ()\n\
                             \n\
                             @end",fileName];
        [ZHStoryboardTextManager addCodeText:interface andInsertType:ZHAddCodeType_Import toStrM:strM insertFunction:nil];
    }
    
    for (NSString *property in propertys) {
        
        NSString *newProperty=[self getPropertyCode:property];
        
        if (newProperty.length>0&&[strM rangeOfString:newProperty].location==NSNotFound) {
            [ZHStoryboardTextManager addCodeText:newProperty andInsertType:ZHAddCodeType_Interface toStrM:strM insertFunction:nil];
        }
    }
    
    //本来是要插入函数的,这里暂时不要了
    if(propertys.count>0){
        if ([strM rangeOfString:@"- (void)setPropertyValues{"].location!=NSNotFound) {
            NSString *setValue=[self getSetValueFunc:propertys isExsitFunc:YES];
            if (setValue.length>0) {
                setValue=[@"\n" stringByAppendingString:setValue];
                [ZHStoryboardTextManager addCodeText:setValue andInsertType:ZHAddCodeType_InsertFunction toStrM:strM insertFunction:@"- (void)setPropertyValues{"];
            }
        }else{
            NSString *setValue=[self getSetValueFunc:propertys isExsitFunc:NO];
            [ZHStoryboardTextManager addCodeText:setValue andInsertType:ZHAddCodeType_Implementation toStrM:strM insertFunction:nil];
        }
    }
}

+ (NSString *)getPropertyCode:(NSString *)property{
    
    if ([self isConstain:property]){
        NSString *constainType=[self getConstainType:property];
        if (constainType.length==1) {
            property=[property substringFromIndex:2];
            return [NSString stringWithFormat:@"@property (weak, nonatomic) IBOutlet NSLayoutConstraint *%@;",property];
        }
    }
    
    NSString *category=[self defalutCreateCategory][property];
    
    if (category.length<=0) {
        return @"";
    }
    
    category=[ZHNSString removeSpaceBeforeAndAfterWithString:category];
    
    property=[self getRealKey:property];
    
    if ([property hasPrefix:@"_"]) {
        property=[property substringFromIndex:1];
    }
    
    NSString *viewCategory;
    if ([category hasPrefix:@"mapView"]) {
        viewCategory=@"MKMapView";
    }
    
    viewCategory=[@"UI" stringByAppendingString:[ZHStoryboardTextManager upFirstCharacter:category]];
    return [NSString stringWithFormat:@"@property (weak, nonatomic) IBOutlet %@ *%@;",viewCategory,property];
}

+ (NSString *)getValue:(NSString *)viewName category:(NSString *)category{
    if (viewName.length>0&&category.length>0) {
        if ([[viewName lowercaseString]hasSuffix:[category lowercaseString]]) {
            if ([[category lowercaseString]isEqualToString:[@"ImageView" lowercaseString]]) {
                NSString *remain=[viewName substringToIndex:viewName.length-category.length];
                remain=[remain stringByAppendingString:@"ImageName"];
                return remain;
            }
            return [viewName substringToIndex:viewName.length-category.length];
        }
    }
    return viewName;
}

+ (void)insertModelPropertyString:(NSArray *)propertys withFileName:(NSString *)fileName{
    
    NSMutableString *text=[NSMutableString string];
    NSString *tempFile=fileName;
    if ([[tempFile lowercaseString]hasSuffix:@"tableviewcell"]) {
        tempFile=[tempFile substringToIndex:tempFile.length-@"tableviewcell".length];
        tempFile=[tempFile stringByAppendingString:@"CellModel.h"];
    }else if ([[tempFile lowercaseString]hasSuffix:@"collectionviewcell"]){
        tempFile=[tempFile substringToIndex:tempFile.length-@"collectionviewcell".length];
        tempFile=[tempFile stringByAppendingString:@"CellModel.h"];
    }
    
    if ([tempFile isEqualToString:fileName]==NO) {
        NSString *path=@"";
        NSArray *files=[ZHFileManager subPathFileArrInDirector:ZHProjectPath hasPathExtension:@[@".h"]];
        for (NSString *filePath in files) {
            if ([[ZHFileManager getFileNameFromFilePath:filePath]isEqualToString:tempFile]) {
                path=filePath;
                break;
            }
        }
        if (path.length>0&&[ZHFileManager fileExistsAtPath:path]) {
            [text setString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];
            
            NSMutableString *strM=[NSMutableString string];
            for (NSString *property in propertys) {
                NSString *category=[self defalutCreateCategory][property];
                
                if (category.length>0) {
                    category=[ZHNSString removeSpaceBeforeAndAfterWithString:category];
                    
                    NSString *tempProperty=property;
                    if ([tempProperty hasPrefix:@"_"]) {
                        tempProperty=[tempProperty substringFromIndex:1];
                    }
                    tempProperty=[self getRealKey:tempProperty];
                    tempProperty=[self getValue:tempProperty category:category];
                    if (tempProperty.length>0) {
                        NSString *code=[NSString stringWithFormat:@"\n@property (nonatomic,copy)NSString *%@;",tempProperty];
                        if ([text rangeOfString:code].location==NSNotFound) {
                            [strM appendString:code];
                        }
                    }
                }
            }
            if (strM.length>0) {
                [ZHStoryboardTextManager addCodeText:strM andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
            }
            
            [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

+ (NSString *)getSetValueFunc:(NSArray *)propertys isExsitFunc:(BOOL)isExsitFunc{
    NSMutableString *codeFunc=[NSMutableString string];
    
    if (isExsitFunc==NO) {
        [codeFunc appendString:@"- (void)setPropertyValues{\n"];
    }
    
    for (NSString *property in propertys) {
        
        NSString *category=[self defalutCreateCategory][property];
        category=[ZHNSString removeSpaceBeforeAndAfterWithString:category];
        
        NSString *propertyTemp=property;
        propertyTemp=[self getRealKey:propertyTemp];
        if ([propertyTemp hasPrefix:@"_"]) {
            propertyTemp=[propertyTemp substringFromIndex:1];
        }else{
            continue;
        }
        
        NSString *code=[StroyBoardPropertySetValue getCodePropertysForViewName:propertyTemp WithViewCategory:category];
        
        if(code.length>0)
            [codeFunc appendFormat:@"\t%@\n",code];
    }
    
    if (isExsitFunc==NO) {
        [codeFunc appendString:@"}"];
    }
    
    return codeFunc;
}

+ (BOOL)isCell:(NSString *)rowStr{
    if ([rowStr rangeOfString:@"<tableViewCell "].location!=NSNotFound||[rowStr rangeOfString:@"<collectionViewCell "].location!=NSNotFound) {
        return YES;
    }
    return NO;
}

+ (void)addCustomClassProperty:(NSString *)customClass withCellFileName:(NSString *)cellFileName withViewControllerFileName:(NSString *)viewControllerFileName{
    if ([cellFileName isEqualToString:@"noExsit"]) {
        if ([viewControllerFileName isEqualToString:@"noExsit"]==NO) {
            NSMutableArray *propertyArrM=[self defalutCreateProperty][viewControllerFileName];
            if (propertyArrM==nil) {
                propertyArrM=[NSMutableArray array];
            }
            [propertyArrM addObject:customClass];
            [[self defalutCreateProperty]setValue:propertyArrM forKey:viewControllerFileName];
        }
    }else{
        NSMutableArray *propertyArrM=[self defalutCreateProperty][cellFileName];
        if (propertyArrM==nil) {
            propertyArrM=[NSMutableArray array];
        }
        [propertyArrM addObject:customClass];
        [[self defalutCreateProperty]setValue:propertyArrM forKey:cellFileName];
    }
}

+ (void)backupNewStroyBoard:(NSString *)filePath{
    //有后缀的文件名
    NSString *tempFileName=[ZHFileManager getFileNameFromFilePath:filePath];
    
    //无后缀的文件名
    NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
    
    //获取无文件名的路径
    NSString *newFilePath=[filePath stringByReplacingOccurrencesOfString:tempFileName withString:@""];
    
    //拿到新的有后缀的文件名
    tempFileName=[tempFileName stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@备份",fileName]];
    
    newFilePath = [newFilePath stringByAppendingPathComponent:tempFileName];
    
    [ZHFileManager copyItemAtPath:filePath toPath:newFilePath];
}

+ (void)done{
    //开始保存所有编程文件
    [[self defalutCreateCategory]removeAllObjects];
    [[self defalutCreateProperty]removeAllObjects];
    
    for (NSString *filePath in [self defalutCreateContent]) {
        NSString *text=[self defalutCreateContent][filePath];
        [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    [[self defalutCreateFile]removeAllObjects];
    [[self defalutCreateContent]removeAllObjects];
    [[self defalutCreateId]removeAllObjects];
    [[self defalutCreateReuse]removeAllObjects];
    [[self defalutCellFileName] removeAllObjects];
    [[self defalutTempCellName]removeAllObjects];
    [[self defalutTempControllerName]removeAllObjects];
}

+ (NSString *)getStoryBoardIdString{
    //    gSS-Oy-SNc
    NSMutableString *idText=[NSMutableString string];
    while (idText.length<3) {
        [idText appendString:[self getCharacter]];
    }
    [idText appendString:@"-"];
    while (idText.length<6) {
        [idText appendString:[self getCharacter]];
    }
    [idText appendString:@"-"];
    while (idText.length<10) {
        [idText appendString:[self getCharacter]];
    }
    return idText;
}
+ (NSString *)getCharacter{
    NSInteger count=arc4random()%3+1;
    
    unichar ch;
    if (count==1) {
        ch='0'+arc4random()%10;
    }else if (count==2){
        ch='A'+arc4random()%26;
    }else if (count==3){
        ch='a'+arc4random()%26;
    }
    return [NSString stringWithFormat:@"%C",ch];
}
@end
