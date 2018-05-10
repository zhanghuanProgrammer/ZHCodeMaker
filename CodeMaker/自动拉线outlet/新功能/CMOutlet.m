
#import "CMOutlet.h"

@implementation CMOutlet

+ (NSInteger)createOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSInteger count = 0;
    if ([ZHFileManager fileExistsAtPath:stroyBoardPath]==NO||[ZHFileManager fileExistsAtPath:projectPath]==NO) {
        return 0;
    }
    count+=[self creatAllOutletWithStroyBoardPath:stroyBoardPath withProjectPath:projectPath];
    count+=[self deleteAllOutletWithStroyBoardPath:stroyBoardPath withProjectPath:projectPath];
    count+=[self replaceOutletWithStroyBoardPath:stroyBoardPath withProjectPath:projectPath];
    return count;
}

/**生成所有约束Outlet代码到对应的文件里*/
+ (NSInteger)creatAllOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    if ([text rangeOfString:@" customClass=\"_all_\""].location==NSNotFound) {
        return 0;
    }
    text = [text stringByReplacingOccurrencesOfString:@" customClass=\"_all_\"" withString:@""];
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dic = [self getAllOutletWithStroyBoardPath:stroyBoardPath withProjectPath:projectPath];
    [self onlyClearAllOutletWithStroyBoardPath:stroyBoardPath withProjectPath:projectPath];
    text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *arr = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSString *str in arr) {
        NSString *replaceStr = str;
        NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
        tempStr = [ZHNSString removeSpacePrefix:tempStr];
        tempStr = [ZHNSString removeSpaceSuffix:tempStr];
        if ([tempStr rangeOfString:@"id=\""].location!=NSNotFound) {
            NSString *idStr = [tempStr substringFromIndex:[tempStr rangeOfString:@"id=\""].location+@"id=\"".length];
            idStr = [idStr substringToIndex:[idStr rangeOfString:@"\""].location];
            NSString *property = dic[idStr];
            if (property && [property length]>0) {
                if ([tempStr rangeOfString:@" customClass=\""].location==NSNotFound) {
                    if ([tempStr hasSuffix:@">"]) {
                        replaceStr = [tempStr substringToIndex:tempStr.length-1];
                        replaceStr = [replaceStr stringByAppendingString:[NSString stringWithFormat:@" customClass=\"_%@\">",property]];
                        [arrM addObject:replaceStr];
                        continue;
                    }
                }
            }
        }
        [arrM addObject:str];
    }
    
    text = [arrM componentsJoinedByString:@"\n"];
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return 0;
}

+ (NSDictionary *)getAllOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *arr = [text componentsSeparatedByString:@"\n"];
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
        tempStr = [ZHNSString removeSpacePrefix:tempStr];
        tempStr = [ZHNSString removeSpaceSuffix:tempStr];
        if ([tempStr hasPrefix:@"<outlet property="]) {
            NSString *property = tempStr;
            property = [property substringFromIndex:[property rangeOfString:@"property=\""].location+@"property=\"".length];
            property = [property substringToIndex:[property rangeOfString:@"\""].location];
            NSString *destination = tempStr;
            destination = [destination substringFromIndex:[destination rangeOfString:@"destination=\""].location+@"destination=\"".length];
            destination = [destination substringToIndex:[destination rangeOfString:@"\""].location];
            [dicM setValue:property forKey:destination];
        }
    }
    return dicM;
}

+ (void)onlyClearAllOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *arr = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
        tempStr = [ZHNSString removeSpacePrefix:tempStr];
        tempStr = [ZHNSString removeSpaceSuffix:tempStr];
        if (![tempStr hasPrefix:@"<outlet property="]) {
            [arrM addObject:str];
        }
    }
    text = [arrM componentsJoinedByString:@"\n"];
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

/**删除所有的约束*/
+ (NSInteger)deleteAllOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSInteger countDelete = 0;
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    if ([text rangeOfString:@" customClass=\"_rm_\""].location==NSNotFound) {
        return 0;
    }
    NSInteger count = -1;
    NSArray *arr = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM = [NSMutableArray array];
    NSMutableArray *deleteOutlets = [NSMutableArray array];
    NSString *identityView = @"";
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
        tempStr = [ZHNSString removeSpacePrefix:tempStr];
        tempStr = [ZHNSString removeSpaceSuffix:tempStr];
        
        if ([tempStr rangeOfString:@" customClass=\"_rm_\""].location!=NSNotFound) {
            if ([tempStr hasPrefix:@"<"] && [tempStr rangeOfString:@" "].location!=NSNotFound) {
                identityView = [tempStr substringToIndex:[tempStr rangeOfString:@" "].location];
                identityView = [identityView substringFromIndex:1];
            }
        }
        
        if (identityView.length>0) {
            NSString *prefix = [NSString stringWithFormat:@"<%@",identityView];
            if ([tempStr hasPrefix:prefix]) {
                count = 0;
                if(count>=0)count++;
            }
            NSString *prefix1 = [NSString stringWithFormat:@"</%@>",identityView];
            if ([tempStr hasPrefix:prefix1]) {
                if (count==1) {
                    count=-1;
                    identityView = @"";
                }
                count--;if(count<0)count=-1;
            }
            if (count>0) {
                if ([tempStr rangeOfString:@"id=\""].location!=NSNotFound) {
                    NSString *idStr = [tempStr substringFromIndex:[tempStr rangeOfString:@"id=\""].location+@"id=\"".length];
                    idStr = [idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                    [deleteOutlets addObject:idStr];
                }
            }
        }
        if ([tempStr hasPrefix:@"<outlet property="]) {
            BOOL isShouldDelete = NO;
            for (NSString *idStr in deleteOutlets) {
                if ([tempStr rangeOfString:[NSString stringWithFormat:@"destination=\"%@\"",idStr]].location!=NSNotFound){
                    isShouldDelete = YES;
                    countDelete++;
                }
            }
            if (!isShouldDelete) {
                [arrM addObject:str];
            }
        }else{
            [arrM addObject:str];
        }
    }
    text = [arrM componentsJoinedByString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@" customClass=\"_rm_\"" withString:@""];
    
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return countDelete;
}

/**删除指定的约束.这个比较尴尬,没什么用*/
+ (NSInteger)deleteOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSInteger count = 0;
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    if ([text rangeOfString:@" customClass=\"_rm_\""].location==NSNotFound) {
        return 0;
    }
    
    NSArray *arr = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM = [NSMutableArray array];
    NSMutableArray *deleteOutlets = [NSMutableArray array];
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
        tempStr = [ZHNSString removeSpacePrefix:tempStr];
        tempStr = [ZHNSString removeSpaceSuffix:tempStr];
        if ([tempStr rangeOfString:@" customClass=\"_rm_\""].location!=NSNotFound) {
            if ([tempStr rangeOfString:@"id=\""].location!=NSNotFound) {
                NSString *idStr = [tempStr substringFromIndex:[tempStr rangeOfString:@"id=\""].location+@"id=\"".length];
                idStr = [idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                [deleteOutlets addObject:idStr];
                count++;
            }
        }
        if ([tempStr hasPrefix:@"<outlet property="]) {
            BOOL isShouldDelete = NO;
            for (NSString *idStr in deleteOutlets) {
                if ([tempStr rangeOfString:[NSString stringWithFormat:@"destination=\"%@\"",idStr]].location!=NSNotFound){
                    isShouldDelete = YES;
                }
            }
            if (!isShouldDelete) {
                [arrM addObject:str];
            }
        }else{
            [arrM addObject:str];
        }
    }
    
    text = [arrM componentsJoinedByString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@" customClass=\"_rm_\"" withString:@""];
    
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return count;
}

/**替换掉约束*/
+ (NSInteger)replaceOutletWithStroyBoardPath:(NSString *)stroyBoardPath withProjectPath:(NSString *)projectPath{
    NSString *text=[NSString stringWithContentsOfFile:stroyBoardPath encoding:NSUTF8StringEncoding error:nil];
    if ([text rangeOfString:@" customClass=\"_re_"].location==NSNotFound) {
        return 0;
    }
    
    NSArray *arr = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM = [NSMutableArray array];
    NSMutableArray *deleteOutlets = [NSMutableArray array];
    for (NSString *str in arr) {
        NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:str];
        tempStr = [ZHNSString removeSpacePrefix:tempStr];
        tempStr = [ZHNSString removeSpaceSuffix:tempStr];
        if ([tempStr rangeOfString:@" customClass=\"_re_"].location!=NSNotFound) {
            if ([tempStr rangeOfString:@"id=\""].location!=NSNotFound) {
                NSString *idStr = [tempStr substringFromIndex:[tempStr rangeOfString:@"id=\""].location+@"id=\"".length];
                idStr = [idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                [deleteOutlets addObject:idStr];
            }
        }
        if ([tempStr hasPrefix:@"<outlet property="]) {
            BOOL isShouldDelete = NO;
            for (NSString *idStr in deleteOutlets) {
                if ([tempStr rangeOfString:[NSString stringWithFormat:@"destination=\"%@\"",idStr]].location!=NSNotFound){
                    isShouldDelete = YES;
                }
            }
            if (!isShouldDelete) {
                [arrM addObject:str];
            }
        }else{
            [arrM addObject:str];
        }
    }
    
    text = [arrM componentsJoinedByString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@" customClass=\"_re_" withString:@" customClass=\"_"];
    
    [text writeToFile:stroyBoardPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return 0;
}

@end
