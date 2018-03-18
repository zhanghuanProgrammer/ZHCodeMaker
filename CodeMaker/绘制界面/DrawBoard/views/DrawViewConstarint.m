//
//  DrawViewConstarint.m
//  CodeMaker
//
//  Created by mac on 2018/3/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "DrawViewConstarint.h"
#import "NSObject+YYModel.h"

@implementation DrawViewConstarint

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.firstAttribute forKey:@"firstAttribute"];
    [aCoder encodeObject:self.firstItem forKey:@"firstItem"];
    [aCoder encodeObject:self.secondAttribute forKey:@"secondAttribute"];
    [aCoder encodeObject:self.secondItem forKey:@"secondItem"];
    [aCoder encodeObject:self.multiplier forKey:@"multiplier"];
    [aCoder encodeObject:self.constant forKey:@"constant"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.firstAttribute  = [aDecoder decodeObjectForKey:@"firstAttribute"];
        self.firstItem       = [aDecoder decodeObjectForKey:@"firstItem"];
        self.secondAttribute = [aDecoder decodeObjectForKey:@"secondAttribute"];
        self.secondItem      = [aDecoder decodeObjectForKey:@"secondItem"];
        self.multiplier      = [aDecoder decodeObjectForKey:@"multiplier"];
        self.constant        = [aDecoder decodeObjectForKey:@"constant"];
    }
    return self;
}

- (NSString *)firstItem{ if(!_firstItem) _firstItem = @""; return _firstItem; }
- (NSString *)firstAttribute{ if(!_firstAttribute) _firstAttribute = @""; return _firstAttribute; }
- (NSString *)secondItem{ if(!_secondItem) _secondItem = @""; return _secondItem; }
- (NSString *)secondAttribute{ if(!_secondAttribute) _secondAttribute = @""; return _secondAttribute; }
- (NSString *)constant{ if(!_constant) _constant = @"";return _constant;}

- (NSString *)description{
    return [self modelToJSONString];
}
- (NSString *)firstControllIndex{
    if ([self.firstAttribute isEqualToString:@"top"]) return @"5";
    if ([self.firstAttribute isEqualToString:@"left"]) return @"6";
    if ([self.firstAttribute isEqualToString:@"right"]) return @"7";
    if ([self.firstAttribute isEqualToString:@"bottom"]) return @"8";
    return @"";
}
- (NSString *)secondControllIndex{
    if ([self.secondAttribute isEqualToString:@"top"]) return @"5";
    if ([self.secondAttribute isEqualToString:@"left"]) return @"6";
    if ([self.secondAttribute isEqualToString:@"right"]) return @"7";
    if ([self.secondAttribute isEqualToString:@"bottom"]) return @"8";
    return @"";
}
- (NSString *)logDescription{
    NSMutableString *textM = [NSMutableString string];
    if (self.firstItem.length > 0) [textM appendFormat:@"%@ ",self.firstItem];
    if (self.firstAttribute.length > 0) [textM appendFormat:@"%@ ",self.firstAttribute];
    if (self.secondItem.length > 0) [textM appendFormat:@"%@ ",self.secondItem];
    if (self.secondAttribute.length > 0) [textM appendFormat:@"%@ ",self.secondAttribute];
    if (self.constant.length > 0) [textM appendFormat:@"%@ ",self.constant];
    if (![self.multiplier isEqualToString:@"1"]) [textM appendFormat:@"%@ ",self.multiplier];
    [textM setString:[textM substringToIndex:textM.length-1]];
    return textM;
}

- (NSString *)selectDescription{
    if (self.secondItem.length > 0){
        if ([self.firstAttribute isEqualToString:self.secondAttribute]) {
            if([self.firstAttribute isEqualToString:@"centerX"])return [NSString stringWithFormat:@"cx=? %@",self.constant];
            else if([self.firstAttribute isEqualToString:@"centerY"])return [NSString stringWithFormat:@"cy=? %@",self.constant];
            else return [NSString stringWithFormat:@"%@=? %@",[self.firstAttribute substringToIndex:1],self.constant];
        }
        return self.constant;
    }
    NSMutableString *textM = [NSMutableString string];
    NSString *firstAttribute = self.firstAttribute;
    if (firstAttribute.length > 0){
        if([firstAttribute isEqualToString:@"centerX"])[textM appendFormat:@"cx "];
        else if([firstAttribute isEqualToString:@"centerY"])[textM appendFormat:@"cy "];
        else if([firstAttribute isEqualToString:@"ratio"])[textM appendFormat:@"wh "];
        else{
            NSString *first = [firstAttribute substringToIndex:1];
            if (![ZHNSString isValidateNickname:first]) first = [firstAttribute substringToIndex:2];
            [textM appendFormat:@"%@ ",first];
        }
    }
    if (self.constant.length > 0) [textM appendFormat:@"%@ ",self.constant];
    [textM setString:[textM substringToIndex:textM.length-1]];
    return textM;
}

- (NSString*)multiplier{
    if (!_multiplier) return @"1";
    return _multiplier;
}

- (BOOL)isEqualTo:(id)object{
    DrawViewConstarint* other = (DrawViewConstarint*)object;
    if (![self.firstAttribute isEqualToString:other.firstAttribute] ||
        ![self.secondAttribute isEqualToString:other.secondAttribute] ||
        ![self.secondItem isEqualToString:other.secondItem]) {
        return NO;
    }
    return YES;
}

- (instancetype)copyNew{
    DrawViewConstarint *copy =[DrawViewConstarint new];
    copy.firstAttribute  = self.firstAttribute;
    copy.firstItem       = self.firstItem;
    copy.secondAttribute = self.secondAttribute;
    copy.secondItem      = self.secondItem;
    copy.multiplier      = self.multiplier;
    copy.constant        = self.constant;
    return copy;
}

- (instancetype)reSetValue:(DrawViewConstarint*)object{
    self.firstAttribute  = object.firstAttribute;
    self.firstItem       = object.firstItem;
    self.secondAttribute = object.secondAttribute;
    self.secondItem      = object.secondItem;
    self.multiplier      = object.multiplier;
    self.constant        = object.constant;
    return self;
}

- (BOOL)isRelatedSame:(DrawViewConstarint*)object{
    if ([self.firstAttribute isEqualToString:object.firstAttribute] &&
        [self.secondAttribute isEqualToString:object.secondAttribute] &&
        [self.secondItem isEqualToString:object.secondItem]&&
        [self.firstItem isEqualToString:object.firstItem]) {
        return YES;
    }
    if ([self.firstAttribute isEqualToString:object.secondAttribute] &&
        [self.secondAttribute isEqualToString:object.firstAttribute] &&
        [self.secondItem isEqualToString:object.firstItem]&&
        [self.firstItem isEqualToString:object.secondItem]) {
        return YES;
    }
    return NO;
}

- (BOOL)isInConstarint{
//    @"top" @"left" @"right" @"bottom" @"-top" @"-left" @"-right" @"-bottom" @"width" @"height" @"centerX" @"centerY" @"ratio"
    if ([self.firstAttribute isEqualToString:@"ratio"]) {
        return YES;
    }
    if (([self.firstAttribute isEqualToString:@"width"]||[self.firstAttribute isEqualToString:@"height"])&&(self.secondItem.length<=0)) {
        return YES;
    }
    return NO;
}

@end

