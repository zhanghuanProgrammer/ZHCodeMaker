#import "ZHJson.h"

@implementation ZHJson
/**将json字符串格式化或者压缩化*/
- (NSString *)jsonFormat:(NSString *)text isCompression:(BOOL)compression{
    
    NSData *data=[text dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;
    id obj=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error==nil) {
        if ([obj isKindOfClass:[NSArray class]]||[obj isKindOfClass:[NSDictionary class]]) {
            if ([NSJSONSerialization isValidJSONObject:obj]) {
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:compression?0:NSJSONWritingPrettyPrinted error:&error];
                NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                if (!error) return json;
            }
        }
    }
    return nil;
}

- (NSMutableDictionary *)copyMutableDicFromDictionary:(NSDictionary *)dic{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    for (NSString *key in dic) {
        id obj=dic[key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [dicM setValue:[self copyMutableDicFromDictionary:obj] forKey:key];
        }else if ([obj isKindOfClass:[NSArray class]]){
            [dicM setValue:[self copyMutableArrFromArray:obj] forKey:key];
        }else{
            [dicM setValue:obj forKey:key];
        }
    }
    return dicM;
}
- (NSMutableArray *)copyMutableArrFromArray:(NSArray *)arr{
    NSMutableArray *arrM=[NSMutableArray array];
    for (id obj in arr) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [arrM addObject:[self copyMutableDicFromDictionary:obj]];
        }else if ([obj isKindOfClass:[NSArray class]]){
            [arrM addObject:[self copyMutableArrFromArray:obj]];
        }else{
            [arrM addObject:obj];
        }
    }
    return arrM;
}

- (void)unique:(id)obj{
    
    if([obj isKindOfClass:[NSMutableDictionary class]]){//如果obj对象是字典
        
        NSMutableDictionary *tempDic=(NSMutableDictionary *)obj;
        
        for (NSString *key in tempDic) {//开始遍历字典里面的键值对
            if([tempDic[key] isKindOfClass:[NSMutableArray class]]){//如果字典里面是数组
                
                [self unique:tempDic[key]];
            }
            else if ([tempDic[key] isKindOfClass:[NSMutableDictionary class]]){//如果字典里面是字典
                
                [self unique:tempDic[key]];
            }
        }
    }
    else if([obj isKindOfClass:[NSMutableArray class]]){//如果obj对象是数组
        NSMutableArray *tempArr=(NSMutableArray *)obj;
        
        BOOL isContainDic=NO;
        for (id tempObj in tempArr) {
            if ([tempObj isKindOfClass:[NSMutableDictionary class]]) {
                isContainDic=YES;
                break;
            }
        }
        
        if (isContainDic) {
            [self uniqueArr:tempArr];
            
            for (id tempObj in tempArr) {
                if([tempObj isKindOfClass:[NSMutableDictionary class]]){
                    [self unique:tempObj];
                }
            }
        }else{
            if (tempArr.count>1) {
                [tempArr removeObjectsInRange:NSMakeRange(1, tempArr.count-1)];
            }
        }
    }
}
- (void)uniqueArr:(NSMutableArray *)arrM{
    NSMutableArray *tempArrM=[NSMutableArray array];
    for (id obj in arrM) {
        if ([obj isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *dic=obj;
            if (tempArrM.count==0) {
                [tempArrM addObject:dic];
            }else{
                BOOL isDifferent=YES;
                for (NSMutableDictionary *tempDic in tempArrM) {
                    NSMutableDictionary *result=[self compareDic1:dic dic2:tempDic];
                    if (result!=nil) {//如果为nil,说明两个字典相同
                        isDifferent=NO;
                        [dic setDictionary:result];
                        [tempDic setDictionary:result];
                    }
                }
                if (isDifferent) {
                    [tempArrM addObject:dic];
                }
            }
        }
    }
    [arrM setArray:tempArrM];
}
- (NSMutableDictionary *)compareDic1:(NSMutableDictionary *)dic1 dic2:(NSMutableDictionary *)dic2{
    NSArray *dic1_allKey=[dic1 allKeys];
    NSArray *dic2_allKey=[dic2 allKeys];
    //如果两个字典的key值都不相等,说明两个字典不是相同或者是包含的关系
    
    CompareArray result=[dic1_allKey compareToTextArr:dic2_allKey];
    if (result==CompareArray_Different)
        return nil;
    
    NSMutableDictionary *maxLenDic;
    NSMutableDictionary *minLenDic;
    
    if (result==CompareArray_NextLarge) {minLenDic=dic1;maxLenDic=dic2;}
    else if (result==CompareArray_NextLarge) {minLenDic=dic2;maxLenDic=dic1;}
    else {
        if (dic2.count>dic1.count) {
            minLenDic=dic1;maxLenDic=dic2;
        }else{
            minLenDic=dic2;maxLenDic=dic1;
        }
    }
    
    BOOL isFind=NO;
    for (NSString *key in maxLenDic) {
        id minObj=minLenDic[key];
        id maxObj=maxLenDic[key];
        if (minObj!=nil&&maxObj!=nil) {
            if ([minObj isKindOfClass:[NSMutableDictionary class]]) {
                if ([maxObj isKindOfClass:[NSMutableDictionary class]]){
                    NSMutableDictionary *resultDicM=[self compareDic1:minObj dic2:maxObj];
                    if (resultDicM==nil&&isFind==NO) return nil;
                    else{
                        NSMutableDictionary *maxObjTemp=maxObj;
                        [maxObjTemp setDictionary:resultDicM];
                    }
                }
                else if(isFind==NO) return nil;
            }else if ([minObj isKindOfClass:[NSMutableArray class]]) {
                if (![maxObj isKindOfClass:[NSMutableArray class]]&&isFind==NO){
                    return nil;
                }else{
                    [self uniqueArr:maxObj];
                    NSMutableArray *maxObjTemp=maxObj;
                    NSMutableArray *minObjTemp=minObj;
                    if (maxObjTemp.count!=minObjTemp.count) {
                        isFind=YES;
                    }
                    if (maxObjTemp.count<minObjTemp.count) {
                        [maxObjTemp setArray:minObjTemp];
                    }
                }
            }
        }
    }
    
    return maxLenDic;
}

- (NSString *)compressionJson:(NSString *)json{
    NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableDictionary *jsonDicM=[[ZHJson new] copyMutableDicFromDictionary:jsonDic];
    [[ZHJson new] unique:jsonDicM];
    NSString *newJson=[[ZHJson new] jsonFormat:[jsonDicM jsonPrettyStringEncoded] isCompression:NO];
    
    return newJson;
}

/**移除掉Value通过key值*/
- (NSDictionary *)removeValueForKeys:(NSArray *)keys FromDictionary:(NSDictionary *)dic{
    NSMutableDictionary *dicM=[self copyMutableDicFromDictionary:dic];
    [self removeValueForKeys:keys withData:dicM];
    return dicM;
}

- (void)removeValueForKeys:(NSArray *)keys withData:(id)obj{
    if ([obj isKindOfClass:[NSMutableDictionary class]]) {
        [((NSMutableDictionary *)obj) removeObjectsForKeys:keys];
        for (id subObj in [((NSMutableDictionary *)obj) allValues]) {
            [self removeValueForKeys:keys withData:subObj];
        }
    }else if ([obj isKindOfClass:[NSArray class]]){
        for (id subObj in obj) {
            [self removeValueForKeys:keys withData:subObj];
        }
    }
}

@end
