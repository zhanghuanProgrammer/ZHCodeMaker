#import "ZHDrawSubViewHelp.h"
#import "ZHCreatView.h"

@implementation ZHDrawSubViewHelp

+ (UIView *)getViewWithFrame:(CGRect)frame withViewCategory:(NSString *)categoryView{
    
    if ([categoryView isEqualToString:@"label"]){
        UILabel *label=[ZHCreatView createUILabelFrame:frame text:@"label" addToTarget:nil];
        label.font=[UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth=YES;
        return label;
    }
    if ([categoryView isEqualToString:@"button"]){
        UIButton *button= [ZHCreatView createUISystemButtonFrame:frame text:@"button" target:nil action:nil addToTarget:nil];
        button.titleLabel.font=[UIFont systemFontOfSize:12];
        button.titleLabel.adjustsFontSizeToFitWidth=YES;
        return button;
    }
    if ([categoryView isEqualToString:@"imageView"]){
        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"uiimageview"] addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"slider"]){
        return [ZHCreatView createUISliderFrame:frame value:0.5 target:nil action:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"tableView"]){
        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"tableView"] addToTarget:nil];
//        return [ZHCreatView createUITableViewFrame:frame delegate:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"collectionView"]){
        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"collectionView"] addToTarget:nil];
//        return [ZHCreatView createUICollectionViewFrame:frame delegate:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"view"]){
        
        UILabel *label=[ZHCreatView createUILabelFrame:frame text:@"view" addToTarget:nil];
        label.font=[UIFont systemFontOfSize:12];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        label.adjustsFontSizeToFitWidth=YES;
        return label;
//        return [ZHCreatView createUIViewFrame:frame addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"segmentedControl"]){
        return [ZHCreatView createUISegmentedControlFrame:frame titles:@[@"first",@"second"] target:nil action:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"textField"]){
//        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"textField"] addToTarget:nil];
        UITextField *textField=[ZHCreatView createUITextFieldFrame:frame text:nil addToTarget:nil];
        textField.text=@"textField";
        textField.layer.cornerRadius=5;
        textField.layer.borderColor=[[UIColor grayColor] colorWithAlphaComponent:0.7].CGColor;
        textField.layer.borderWidth=0.5;
        textField.layer.masksToBounds=YES;
        return textField;
    }
    if ([categoryView isEqualToString:@"switch"]){
        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"switch"] addToTarget:nil];
//        return [ZHCreatView createUISwicthFrame:frame on:YES target:nil action:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"activityIndicatorView"]){
        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"activityIndicatorView"] addToTarget:nil];
//        return [ZHCreatView createUIActivityIndicatorViewFrame:frame status:NO addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"progressView"]){
        return [ZHCreatView createUIProgressViewFrame:frame progress:0.5 addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"pageControl"]){
        UIPageControl *pageControl=[ZHCreatView createUIPageControlFrame:frame pagesCount:5 addToTarget:nil];
        CGPoint center=pageControl.center;
        [pageControl sizeToFit];
        pageControl.center=center;
        return pageControl;
    }
    if ([categoryView isEqualToString:@"stepper"]){
        return [ZHCreatView createUIStepperFrame:frame value:5 minimumValue:1 maximumValue:10 stepValue:5 addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"textView"]){
//        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"textView"] addToTarget:nil];
        UITextView *textView=[ZHCreatView createUITextViewFrame:frame text:@"textView" addToTarget:nil];
        textView.text=@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
        textView.font=[UIFont systemFontOfSize:12];
        textView.layer.borderColor=[[UIColor grayColor] colorWithAlphaComponent:0.7].CGColor;
        textView.layer.borderWidth=0.5;
        textView.layer.masksToBounds=YES;
        UIView *split=[[UIView alloc]initWithFrame:CGRectMake(textView.width-5, 3, 2, textView.height-6)];
        split.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.7];
        [textView addSubview:split];
        return textView;
    }
    if ([categoryView isEqualToString:@"scrollView"]){
        UILabel *scrollView=[ZHCreatView createUILabelFrame:frame text:@"scrollView" addToTarget:nil];
        scrollView.font=[UIFont systemFontOfSize:12];
        scrollView.textAlignment=NSTextAlignmentCenter;
        scrollView.textColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        scrollView.adjustsFontSizeToFitWidth=YES;
        scrollView.backgroundColor=[UIColor whiteColor];
        scrollView.layer.borderColor=[[UIColor grayColor] colorWithAlphaComponent:0.7].CGColor;
        scrollView.layer.borderWidth=0.5;
        scrollView.layer.masksToBounds=YES;
        UIView *split=[[UIView alloc]initWithFrame:CGRectMake(scrollView.width-5, 3, 2, scrollView.height-6)];
        split.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.7];
        [scrollView addSubview:split];
        return scrollView;
    }
    if ([categoryView isEqualToString:@"datePicker"]){
        UIDatePicker *datePicker=[ZHCreatView createUIDatePickerFrame:frame addToTarget:nil];
        datePicker.clipsToBounds=YES;
        datePicker.alpha=0.5;
        return datePicker;
    }
    if ([categoryView isEqualToString:@"pickerView"]){
        return [ZHCreatView createUIImageViewFrame:frame image:[UIImage imageNamed:@"pickerView"] addToTarget:nil];
//        return [ZHCreatView createUIPickerViewFrame:frame delegate:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"mapView"]){
        return [ZHCreatView createMKMapViewFrame:frame addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"searchBar"]){
        return [ZHCreatView createUISearchBarFrame:frame delegate:nil addToTarget:nil];
    }
    if ([categoryView isEqualToString:@"webView"]){
        UILabel *label=[ZHCreatView createUILabelFrame:frame text:@"webView" addToTarget:nil];
        label.font=[UIFont systemFontOfSize:12];
        label.textAlignment=NSTextAlignmentCenter;
        label.textColor=[[UIColor grayColor]colorWithAlphaComponent:0.6];
        label.adjustsFontSizeToFitWidth=YES;
        return label;
//        return [ZHCreatView createUIWebViewFrame:frame delegate:nil addToTarget:nil];
    }
    return nil;
}

@end
