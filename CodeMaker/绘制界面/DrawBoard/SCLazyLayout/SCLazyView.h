
#import <UIKit/UIKit.h>
#import "DrawUIViewController.h"
@class SCLayoutModel;
@class DrawViewConstarint;

typedef enum {
	SCLayoutLeft,
	SCLayoutRight,
	SCLayoutTop,
	SCLayoutBottom,
	SCLayoutCenterX,
	SCLayoutCenterY,
	SCLayoutUnknow,
}SCLayoutTarget;

@interface SCLazyView : UIView

@property(nonatomic,assign)BOOL isActived;

@property(nonatomic,strong)NSString *uuid;

@property(nonatomic,strong)NSArray<SCLayoutModel*> *layouts;
@property (nonatomic,weak)NSMutableArray *models;
@property (nonatomic,weak)NSMutableDictionary *constarintOperation;

@property (nonatomic,weak)DrawUIViewController *viewController;
@property (nonatomic,copy)NSString *lastSelectControll;
- (void)reSelectControll:(DrawViewConstarint *)model;
- (void)runCommandSuccess;

- (void)actived;
- (void)unActived;

- (void)tapSelectSubView:(UIView *)view;

@end
