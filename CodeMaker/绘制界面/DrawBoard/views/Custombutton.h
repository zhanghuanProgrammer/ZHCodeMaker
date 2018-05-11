//
//  Custombutton.h
//  Tuozmz
//
//  Created by CiHon-IOS2 on 16/9/23.
//  Copyright © 2016年 walkingzmz. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RC_DB_VERSION @"0.2"
@interface Custombutton : UIView
{
    BOOL _isDragging;
    BOOL _singleTapBeenCanceled;
    CGPoint _beginLocation;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;

}
@property (nonatomic) BOOL draggable;
@property (nonatomic) BOOL autoDocking;

@property (nonatomic, copy) void(^longPressBlock)(Custombutton *button);
@property (nonatomic, copy) void(^tapBlock)(Custombutton *button);
@property (nonatomic, copy) void(^doubleTapBlock)(Custombutton *button);

@property (nonatomic, copy) void(^draggingBlock)(Custombutton *button);
@property (nonatomic, copy) void(^dragDoneBlock)(Custombutton *button);

@property (nonatomic, copy) void(^autoDockingBlock)(Custombutton *button);
@property (nonatomic, copy) void(^autoDockingDoneBlock)(Custombutton *button);

- (id)initInKeyWindowWithFrame:(CGRect)frame;
- (id)initInView:(id)view WithFrame:(CGRect)frame;

- (void)setBackgroundImage:(NSString *)image;
- (BOOL)isDragging;

+ (NSString *)version;

+ (void)removeAllFromKeyWindow;
+ (void)removeAllFromView:(id)superView;

@end
