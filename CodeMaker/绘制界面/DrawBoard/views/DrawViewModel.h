#import <UIKit/UIKit.h>
#import "DrawUIViewController.h"

@interface DrawViewModel : NSObject <NSCoding>
@property (nonatomic,copy)NSString *relateViewIp;
@property (nonatomic,assign)CGRect frame;
@property (nonatomic,copy)NSString *idStr;
@property (nonatomic,copy)NSString *categoryView;
@property (nonatomic,strong)UIView *relateView;
@property (nonatomic,weak)DrawUIViewController *relateVC;
@property (nonatomic,copy)NSString *superViewIdStr;
@property (nonatomic,strong)NSMutableArray *commands;
@property (nonatomic,assign)CGFloat x;
@property (nonatomic,assign)CGFloat y;
@property (nonatomic,assign)CGFloat w;
@property (nonatomic,assign)CGFloat h;
- (instancetype)copyNew;
- (void)addOrUpdateCommand:(id)command;
- (void)ifExsitRemove:(id)command;
- (NSString *)conmandText;
- (NSString *)changeKeyValueCommand:(NSDictionary *)command;
- (void)reOpenViewIpAjust:(NSArray *)models;
- (void)deleteOverDataViewIp:(NSArray *)models relateViewIP:(NSString *)relateViewIP;
@end
