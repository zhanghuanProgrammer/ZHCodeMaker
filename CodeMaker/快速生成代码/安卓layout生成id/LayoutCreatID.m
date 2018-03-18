//
//  LayoutCreatID.m
//  代码助手
//
//  Created by mac on 17/6/12.
//  Copyright © 2017年 com/qianfeng/mac. All rights reserved.
//

#import "LayoutCreatID.h"
#import "ZHCreatAndroidModel.h"
#import "ZHBindDataLayout.h"

@implementation LayoutCreatID
- (NSString *)description{
    return @"请将要生成id的layout拉到文本框里面";
}

- (NSString *)Begin:(NSString *)str toView:(UIView *)view{
    if (str.length<=0) {
        [MBProgressHUD showHUDAddedToView:view withText:@"不要为空!" withDuration:1 animated:NO];
        return @"不要为空!";
    }
    NSDictionary *dataDic=[NSDictionary dictionaryWithXML:str needRecoderOrder:NO];
    ZHRepearDictionary *map=[ZHRepearDictionary new];
    if (dataDic&&[dataDic isKindOfClass:[NSDictionary class]]) {
        [self traverseDictionary:dataDic saveToMap:map forFatherKey:@""];
        NSString *code=[self creatCodeForMap:map];
        if (code.length>0) {
            [MBProgressHUD showHUDAddedToView:view withText:@"生成成功!" withDuration:1 animated:NO];
            return code;
        }
    }
    [MBProgressHUD showHUDAddedToView:view withText:@"生成失败!" withDuration:1 animated:NO];
    return @"生成失败!";
}

- (void)traverseDictionary:(NSDictionary *)dic saveToMap:(ZHRepearDictionary *)map forFatherKey:(NSString *)fatherKey{
    for (NSString *key in dic) {
        id obj=dic[key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self traverseDictionary:obj saveToMap:map forFatherKey:key];
        }else if ([obj isKindOfClass:[NSArray class]]){
            [self traverseArray:obj saveToMap:map forFatherKey:key];
        }else{
            if ([key isEqualToString:@"android:id"]) {
                NSString *value=dic[key];
                if ([value isKindOfClass:[NSString class]]&&[value hasPrefix:@"@+id/"]) {
                    value=[value substringFromIndex:5];
                    [map setValue:value forKey:fatherKey];
                }
            }
        }
    }
}
- (void)traverseArray:(NSArray *)arr saveToMap:(ZHRepearDictionary *)map forFatherKey:(NSString *)fatherKey{
    for (id obj in arr) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self traverseDictionary:obj saveToMap:map forFatherKey:fatherKey];
        }else if ([obj isKindOfClass:[NSArray class]]){
            [self traverseArray:obj saveToMap:map forFatherKey:@""];
        }
    }
}

- (NSString *)creatCodeForMap:(ZHRepearDictionary *)map{
    if (map.dicM.count<=0) {
        return @"";
    }
    NSMutableString *textStrM=[NSMutableString string];
    
    NSMutableString *controls=[NSMutableString string];
    for (NSString *key in map.dicM) {
        [controls appendFormat:@"%@ %@;\n",[ZHRepearDictionary getKeyForKey:key],map.dicM[key]];
    }
    [textStrM appendString:controls];
    
    NSMutableString *findByIds=[NSMutableString string];
    for (NSString *key in map.dicM) {
        [findByIds appendFormat:@"%@ = (%@) itemView.findViewById(R.id.%@);\n",map.dicM[key],[ZHRepearDictionary getKeyForKey:key],map.dicM[key]];
    }
    [findByIds appendString:@"\n\n"];
    [textStrM appendString:findByIds];
    
    NSString *modelValues=[[ZHCreatAndroidModel new] getAndroidModelWithParameter:map.dicM];
    [textStrM appendString:modelValues];
    
    NSString *bindDataLayout=[[ZHBindDataLayout new] getBindDataLayoutWithParameter:map.dicM];
    [textStrM appendString:bindDataLayout];
    
    return [[ZHWordWrap new]wordWrapText:textStrM];
}

@end
