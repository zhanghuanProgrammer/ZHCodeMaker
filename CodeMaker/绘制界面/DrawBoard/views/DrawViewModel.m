#import "DrawViewModel.h"
#import "DrawViewConstarint.h"

@implementation DrawViewModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.categoryView forKey:@"categoryView"];
    [aCoder encodeCGRect:self.frame forKey:@"frame"];
    [aCoder encodeObject:self.commands forKey:@"commands"];
    [aCoder encodeObject:self.relateViewIp forKey:@"relateViewIp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.categoryView = [aDecoder decodeObjectForKey:@"categoryView"];
        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
        self.commands = [aDecoder decodeObjectForKey:@"commands"];
        self.relateViewIp = [aDecoder decodeObjectForKey:@"relateViewIp"];
    }
    return self;
}

- (instancetype)copyNew{
    DrawViewModel * copy = [DrawViewModel new];
    copy.idStr=self.idStr;
    copy.categoryView=self.categoryView;
    copy.relateView=self.relateView;
    copy.relateVC = self.relateVC;
    copy.superViewIdStr=self.superViewIdStr;
    copy.x=self.x;
    copy.y=self.y;
    copy.w=self.w;
    copy.h=self.h;
    NSMutableArray *commands = [NSMutableArray array];
    for (id model in self.commands) {
        if ([model isKindOfClass:[DrawViewConstarint class]]) {
            [commands addObject:[model copyNew]];
        }else if ([model isKindOfClass:[NSDictionary class]]) {
            [commands addObject:[NSDictionary dictionaryWithDictionary:model]];
        }
    }
    copy.commands = commands;
    return copy;
}

- (NSMutableArray *)commands{
    if (!_commands) {
        _commands = [NSMutableArray array];
    }
    return _commands;
}

- (NSString *)changeKeyValueCommand:(NSDictionary *)command{
    for (id tempCommad in self.commands) {
        if ([tempCommad isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = tempCommad;
            if ([[dic allKeys][0] isEqualToString:[command allKeys][0]]) {
                NSString * value1 = [dic allValues][0];
                NSString * value2 = [command allValues][0];
                if ([ZHNSString isPureInt:value1]||[ZHNSString isPureFloat:value1]) {
                    if (!([ZHNSString isPureInt:value2]||[ZHNSString isPureFloat:value2])) {
                        return @"修改时值的类型不能改变";
                    }
                }
                [self addOrUpdateCommand:command];
                return @"";
            }
        }
    }
    return @"指令不识别";
}

- (void)addOrUpdateCommand:(id)command{
    if ([command isKindOfClass:[DrawViewConstarint class]]) {
        DrawViewConstarint *commandModel = command;
        for (id tempCommad in self.commands) {
            if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
                if ([commandModel isEqualTo:tempCommad]) {
                    [tempCommad reSetValue:commandModel];
                    return;
                }
            }
        }
        [self.commands addObject:command];
    }else if ([command isKindOfClass:[NSDictionary class]]){
        NSDictionary *dic = command;
        NSDictionary *target = nil;
        for (id tempCommad in self.commands) {
            if ([tempCommad isKindOfClass:[NSDictionary class]]) {
                NSDictionary *tempDic = tempCommad;
                if ([[tempDic allKeys][0] isEqual:[dic allKeys][0]]) {
                    target = tempDic;
                    break;
                }
            }
        }
        if (target) {
            [self.commands removeObject:target];
        }
        [self.commands addObject:dic];
    }
}

- (void)ifExsitRemove:(id)command{
    id target = nil;
    if ([command isKindOfClass:[DrawViewConstarint class]]) {
        DrawViewConstarint *commandModel = command;
        for (id tempCommad in self.commands) {
            if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
                if ([tempCommad isRelatedSame:commandModel]) {
                    target = tempCommad;
                    break;
                }
            }
        }
    }
    [self.commands removeObject:target];
}

- (NSString *)conmandText{
    NSInteger index = 1;
    NSMutableString *textM = [NSMutableString string];
    for (id tempCommad in self.commands) {
        if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
            DrawViewConstarint *model = tempCommad;
            model.relateVC = self.relateVC;
            [textM appendFormat:@"%zd : %@\n",index++,model.logDescription];
        }
        if ([tempCommad isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = tempCommad;
            [textM appendFormat:@"%zd : %@ %@\n",index++,[dic allKeys][0],[dic allValues][0]];
        }
    }
    return textM;
}

/**重新保存并打开后,relatedView的IP地址会变,所以要全部替换*/
- (void)reOpenViewIpAjust:(NSArray *)models{
    for (id tempCommad in self.commands) {
        if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
            DrawViewConstarint *constarint = tempCommad;
            if (constarint.firstItem.length>0) {
                for (DrawViewModel *subModel in models) {
                    if ([subModel.relateViewIp isEqualToString:constarint.firstItem]) {
                        constarint.firstItem = [NSString stringWithFormat:@"%p",subModel.relateView];
                        break;
                    }
                }
            }
            if (constarint.secondItem.length>0) {
                for (DrawViewModel *subModel in models) {
                    if ([subModel.relateViewIp isEqualToString:constarint.secondItem]) {
                        constarint.secondItem = [NSString stringWithFormat:@"%p",subModel.relateView];
                        break;
                    }
                }
            }
        }
        if ([tempCommad isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = tempCommad;
            NSString *key = [dic allKeys][0];
            NSString *value = [dic allValues][0];
            for (DrawViewModel *subModel in models) {
                if ([subModel.relateViewIp isEqualToString:value]) {
                    [self addOrUpdateCommand:@{key:[NSString stringWithFormat:@"%p",subModel.relateView]}];
                    break;
                }
            }
        }
    }
}

/**假如某个控件被删除了,那么与它相关的约束等等命令需要删除*/
- (void)deleteOverDataViewIp:(NSArray *)models relateViewIP:(NSString *)relateViewIP{
    NSMutableArray *overData = [NSMutableArray array];
    for (id tempCommad in self.commands) {
        if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
            DrawViewConstarint *constarint = tempCommad;
            if (constarint.firstItem.length>0) {
                if ([relateViewIP isEqualToString:constarint.firstItem]) {
                    [overData addObject:tempCommad];
                }
            }else if (constarint.secondItem.length>0) {
                if ([relateViewIP isEqualToString:constarint.secondItem]) {
                    [overData addObject:tempCommad];
                }
            }
        }
        if ([tempCommad isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = tempCommad;
            NSString *value = [dic allValues][0];
            if ([relateViewIP isEqualToString:value]) {
                [overData addObject:tempCommad];
            }
        }
    }
    for (id tempCommad in overData) {
        if ([self.commands containsObject:tempCommad]) {
            [self.commands removeObject:tempCommad];
        }
    }
}

@end
