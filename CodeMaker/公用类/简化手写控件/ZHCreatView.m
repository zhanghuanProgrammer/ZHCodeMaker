#import "ZHCreatView.h"

@implementation ZHCreatView
+ (UIImageView *)createUIImageViewFrame:(CGRect)rect image:(UIImage *)image addToTarget:(UIView *)view{
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:rect];
    imageView.image=image;
    if (view) {
        [view addSubview:imageView];
    }
    return imageView;
}

+ (UILabel *)createUILabelFrame:(CGRect)rect text:(NSString *)text addToTarget:(UIView *)view{
    UILabel *label=[[UILabel alloc]initWithFrame:rect];
    label.text=text;
    if (view) {
        [view addSubview:label];
    }
    return  label;
}

+ (UIButton *)createUISystemButtonFrame:(CGRect)rect text:(NSString *)text target:(id)target action:(SEL)action addToTarget:(UIView *)view{
    UIButton *button=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button.frame=rect;
    [button setTitle:text forState:(UIControlStateNormal)];
    if (target) {
        [button addTarget:target action:action forControlEvents:1<<6];
    }
    if (view) {
        [view addSubview:button];
    }
    return button;
}

+ (UIButton *)createUICustomButtonFrame:(CGRect)rect text:(NSString *)text target:(id)target action:(SEL)action addToTarget:(UIView *)view{
    UIButton *button=[UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitle:text forState:(UIControlStateNormal)];
    if (target) {
        [button addTarget:target action:action forControlEvents:1<<6];
    }
    if (view) {
        [view addSubview:button];
    }
    return button;
}

+ (UITextField *)createUITextFieldFrame:(CGRect)rect text:(NSString *)text addToTarget:(UIView *)view{
    UITextField *textField=[[UITextField alloc]initWithFrame:rect];
    textField.text=text;
    if (view) {
        [view addSubview:textField];
    }
    return textField;
}

+ (UITextView *)createUITextViewFrame:(CGRect)rect text:(NSString *)text addToTarget:(UIView *)view{
    UITextView *textView=[[UITextView alloc]initWithFrame:rect];
    textView.text=text;
    if (view) {
        [view addSubview:textView];
    }
    return textView;
}

+ (UITableView *)createUITableViewFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view{
    UITableView *tableView=[[UITableView alloc]initWithFrame:rect];
    if (delegate) {
        tableView.delegate=delegate;
        tableView.dataSource=delegate;
    }
    if (view) {
        [view addSubview:tableView];
    }
    return  tableView;
}

+ (UIView *)createUIViewFrame:(CGRect)rect addToTarget:(UIView *)view{
    UIView *subview=[[UIView alloc]initWithFrame:rect];
    if (view) {
        [view addSubview:subview];
    }
    return subview;
}

+ (UISwitch *)createUISwicthFrame:(CGRect)rect on:(BOOL)on target:(id)target action:(SEL)action addToTarget:(UIView *)view{
    UISwitch *switchView=[[UISwitch alloc]initWithFrame:rect];
    switchView.on=on;
    if (target) {
        [switchView addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    }
    if (view) {
        [view addSubview:switchView];
    }
    return  switchView;
}

+ (UIWebView *)createUIWebViewFrame:(CGRect)rect  delegate:(id)delegate addToTarget:(UIView *)view{
    UIWebView *webView=[[UIWebView alloc]initWithFrame:rect];
    if (delegate) {
        webView.delegate=delegate;
    }
    if (view) {
        [view addSubview:webView];
    }
    return webView;
}

+ (UICollectionView *)createUICollectionViewFrame:(CGRect)rect  delegate:(id)delegate addToTarget:(UIView *)view{
    UICollectionView *collectionView=[[UICollectionView alloc]initWithFrame:rect collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionView.backgroundColor=[UIColor whiteColor];
    if (delegate) {
        collectionView.delegate=delegate;
        collectionView.dataSource=delegate;
    }
    if (view) {
        [view addSubview:collectionView];
    }
    return collectionView;
}

+ (UISegmentedControl *)createUISegmentedControlFrame:(CGRect)rect titles:(NSArray *)titles target:(id)target action:(SEL)action addToTarget:(UIView *)view{
    UISegmentedControl *segmentedControl=[[UISegmentedControl alloc]initWithFrame:rect];
    [segmentedControl removeAllSegments];
    for (NSString *title in titles) {
        if (title.length>0) {
            [segmentedControl insertSegmentWithTitle:title atIndex:segmentedControl.numberOfSegments animated:NO];
        }
    }
    if (target) {
        [segmentedControl addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    }
    if (view) {
        [view addSubview:segmentedControl];
    }
    return segmentedControl;
}

+ (UISlider *)createUISliderFrame:(CGRect)rect value:(CGFloat)value target:(id)target action:(SEL)action addToTarget:(UIView *)view{
    UISlider *slider=[[UISlider alloc]initWithFrame:rect];
    slider.value=value;
    if (target) {
        [slider addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    }
    if (view) {
        [view addSubview:slider];
    }
    return slider;
}

+ (UIActivityIndicatorView *)createUIActivityIndicatorViewFrame:(CGRect)rect status:(BOOL)status addToTarget:(UIView *)view{
    UIActivityIndicatorView *activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:rect];
    if (status) {
        [activityIndicatorView startAnimating];
    }else{
        [activityIndicatorView stopAnimating];
    }
    if (view) {
        [view addSubview:activityIndicatorView];
    }
    return activityIndicatorView;
}

+ (UIProgressView *)createUIProgressViewFrame:(CGRect)rect progress:(CGFloat)progress addToTarget:(UIView *)view{
    UIProgressView *progressView=[[UIProgressView alloc]initWithFrame:rect];
    progressView.progress=progress;
    if (view) {
        [view addSubview:progressView];
    }
    return progressView;
}

+ (UIPageControl *)createUIPageControlFrame:(CGRect)rect pagesCount:(NSInteger)pagesCount addToTarget:(UIView *)view{
    UIPageControl *pageControl=[[UIPageControl alloc]initWithFrame:rect];
    pageControl.numberOfPages=pagesCount;
    if (view) {
        [view addSubview:pageControl];
    }
    return pageControl;
}

+ (UIStepper *)createUIStepperFrame:(CGRect)rect value:(CGFloat)value minimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue stepValue:(CGFloat)stepValue addToTarget:(UIView *)view{
    UIStepper *stepper=[[UIStepper alloc]initWithFrame:rect];
    stepper.value=value;
    stepper.minimumValue=minimumValue;
    stepper.maximumValue=maximumValue;
    stepper.stepValue=stepValue;
    
    if (view) {
        [view addSubview:stepper];
    }
    return stepper;
}

+ (UIScrollView *)createUIScrollViewFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view{
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:rect];
    if (delegate) {
        scrollView.delegate=delegate;
    }
    if (view) {
        [view addSubview:scrollView];
    }
    return scrollView;
}

+ (UIDatePicker *)createUIDatePickerFrame:(CGRect)rect addToTarget:(UIView *)view{
    UIDatePicker *datePicker=[[UIDatePicker alloc]initWithFrame:rect];
    if (view) {
        [view addSubview:datePicker];
    }
    return datePicker;
}

+ (UIPickerView *)createUIPickerViewFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view{
    UIPickerView *pickerView=[[UIPickerView alloc]initWithFrame:rect];
    if (delegate) {
        pickerView.delegate=delegate;
    }
    if (view) {
        [view addSubview:pickerView];
    }
    return pickerView;
}

+ (UISearchBar *)createUISearchBarFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view{
    UISearchBar *searchBar=[[UISearchBar alloc]initWithFrame:rect];
    if (delegate) {
        searchBar.delegate=delegate;
    }
    if (view) {
        [view addSubview:searchBar];
    }
    return searchBar;
}

+ (MKMapView *)createMKMapViewFrame:(CGRect)rect addToTarget:(UIView *)view{
    MKMapView *mapview=[[MKMapView alloc]initWithFrame:rect];
    if (view) {
        [view addSubview:mapview];
    }
    return mapview;
}
@end
