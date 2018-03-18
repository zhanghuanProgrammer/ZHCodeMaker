#import "ZHCreatRegex.h"

@interface ZHCreatRegex ()
@property (nonatomic,strong)NSMutableArray *regexArrM;
@property (nonatomic,copy)NSString *prefix;
@property (nonatomic,copy)NSString *suffix;
@end
@implementation ZHCreatRegex

- (NSString *)regexString{
    return [NSString stringWithFormat:@"%@",self];
}
- (NSString *)description{
    NSMutableString *regexStrM=[NSMutableString string];
    if (self.prefix.length>0) [regexStrM appendString:self.prefix];
    if (self.regexArrM.count>0) {
        for (NSString *regex in self.regexArrM) {
            [regexStrM appendString:regex];
        }
    }else{
        [regexStrM appendString:@".*"];
    }
    if (self.suffix.length>0) [regexStrM appendString:self.suffix];
    return regexStrM;
}

- (NSMutableArray *)regexArrM{
    if (!_regexArrM) {
        _regexArrM=[NSMutableArray array];
    }
    return _regexArrM;
}

/**
 *  链式语法的经典之处:
 1.利用了属性点语法的来获取这个其实不是属性和成员变量,但在语法上构成了类似点语法
 2.返回参数,返回的是一个block,而block里面的参数形式,却依然保持c语言的风格
 3.block的传递模式,在这个函数里面,其实它返回的是一个block,那么外边的点语法括号中,就可以使用这个block,并且在括号里面写参数
 4.block有个优势,就是可以存储代码块,那么在外边写好的参数,就可以传递到这个(返回的)代码块中,这个代码块进行逻辑处理
 5.更加经典的就是,这个代码块的block,它还有一个返回参数,那么,利用这个返回参数,我们就可以把自己给返回,也就是说creatRegex.hasPrefix(@"123") 其实返回的不是hasPrefix这个属性,而是返回一个block的返回参数,那么这个参数就可以设置为自己了,于是衍生出creatRegex.hasPrefix(@"123").hasPrefix(@"123")=(creatRegex.hasPrefix(@"123")).hasPrefix(@"123")=self.hasPrefix(@"123")=self;但是里面就可以做多层逻辑了
 */
/**以某个字符串为前缀*/
- (ZHCreatRegex * (^)(NSString *prefix))hasPrefix{
    return ^id(id prefix) {
        NSString *error=[NSString stringWithFormat:@"不能同时以两个字符串开头 %@",self.prefix];
        NSAssert(!(self.prefix.length>0), error);
        self.prefix=[NSString stringWithFormat:@"^%@",prefix];
        return self;
    };
}
/**以某个字符串为后缀*/
- (ZHCreatRegex * (^)(NSString *suffix))hasSuffix{
    return ^id(id suffix) {
        NSString *error=[NSString stringWithFormat:@"不能同时以两个字符串结尾 %@",self.suffix];
        NSAssert(!(self.suffix.length>0), error);
        self.suffix=[NSString stringWithFormat:@"%@$",suffix];
        return self;
    };
}
/**包含某个字符串*/
- (ZHCreatRegex * (^)(NSString *contain))containStr{
    return ^id(id contain) {
        [self.regexArrM addObject:contain];
        return self;
    };
}
/**最多有一个字符*/
- (ZHCreatRegex * (^)(unichar mostOne))mostOneCharacter{
    return ^id(unichar mostOne) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"%C?",mostOne]];
        return self;
    };
}
/**最多有一个字符串*/
- (ZHCreatRegex * (^)(NSString *string))mostOneString{
    return ^id(NSString *string) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"(%@)?",string]];
        return self;
    };
}
/**至少有一个字符*/
- (ZHCreatRegex * (^)(unichar atLeastOne))atLeastOneCharacter{
    return ^id(unichar atLeastOne) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"%C+",atLeastOne]];
        return self;
    };
}
/**至少有一个字符串*/
- (ZHCreatRegex * (^)(NSString *string))atLeastOneString{
    return ^id(NSString *string) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"(%@)+",string]];
        return self;
    };
}
/**可能有一个或多个字符*/
- (ZHCreatRegex * (^)(unichar may))mayHasCharacter{
    return ^id(unichar may) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"%C*",may]];
        return self;
    };
}
/**可能有一个或多个字符串*/
- (ZHCreatRegex * (^)(NSString *string))mayHasString{
    return ^id(NSString *string) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"(%@)*",string]];
        return self;
    };
}
/**有n个相同字符ch*/
- (ZHCreatRegex * (^)(unichar ch,NSUInteger count))countMultipleCharacter{
    return ^id(unichar ch,NSUInteger count) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"%C{%lu}",ch,count]];
        return self;
    };
}
/**有n个相同字符串*/
- (ZHCreatRegex * (^)(NSString *string,NSUInteger count))countMultipleString{
    return ^id(NSString *string,NSUInteger count) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"(%@){%lu}",string,count]];
        return self;
    };
}
/**有m-n个相同字符ch*/
- (ZHCreatRegex * (^)(unichar ch,NSUInteger m,NSUInteger n))between_m_n_MultipleCharacter{
    return ^id(unichar ch,NSUInteger m,NSUInteger n) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"%C{%lu,%lu}",ch,m,n]];
        return self;
    };
}
/**有m-n个相同字符串*/
- (ZHCreatRegex * (^)(NSString *string,NSUInteger m,NSUInteger n))between_m_n_MultipleString{
    return ^id(NSString *string,NSUInteger m,NSUInteger n) {
        [self.regexArrM addObject:[NSString stringWithFormat:@"(%@){%lu,%lu}",string,m,n]];
        return self;
    };
}


/**一个字符串中的一个*/
- (ZHCreatRegex * (^)(NSString *String))enumOneInString{
    return ^id(NSString *String) {
        NSMutableArray *arrM=[NSMutableArray array];
        unichar ch;
        for (NSInteger i=0; i<String.length; i++) {
            ch=[String characterAtIndex:i];
            [arrM addObject:[NSString stringWithFormat:@"%C",ch]];
        }
        if (arrM.count>0) {
            [self.regexArrM addObject:[NSString stringWithFormat:@"(%@)",[arrM componentsJoinedByString:@"|"]]];
        }
        return self;
    };
}
/**多个字符串中的一个*/
- (ZHCreatRegex * (^)(NSArray *multipleString))orOneInMultipleString{
    return ^id(NSArray *multipleString) {
        NSMutableArray *arrM=[NSMutableArray array];
        for (NSString *str in multipleString) {
            if (str.length>0) {
                [arrM addObject:str];
            }
        }
        if (arrM.count>0) {
            [self.regexArrM addObject:[NSString stringWithFormat:@"(%@)",[arrM componentsJoinedByString:@"|"]]];
        }
        return self;
    };
}

- (ZHCreatRegex * (^)(NSArray *startCharacters,NSArray *endCharacters,BOOL yesOrNo))enumOneBetween_m_n_Character_yesOrNo{
    return ^id(NSArray *startCharacters,NSArray *endCharacters,BOOL yesOrNo) {
        
        NSAssert(!(startCharacters.count==0||endCharacters.count==0), @"enumOneBetween_m_n_Character函数中,两个参数数组中存在空数组");
        NSAssert(!(startCharacters.count!=endCharacters.count), @"enumOneBetween_m_n_Character函数中,两个参数数组(startCharacters,endCharacters)个数不等");
        
        for (NSString *str in startCharacters) {
            if (str.length!=1) {
                NSAssert(!(startCharacters.count!=endCharacters.count), @"enumOneBetween_m_n_Character函数中,两个参数数组(startCharacters)中的字符长度不为1");
            }
        }
        for (NSString *str in endCharacters) {
            if (str.length!=1) {
                NSAssert(!(startCharacters.count!=endCharacters.count), @"enumOneBetween_m_n_Character函数中,两个参数数组(endCharacters)中的字符长度不为1");
            }
        }
        NSMutableArray *arrM=[NSMutableArray array];
        for (NSInteger i=0; i<startCharacters.count&&i<endCharacters.count; i++) {
            NSString *start=startCharacters[i];
            NSString *end=endCharacters[i];
            
            NSAssert(!([start compare:end]==NSOrderedDescending), @"enumOneBetween_m_n_Character函数中,两个参数数组(startCharacters,endCharacters)中存在字符start小于end");
            
            [arrM addObject:[NSString stringWithFormat:@"%@-%@",start,end]];
        }
        if (arrM.count>0) {
            if (yesOrNo) {
                [self.regexArrM addObject:[NSString stringWithFormat:@"[%@]",[arrM componentsJoinedByString:@""]]];
            }else{
                [self.regexArrM addObject:[NSString stringWithFormat:@"[^%@]",[arrM componentsJoinedByString:@""]]];
            }
        }
        return self;
    };
}
/**某个范围内的一个字符*/
- (ZHCreatRegex * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character{
    return ^id(NSArray *startCharacters,NSArray *endCharacters) {
        return self.enumOneBetween_m_n_Character_yesOrNo(startCharacters,endCharacters,YES);
    };
}
/**不是某个范围内的任何一个字符*/
- (ZHCreatRegex * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character_NO{
    return ^id(NSArray *startCharacters,NSArray *endCharacters) {
        return self.enumOneBetween_m_n_Character_yesOrNo(startCharacters,endCharacters,NO);
    };
}


/**是一个数字*/
- (ZHCreatRegex *)number{
    [self.regexArrM addObject:@"\\d"];
    return self;
}
/**不是一个数字*/
- (ZHCreatRegex *)number_No{
    [self.regexArrM addObject:@"\\D"];
    return self;
}
/**是一个字母*/
- (ZHCreatRegex *)a_z_Or_A_Z{
    [self.regexArrM addObject:@"\\w"];
    return self;
}
/**不是一个字母*/
- (ZHCreatRegex *)a_z_Or_A_Z_NO{
    [self.regexArrM addObject:@"\\W"];
    return self;
}




#pragma mark --------获取简短的正则表达式字符串
/**以某个字符串为前缀*/
- (NSString * (^)(NSString *prefix))hasPrefix_Get{
    return ^id(id prefix) {
        return [NSString stringWithFormat:@"^%@",prefix];
    };
}
/**以某个字符串为后缀*/
- (NSString * (^)(NSString *suffix))hasSuffix_Get{
    return ^id(id suffix) {
        return [NSString stringWithFormat:@"%@$",suffix];
    };
}

/**最多有一个字符*/
- (NSString * (^)(unichar mostOne))mostOneCharacter_Get{
    return ^id(unichar mostOne) {
        return [NSString stringWithFormat:@"%C?",mostOne];
    };
}
/**最多有一个字符串*/
- (NSString * (^)(NSString *string))mostOneString_Get{
    return ^id(NSString *string) {
        return [NSString stringWithFormat:@"(%@)?",string];
    };
}
/**至少有一个字符*/
- (NSString * (^)(unichar atLeastOne))atLeastOneCharacter_Get{
    return ^id(unichar atLeastOne) {
        return [NSString stringWithFormat:@"%C+",atLeastOne];
    };
}
/**至少有一个字符串*/
- (NSString * (^)(NSString *string))atLeastOneString_Get{
    return ^id(NSString *string) {
        return [NSString stringWithFormat:@"(%@)+",string];
    };
}
/**可能有一个或多个字符*/
- (NSString * (^)(unichar may))mayHasCharacter_Get{
    return ^id(unichar may) {
        return [NSString stringWithFormat:@"%C*",may];
    };
}
/**可能有一个或多个字符串*/
- (NSString * (^)(NSString *string))mayHasString_Get{
    return ^id(NSString *string) {
        return [NSString stringWithFormat:@"(%@)*",string];
    };
}


/**有n个相同字符ch*/
- (NSString * (^)(unichar ch,NSUInteger count))countMultipleCharacter_Get{
    return ^id(unichar ch,NSUInteger count) {
        return [NSString stringWithFormat:@"%C{%lu}",ch,count];
    };
}
/**有n个相同字符串*/
- (NSString * (^)(NSString *string,NSUInteger count))countMultipleString_Get{
    return ^id(NSString *string,NSUInteger count) {
        return [NSString stringWithFormat:@"(%@){%lu}",string,count];
    };
}
/**有m-n个相同字符ch*/
- (NSString * (^)(unichar ch,NSUInteger m,NSUInteger n))between_m_n_MultipleCharacter_Get{
    return ^id(unichar ch,NSUInteger m,NSUInteger n) {
        return [NSString stringWithFormat:@"%C{%lu,%lu}",ch,m,n];
    };
}
/**有m-n个相同字符串*/
- (NSString * (^)(NSString *string,NSUInteger m,NSUInteger n))between_m_n_MultipleString_Get{
    return ^id(NSString *string,NSUInteger m,NSUInteger n) {
        return [NSString stringWithFormat:@"(%@){%lu,%lu}",string,m,n];
    };
}


/**一个字符串中的一个*/
- (NSString * (^)(NSString *String))enumOneInString_Get{
    return ^id(NSString *String) {
        NSMutableArray *arrM=[NSMutableArray array];
        unichar ch;
        for (NSInteger i=0; i<String.length; i++) {
            ch=[String characterAtIndex:i];
            [arrM addObject:[NSString stringWithFormat:@"%C",ch]];
        }
        if (arrM.count>0) {
            return [NSString stringWithFormat:@"(%@)",[arrM componentsJoinedByString:@"|"]];
        }
        return @"";
    };
}
/**多个字符串中的一个*/
- (NSString * (^)(NSArray *multipleString))orOneInMultipleString_Get{
    return ^id(NSArray *multipleString) {
        NSMutableArray *arrM=[NSMutableArray array];
        for (NSString *str in multipleString) {
            if (str.length>0) {
                [arrM addObject:str];
            }
        }
        if (arrM.count>0) {
            return [NSString stringWithFormat:@"(%@)",[arrM componentsJoinedByString:@"|"]];
        }
        return @"";
    };
}
- (NSString * (^)(NSArray *startCharacters,NSArray *endCharacters,BOOL yesOrNo))enumOneBetween_m_n_Character_yesOrNo_Get{
    return ^id(NSArray *startCharacters,NSArray *endCharacters,BOOL yesOrNo) {
        
        NSAssert(!(startCharacters.count==0||endCharacters.count==0), @"enumOneBetween_m_n_Character函数中,两个参数数组中存在空数组");
        NSAssert(!(startCharacters.count!=endCharacters.count), @"enumOneBetween_m_n_Character函数中,两个参数数组(startCharacters,endCharacters)个数不等");
        
        for (NSString *str in startCharacters) {
            if (str.length!=1) {
                NSAssert(!(startCharacters.count!=endCharacters.count), @"enumOneBetween_m_n_Character函数中,两个参数数组(startCharacters)中的字符长度不为1");
            }
        }
        for (NSString *str in endCharacters) {
            if (str.length!=1) {
                NSAssert(!(startCharacters.count!=endCharacters.count), @"enumOneBetween_m_n_Character函数中,两个参数数组(endCharacters)中的字符长度不为1");
            }
        }
        NSMutableArray *arrM=[NSMutableArray array];
        for (NSInteger i=0; i<startCharacters.count&&i<endCharacters.count; i++) {
            NSString *start=startCharacters[i];
            NSString *end=endCharacters[i];
            
            NSAssert(!([start compare:end]==NSOrderedDescending), @"enumOneBetween_m_n_Character函数中,两个参数数组(startCharacters,endCharacters)中存在字符start小于end");
            
            [arrM addObject:[NSString stringWithFormat:@"%@-%@",start,end]];
        }
        if (arrM.count>0) {
            if (yesOrNo) {
                return [NSString stringWithFormat:@"[%@]",[arrM componentsJoinedByString:@""]];
            }else{
                return [NSString stringWithFormat:@"[^%@]",[arrM componentsJoinedByString:@""]];
            }
        }
        return @"";
    };
}
/**某个范围内的一个字符*/
- (NSString * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character_Get{
    return ^id(NSArray *startCharacters,NSArray *endCharacters) {
        return self.enumOneBetween_m_n_Character_yesOrNo_Get(startCharacters,endCharacters,YES);
    };
}
/**不是某个范围内的任何一个字符*/
- (NSString * (^)(NSArray *startCharacters,NSArray *endCharacters))enumOneBetween_m_n_Character_NO_Get{
    return ^id(NSArray *startCharacters,NSArray *endCharacters) {
        return self.enumOneBetween_m_n_Character_yesOrNo_Get(startCharacters,endCharacters,NO);
    };
}

/**是一个数字*/
- (NSString *)number_Get{
    return @"\\d";
}
/**不是一个数字*/
- (NSString *)number_No_Get{
    return @"\\D";
}
/**是一个字母*/
- (NSString *)a_z_Or_A_Z_Get{
    return @"\\w";
}
/**不是一个字母*/
- (NSString *)a_z_Or_A_Z_NO_Get{
    return @"\\W";
}
@end