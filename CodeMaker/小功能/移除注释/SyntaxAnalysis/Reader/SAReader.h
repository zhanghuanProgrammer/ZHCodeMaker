//
//  SAReader.h
//  语法分析器
//
//  Created by mac on 2018/2/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAReader : NSObject

@property (nonatomic,copy)NSString *codeText;
@property (nonatomic,strong)NSMutableArray *splits;

- (instancetype)initWithCodeText:(NSString *)codeText;

@end
