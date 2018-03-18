//
//  SAReader.m
//  语法分析器
//
//  Created by mac on 2018/2/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "SAReader.h"

@implementation SAReader

- (instancetype)initWithCodeText:(NSString *)codeText{
    self = [super init];
    if (self) {
        self.codeText = codeText;
        if (self.codeText.length > 0) {
            [self splitCodeText];
        }else{
            NSLog(@"%@",@"文本不能为空!");
        }
    }
    return self;
}

- (void)splitCodeText{
    NSMutableArray *splits = [NSMutableArray array];
    NSMutableString *variableName = [NSMutableString string];
    for (NSInteger i=0,length = self.codeText.length; i<length; i++) {
        unichar charStr = [self.codeText characterAtIndex:i];
        if ([self isVariableNameChar:charStr]) {
            [variableName appendFormat:@"%C",charStr];
        }else{
            if (variableName.length > 0) {
                [splits addObject:[variableName copy]];
                [variableName setString:@""];
            }
            [splits addObject:[NSString stringWithFormat:@"%C",charStr]];
        }
    }
    //最后的也要加上
    if (variableName.length > 0) {
        [splits addObject:[variableName copy]];
        [variableName setString:@""];
    }
    self.splits = [splits mutableCopy];
}

/**判断字符是不是变量名命名的字符 下划线,数字,字母*/
- (BOOL)isVariableNameChar:(unichar)charStr{
    if ((charStr > 128) || (charStr == '_') || (charStr >= '0' && charStr <= '9') ||
        (charStr >= 'a' && charStr <= 'z') || (charStr >= 'A' && charStr <= 'Z')) {
        return YES;
    }
    return NO;
}

@end
