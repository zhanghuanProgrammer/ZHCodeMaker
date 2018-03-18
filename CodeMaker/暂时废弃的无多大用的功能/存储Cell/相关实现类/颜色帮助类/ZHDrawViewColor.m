#import "ZHDrawViewColor.h"
#import "UIColor+Wonderful.h"
#import "UIColor+ZH.h"

@implementation ZHDrawViewColor

+ (UIColor *)getRectColorWithViewCategory:(NSString *)categoryView{
    
    if ([categoryView isEqualToString:@"label"]){
        return Wonderful_RedColor3;
    }
    if ([categoryView isEqualToString:@"button"]){
        return Wonderful_CyanColor10;
    }
    if ([categoryView isEqualToString:@"imageView"]){
        return Wonderful_BlueColor4;
    }
    if ([categoryView isEqualToString:@"slider"]){
        return Wonderful_BlueColor5;
    }
    if ([categoryView isEqualToString:@"tableView"]){
        return Wonderful_GreenColor7;
    }
    if ([categoryView isEqualToString:@"collectionView"]){
        return Wonderful_YelloeColor5;
    }
    if ([categoryView isEqualToString:@"view"]){
        return Wonderful_PurpleColor6;
    }
    if ([categoryView isEqualToString:@"segmentedControl"]){
        return Wonderful_GrayColor5;
    }
    if ([categoryView isEqualToString:@"textField"]){
        return Wonderful_CyanColor7;
    }
    if ([categoryView isEqualToString:@"switch"]){
        return Wonderful_BrownColor5;
    }
    if ([categoryView isEqualToString:@"activityIndicatorView"]){
        return Wonderful_PinkColor3;
    }
    if ([categoryView isEqualToString:@"progressView"]){
        return Wonderful_RedColor10;
    }
    if ([categoryView isEqualToString:@"pageControl"]){
        return Wonderful_CyanColor1;
    }
    if ([categoryView isEqualToString:@"stepper"]){
        return Wonderful_BlueColor8;
    }
    if ([categoryView isEqualToString:@"textView"]){
        return Wonderful_GreenColor3;
    }
    if ([categoryView isEqualToString:@"scrollView"]){
        return Wonderful_GreenColor8;
    }
    if ([categoryView isEqualToString:@"datePicker"]){
        return Wonderful_PurpleColor2;
    }
    if ([categoryView isEqualToString:@"pickerView"]){
        return Wonderful_PinkColor7;
    }
    if ([categoryView isEqualToString:@"mapView"]){
        return Wonderful_BrownColor9;
    }
    if ([categoryView isEqualToString:@"searchBar"]){
        return Wonderful_PinkColor2;
    }
    if ([categoryView isEqualToString:@"webView"]){
        return Wonderful_RedColor5;
    }
    return nil;
}

+ (UIColor *)getStringColorWithViewCategory:(NSString *)categoryView{
    
    UIColor *rectColor=[self getRectColorWithViewCategory:categoryView];
    if (rectColor) {
        return [rectColor colorInvert];
    }
    return nil;
}

@end
