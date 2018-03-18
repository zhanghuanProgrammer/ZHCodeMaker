//
//  DrawViewConstarint.h
//  CodeMaker
//
//  Created by mac on 2018/3/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawViewConstarint : NSObject<NSCoding>

@property (nonatomic,copy)NSString *firstAttribute;
@property (nonatomic,copy)NSString *firstItem;
@property (nonatomic,copy)NSString *secondAttribute;
@property (nonatomic,copy)NSString *secondItem;
@property (nonatomic,copy)NSString *multiplier;
@property (nonatomic,copy)NSString *constant;

- (instancetype)copyNew;
- (instancetype)reSetValue:(DrawViewConstarint*)object;
- (BOOL)isRelatedSame:(DrawViewConstarint*)object;
- (BOOL)isEqualTo:(id)object;
- (NSString *)logDescription;
- (NSString *)selectDescription;
- (NSString *)firstControllIndex;
- (NSString *)secondControllIndex;

- (BOOL)isInConstarint;

@end
