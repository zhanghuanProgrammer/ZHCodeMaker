#import "ZHStoryboardTextManagerConstant.h"

@implementation ZHStoryboardTextManagerConstant
+ (NSString *)addCustomClassToAllViews:(NSString *)text withIdsCustomDicM:(NSMutableDictionary *)dicM{
    NSArray *arr=[text componentsSeparatedByString:@"\n"];
    NSMutableArray *arrM=[NSMutableArray array];
    NSString *rowStr,*newRowStr,*viewIdenity;
    for (NSInteger i=0; i<arr.count; i++) {
        rowStr=arr[i];
        
        viewIdenity=[self isView:rowStr];
        //如果这一行代表的是控件
        if (viewIdenity.length>0) {
            if ([viewIdenity isEqualToString:@"<view "]&&i>0&&([arr[i-1] rangeOfString:@"key=\""].location!=NSNotFound||[arr[i-1] rangeOfString:@"</layoutGuides>"].location!=NSNotFound)) {
                
                //为了后面好设置约束,需要将这类view的id值设成特殊可识别的标识符
                //取出id值
                if ([rowStr rangeOfString:@"id=\""].location!=NSNotFound) {
                    NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                    idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                    NSString *viewCountIdenity=[self getViewCountIdenityWithViewIdenity:@"<self.view "];
                    [[self defaultIDDicM]setValue:idStr forKey:viewCountIdenity];
                    [dicM setValue:idStr forKey:viewCountIdenity];
                }
                [arrM addObject:[self replaceAllIdByCustomClass:rowStr]];
                continue;
            }
            
            //如果这一行里面没有标识符CustomClass
            if ([rowStr rangeOfString:@" customClass"].location==NSNotFound) {
                
                if ([rowStr hasSuffix:@">"]==YES) {
                    newRowStr=[rowStr substringToIndex:rowStr.length-1];
                    NSString *viewCountIdenity=[self getViewCountIdenityWithViewIdenity:viewIdenity];
                    newRowStr=[newRowStr stringByAppendingFormat:@" customClass=\"%@\">",viewCountIdenity];
                    
                    if ([newRowStr rangeOfString:@" customClass=\""].location!=NSNotFound&&[newRowStr rangeOfString:@" id=\""].location!=NSNotFound) {
                        NSString *customClass=[newRowStr substringFromIndex:[newRowStr rangeOfString:@"customClass=\""].location+13];
                        customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                        NSString *idStr=[newRowStr substringFromIndex:[newRowStr rangeOfString:@"id=\""].location+4];
                        idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                        
                        [[self defaultIDDicM]setValue:idStr forKey:customClass];
                        [dicM setValue:idStr forKey:customClass];
                        
                    }else{
                        NSLog(@"出现小BUG 有的view没有打CustomClass =%@",newRowStr);
                    }
                    
                    [arrM addObject:[self replaceAllIdByCustomClass:newRowStr]];
                    continue;
                }
            }else if ([rowStr rangeOfString:@" customClass=\""].location!=NSNotFound&&[rowStr rangeOfString:@" id=\""].location!=NSNotFound) {
                NSString *customClass=[rowStr substringFromIndex:[rowStr rangeOfString:@"customClass=\""].location+13];
                customClass=[customClass substringToIndex:[customClass rangeOfString:@"\""].location];
                NSString *newCustomClass;
                newCustomClass=[self detailSpecialCustomClassLikeCell:rowStr];
                if (newCustomClass.length>0) {
                    //替换
                    NSString *oldCustom=[@" customClass=\"" stringByAppendingString:customClass];
                    NSString *newCustom=[@" customClass=\"" stringByAppendingString:newCustomClass];
                    rowStr=[rowStr stringByReplacingOccurrencesOfString:oldCustom withString:newCustom];
                    customClass=newCustomClass;
                }
                
                NSString *idStr=[rowStr substringFromIndex:[rowStr rangeOfString:@"id=\""].location+4];
                idStr=[idStr substringToIndex:[idStr rangeOfString:@"\""].location];
                
                [[self defaultIDDicM]setValue:idStr forKey:customClass];
                [dicM setValue:idStr forKey:customClass];
            }else{
                NSLog(@"出现小BUG 有的view没有打CustomClass =%@",rowStr);
            }
        }else{
            
            //如果不是控件,就判断是不是ViewController,因为如果是的,就可以清空 CustomClass 和 id 的字典了
            
            NSString *tempStr=[ZHNSString removeSpaceBeforeAndAfterWithString:rowStr];
            if([tempStr hasPrefix:@"<viewController "]){
                [[self defaultIDDicM] removeAllObjects];
                
                //如果没有打上标识符
                if([tempStr rangeOfString:@" customClass=\""].location==NSNotFound){
                    
                    if ([tempStr hasSuffix:@"sceneMemberID=\"viewController\">"]) {
                        NSString *newRowStr=[rowStr stringByReplacingOccurrencesOfString:@"sceneMemberID=\"viewController\">" withString:@""];
                        NSString *viewCountIdenity=[self getViewCountIdenityWithViewIdenity:@"<viewController "];
                        newRowStr=[newRowStr stringByAppendingString:[NSString stringWithFormat:@"customClass=\"%@\"",viewCountIdenity]];
                        newRowStr=[newRowStr stringByAppendingString:@" sceneMemberID=\"viewController\">"];
                        [arrM addObject:[self replaceAllIdByCustomClass:newRowStr]];
                        continue;
                    }
                }
            }
        }
        [arrM addObject:[self replaceAllIdByCustomClass:rowStr]];
    }
    return [arrM componentsJoinedByString:@"\n"];
}

@end
