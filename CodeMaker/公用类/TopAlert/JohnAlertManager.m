//
//  JohnAlertManager.m
//  顶部提示框
//
//  Created by YuanQuanTech on 2016/11/11.
//  Copyright © 2016年 John Lai. All rights reserved.
//

#import "JohnAlertManager.h"
#import "UIColor+Tools.h"

static JohnTopAlert *_alert = nil;
@implementation JohnAlertManager

+ (void)showAlertWithType:(JohnTopAlertType)type title:(NSString *)title{
    if (_alert) {
        [_alert removeFromSuperview];
    }
    _alert = [[JohnTopAlert alloc]init];
    [_alert alertWithType:type title:title];
    
    if (type == JohnTopAlertTypeSuccess) {
        _alert.alertBgColor = [UIColor whiteColor];
        _alert.textColor = [UIColor blackColor];
    }else if (type == JohnTopAlertTypeError){
        _alert.alertBgColor = [UIColor colorWithHexString:@"ff6460"];
    }else if (type == JohnTopAlertTypeMessage){
        _alert.alertBgColor = [UIColor whiteColor];
        _alert.textColor = [UIColor blackColor];
    }
    
    _alert.alertShowTime = 1.5f;
    [_alert show];
}

@end
