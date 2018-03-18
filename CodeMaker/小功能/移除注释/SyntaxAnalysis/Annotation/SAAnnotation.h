//
//  SAAnnotation.h
//  语法分析器
//
//  Created by mac on 2018/2/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAReader.h"

@interface SAAnnotation : NSObject

@property (nonatomic,strong)SAReader *reader;
@property (nonatomic,strong)NSMutableArray *annotations;

- (instancetype)initWithReader:(SAReader *)reader;

@end
