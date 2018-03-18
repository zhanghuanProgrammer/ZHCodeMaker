#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ZHCreatView : NSObject

+ (UIImageView *)createUIImageViewFrame:(CGRect)rect image:(UIImage *)image addToTarget:(UIView *)view;

+ (UILabel *)createUILabelFrame:(CGRect)rect text:(NSString *)text addToTarget:(UIView *)view;

+ (UIButton *)createUISystemButtonFrame:(CGRect)rect text:(NSString *)text target:(id)target action:(SEL)action addToTarget:(UIView *)view;

+ (UIButton *)createUICustomButtonFrame:(CGRect)rect text:(NSString *)text target:(id)target action:(SEL)action addToTarget:(UIView *)view;

+ (UITextField *)createUITextFieldFrame:(CGRect)rect text:(NSString *)text addToTarget:(UIView *)view;

+ (UITextView *)createUITextViewFrame:(CGRect)rect text:(NSString *)text addToTarget:(UIView *)view;

+ (UITableView *)createUITableViewFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view;

+ (UIView *)createUIViewFrame:(CGRect)rect addToTarget:(UIView *)view;

+ (UISwitch *)createUISwicthFrame:(CGRect)rect on:(BOOL)on target:(id)target action:(SEL)action addToTarget:(UIView *)view;

+ (UIWebView *)createUIWebViewFrame:(CGRect)rect  delegate:(id)delegate addToTarget:(UIView *)view;

+ (UICollectionView *)createUICollectionViewFrame:(CGRect)rect  delegate:(id)delegate addToTarget:(UIView *)view;

+ (UISegmentedControl *)createUISegmentedControlFrame:(CGRect)rect titles:(NSArray *)titles target:(id)target action:(SEL)action addToTarget:(UIView *)view;

+ (UISlider *)createUISliderFrame:(CGRect)rect value:(CGFloat)value target:(id)target action:(SEL)action addToTarget:(UIView *)view;

+ (UIActivityIndicatorView *)createUIActivityIndicatorViewFrame:(CGRect)rect status:(BOOL)status addToTarget:(UIView *)view;

+ (UIProgressView *)createUIProgressViewFrame:(CGRect)rect progress:(CGFloat)progress addToTarget:(UIView *)view;

+ (UIPageControl *)createUIPageControlFrame:(CGRect)rect pagesCount:(NSInteger)pagesCount addToTarget:(UIView *)view;

+ (UIStepper *)createUIStepperFrame:(CGRect)rect value:(CGFloat)value minimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue stepValue:(CGFloat)stepValue addToTarget:(UIView *)view;

+ (UIScrollView *)createUIScrollViewFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view;

+ (UIDatePicker *)createUIDatePickerFrame:(CGRect)rect addToTarget:(UIView *)view;

+ (UIPickerView *)createUIPickerViewFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view;

+ (UISearchBar *)createUISearchBarFrame:(CGRect)rect delegate:(id)delegate addToTarget:(UIView *)view;

+ (MKMapView *)createMKMapViewFrame:(CGRect)rect addToTarget:(UIView *)view;
@end
