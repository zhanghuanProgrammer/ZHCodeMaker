//
//  SAAnnotation.m
//  语法分析器
//
//  Created by mac on 2018/2/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "SAAnnotation.h"

#define kIsEscape @"_$^isEscape^$_"

//注释的类型:
//1.单行// ,以\n结尾
//2.多行注释 /**/
//3.'',""中的不算,'',""以\n结尾
//4.单行//的优先级大于/*
//5./**/中嵌套的//不以\n结尾

typedef NS_ENUM(NSUInteger, SAAnnotationStatus) {
    SAAnnotationStatusNormal = 1 << 0,
    SAAnnotationStatusSingleLine = 1 << 1,   // 指单行// 开始
    SAAnnotationStatusMultipleLine = 1 << 2, // 指多行/* 开始
    SAAnnotationStatusiSingleQuote = 1 << 3, // 指单引旁' 开始
    SAAnnotationStatusiDoubleQuote = 1 << 4, // 指双引旁" 开始
    SAAnnotationStatusContact = 1 << 5,      // 指连接行数的'\'
    SAAnnotationStatusNewline = 1 << 6,      // 指换行符的'\n'
};

@interface SAAnnotation ()
@property (nonatomic,assign)SAAnnotationStatus annotationStatus;//当前状态
@property (nonatomic,strong)NSMutableString *annotationString;//当前的注释串
@property (nonatomic,assign)BOOL isAnnotationing;//是否是注释状态
@property (nonatomic,strong)NSMutableArray *isEscapeIndexs;//转义字符的下标集合
@property (nonatomic,strong)NSMutableArray *removeAnnotations;//所有的非注释集合,即去除注释的代码集合
@end

@implementation SAAnnotation

- (instancetype)initWithReader:(SAReader *)reader{
    self = [super init];
    if (self) {
        self.reader = reader;
        self.annotationStatus  = SAAnnotationStatusNormal;
        self.annotationString  = [NSMutableString string];
        self.annotations       = [NSMutableArray array];
        self.isEscapeIndexs    = [NSMutableArray array];
        self.removeAnnotations = [NSMutableArray array];
        self.isAnnotationing = NO;
        [self analysisAnnotation];
    }
    return self;
}

- (void)analysisAnnotation{
    BOOL preIsAdd = NO;
    for (NSInteger i=0,count = self.reader.splits.count; i<count; i++) {
        preIsAdd = [self refreshAnnotationStatus:i preIsAdd:preIsAdd];
    }
    [self.reader.splits setArray:self.removeAnnotations];
}

- (BOOL)refreshAnnotationStatus:(NSInteger)index preIsAdd:(BOOL)preIsAdd{
    NSString *keyWord = self.reader.splits[index];
    NSString *pre = @"";
    if (index > 0) pre = self.reader.splits[index-1];
    
    BOOL isAnnotationKeyWord = NO;
    BOOL isBreakAnnotationKeyWord = NO;
    BOOL isAnnotationingTemp = self.isAnnotationing;
    if (keyWord.length == 1) {
        if ([keyWord isEqualToString:@"\n"]) {
            isBreakAnnotationKeyWord = YES;
            //情况:
            //1:正常代码中的\n 不管它
            //2:''中出现\n 先判断里面是否有连接符\,如果有就去掉连接符,代表继续连接,否则,就认为''结束
            //3.""中出现\n 先判断里面是否有连接符\,如果有就去掉连接符,代表继续连接,否则,就认为""结束
            //4.//中出现\n 先判断里面是否有连接符\,如果有就去掉连接符,代表继续连接,否则,就认为//结束
            if(self.annotationStatus & SAAnnotationStatusContact){
                self.annotationStatus -= SAAnnotationStatusContact;
            }else{
                if (self.annotationStatus & SAAnnotationStatusSingleLine) {
                    self.annotationStatus -= SAAnnotationStatusSingleLine;
                    self.isAnnotationing = NO;
                    [self.removeAnnotations addObject:keyWord];
                }
                if (self.annotationStatus & SAAnnotationStatusiSingleQuote) {
                    self.annotationStatus -= SAAnnotationStatusiSingleQuote;
                }
                if (self.annotationStatus & SAAnnotationStatusiDoubleQuote) {
                    self.annotationStatus -= SAAnnotationStatusiDoubleQuote;
                }
            }
        }
        if ([keyWord isEqualToString:@"\\"]) {
            isBreakAnnotationKeyWord = YES;
            //情况:
            //1:正常代码中的单个\ 本身就是连接符,比如宏定义,不管它
            //2:正常代码中的转义字符\,比如宏定义
            //3:''中出现\ 添加连接符
            //4.""中出现\ 添加连接符
            //5.//中出现\ 添加连接符
            
            //处理特殊的情况 - 转义字符
            BOOL isEscape = YES;
            if (index < self.reader.splits.count - 1) {
                for (NSInteger j = index + 1; j < self.reader.splits.count; j++) {
                    NSString *next = self.reader.splits[j];
                    if ([next isEqualToString:@"\n"]) {
                        isEscape = NO;
                        break;
                    }
                    if (![next isEqualToString:@" "]) {
                        self.reader.splits[index] = keyWord = kIsEscape;
                        [self.isEscapeIndexs addObject:@(index)];
                        if ([self.reader.splits[index + 1] isEqualToString:@"\\"]) {
                            self.reader.splits[index + 1] = kIsEscape;
                            [self.isEscapeIndexs addObject:@(index + 1)];
                        }
                        break;
                    }
                }
            }
            if (!isEscape) {
                if ((self.annotationStatus & SAAnnotationStatusSingleLine) ||
                    (self.annotationStatus & SAAnnotationStatusiSingleQuote) ||
                    (self.annotationStatus & SAAnnotationStatusiDoubleQuote)) {
                    if(!(self.annotationStatus & SAAnnotationStatusContact)){
                        self.annotationStatus |= SAAnnotationStatusContact;
                    }
                }
            }
        }
        if ([keyWord isEqualToString:@"'"]) {
            isBreakAnnotationKeyWord = YES;
            //情况:
            //1:正常代码中的单个' 代表开始或者结束
            //2:正常代码中的转义字符\' 不管
            //3.""中出现' 不管
            //4./**/中出现' 不管
            //5.//中出现' 不管
            if (index > 0 && [self.isEscapeIndexs containsObject:@(index-1)]) {
                // do nothing
            }else{
                if ((self.annotationStatus & SAAnnotationStatusSingleLine) ||
                    (self.annotationStatus & SAAnnotationStatusMultipleLine) ||
                    (self.annotationStatus & SAAnnotationStatusiDoubleQuote)) {
                    // do nothing
                }else{
                    if(!(self.annotationStatus & SAAnnotationStatusiSingleQuote)){
                        self.annotationStatus |= SAAnnotationStatusiSingleQuote;
                    }else{
                        self.annotationStatus -= SAAnnotationStatusiSingleQuote;
                    }
                }
            }
        }
        if ([keyWord isEqualToString:@"\""]) {
            isBreakAnnotationKeyWord = YES;
            //情况:
            //1:正常代码中的单个" 代表开始或者结束
            //2:正常代码中的转义字符\",这个在前面做过处理会被过滤掉,不会进入这个方法
            //3.''中出现" 不管
            //4./**/中出现" 不管
            //5.//中出现" 不管
            if (index > 0 && [self.isEscapeIndexs containsObject:@(index-1)]) {
                // do nothing
            }else{
                if ((self.annotationStatus & SAAnnotationStatusSingleLine) ||
                    (self.annotationStatus & SAAnnotationStatusMultipleLine) ||
                    (self.annotationStatus & SAAnnotationStatusiSingleQuote)) {
                    // do nothing
                }else{
                    if(!(self.annotationStatus & SAAnnotationStatusiDoubleQuote)){
                        self.annotationStatus |= SAAnnotationStatusiDoubleQuote;
                    }else{
                        self.annotationStatus -= SAAnnotationStatusiDoubleQuote;
                    }
                }
            }
        }
    }
    
    if (!isBreakAnnotationKeyWord) {
        keyWord = [pre stringByAppendingString:keyWord];
        
        if (keyWord.length == 2){
            
            if ([keyWord isEqualToString:@"/*"]) {
                isAnnotationKeyWord = YES;
                //情况:
                //1:正常代码中的单个/* 代表开始
                //2.''中出现/* 不管
                //3./**/中出现/* 不管
                //4.//中出现/* 不管
                //5.""中出现/* 不管
                if ((self.annotationStatus & SAAnnotationStatusSingleLine) ||
                    (self.annotationStatus & SAAnnotationStatusMultipleLine) ||
                    (self.annotationStatus & SAAnnotationStatusiSingleQuote) ||
                    (self.annotationStatus & SAAnnotationStatusiDoubleQuote)) {
                    // do nothing
                }else{
                    self.annotationStatus |= SAAnnotationStatusMultipleLine;
                    self.isAnnotationing = YES;
                }
            }
            if ([keyWord isEqualToString:@"*/"]) {
                isAnnotationKeyWord = YES;
                //情况:
                //1:正常代码中的单个*/ 代表结束
                //2.''中出现*/ 不管
                //3.//中出现*/ 不管
                //4.""中出现*/ 不管
                if ((self.annotationStatus & SAAnnotationStatusSingleLine) ||
                    (self.annotationStatus & SAAnnotationStatusiSingleQuote) ||
                    (self.annotationStatus & SAAnnotationStatusiDoubleQuote)) {
                    // do nothing
                }else{
                    if((self.annotationStatus & SAAnnotationStatusMultipleLine)){
                        self.annotationStatus -= SAAnnotationStatusMultipleLine;
                        self.isAnnotationing = NO;
                    }
                }
            }
            if ([keyWord isEqualToString:@"//"]) {
                isAnnotationKeyWord = YES;
                //情况:
                //1:正常代码中的单个// 代表开始
                //2.''中出现// 不管
                //3./**/中出现// 不管
                //4.//中出现// 不管
                //5.""中出现// 不管
                if ((self.annotationStatus & SAAnnotationStatusSingleLine) ||
                    (self.annotationStatus & SAAnnotationStatusMultipleLine) ||
                    (self.annotationStatus & SAAnnotationStatusiSingleQuote) ||
                    (self.annotationStatus & SAAnnotationStatusiDoubleQuote)) {
                    // do nothing
                }else{
                    self.annotationStatus |= SAAnnotationStatusSingleLine;
                    self.isAnnotationing = YES;
                }
            }
        }
    }
    NSString *orginal = self.reader.splits[index];
    if ([self.isEscapeIndexs containsObject:@(index)]) {
        orginal = @"\\";
    }
    BOOL isAdd = NO;
    if (self.isAnnotationing) {
        if (isAnnotationKeyWord && !preIsAdd) {
            [self.annotationString appendString:keyWord];
        }else{
            [self.annotationString appendString:orginal];
        }
        isAdd = YES;
    }
    if (isAnnotationingTemp && !self.isAnnotationing) {
        if (!isBreakAnnotationKeyWord) {
            [self.annotationString appendString:keyWord];//虽然是注释结尾,也得加上最后一个字符 如*/ , \n就不用加了
        }
        isAdd = YES;
        [self.annotations addObject:[self.annotationString copy]];
        [self.annotationString setString:@""];
    }
    if (!isAnnotationingTemp && self.isAnnotationing) {
        [self.removeAnnotations removeLastObject];
    }
    if (!isAdd) {
        [self.removeAnnotations addObject:orginal];
    }
    return isAdd;
}

@end
