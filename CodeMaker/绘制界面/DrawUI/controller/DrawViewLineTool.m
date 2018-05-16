
#import "DrawViewLineTool.h"
#import "DrawViewModel.h"
#import "NSObject+YYModel.h"
#import "DrawViewConstarint.h"
#import "DrawConstraintLine.h"
#import "DrawViewParameterTool.h"

@interface DrawViewLineTool ()

@property (nonatomic,weak)DrawViewModel *modelTarget;

@end

@implementation DrawViewLineTool

- (NSArray *)getDrawConstraintLine:(DrawViewModel *)modelTarget models:(NSArray *)models{
    NSMutableArray *copys = [NSMutableArray array];
    for (DrawViewModel *model in models){
        DrawViewModel *copyNew = [model copyNew];
        [copys addObject:copyNew];
        if([model isEqual:modelTarget])modelTarget = copyNew;
    }
    self.modelTarget = modelTarget;
    models = [NSArray arrayWithArray:copys];
    
    NSMutableArray *drawConstraintLines = [NSMutableArray array];
    for (DrawViewModel *model in models) {
        if(model.idStr.length<=0)model.idStr = [[CreatFatherFile new] getStoryBoardIdString];
        model.x=model.relateView.x;model.y=model.relateView.y;
        model.w=model.relateView.width;model.h=model.relateView.height;
        NSMutableArray *inConstraints = [NSMutableArray array];
        for (id tempCommad in model.commands) {
            if ([modelTarget isEqual:model]&&[tempCommad isKindOfClass:[DrawViewConstarint class]]) {
                DrawViewConstarint *model = tempCommad;
                if([model isInConstarint])[inConstraints addObject:model];
            }
            if ([tempCommad isKindOfClass:[NSDictionary class]]) {
                NSString *key = [tempCommad allKeys][0];
                if ([key isEqualToString:@"inview"]) {
                    NSString *value = [tempCommad allValues][0];
                    for (DrawViewModel *subModel in models){
                        if ([[NSString stringWithFormat:@"%p",subModel.relateView] isEqualToString:value]) {
                            if(subModel.idStr.length<=0)subModel.idStr = [[CreatFatherFile new] getStoryBoardIdString];
                            model.superViewIdStr = subModel.idStr;
                            model.x-=subModel.relateView.x;
                            model.y-=subModel.relateView.y;
                            break;
                        }
                    }
                }
            }
        }
        if(model.superViewIdStr.length<=0)model.superViewIdStr=KsuperViewIdStr;
        if (inConstraints.count > 0) {
            for (DrawViewConstarint *modelConstarint in inConstraints) {
                if ([modelConstarint.firstAttribute isEqualToString:@"ratio"]) {
                    [drawConstraintLines addObject:[[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, model.relateView.maxY) point2:CGPointMake(model.relateView.maxX, model.relateView.maxY)]];
                    [drawConstraintLines addObject:[[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.maxX, model.relateView.y) point2:CGPointMake(model.relateView.maxX, model.relateView.maxY)]];
                }
                if ([modelConstarint.firstAttribute isEqualToString:@"width"]) {
                    [drawConstraintLines addObject:[[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, model.relateView.centerY) point2:CGPointMake(model.relateView.maxX, model.relateView.centerY)]];
                }
                if ([modelConstarint.firstAttribute isEqualToString:@"height"]) {
                    [drawConstraintLines addObject:[[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.centerX, model.relateView.y) point2:CGPointMake(model.relateView.centerX, model.relateView.maxY)]];
                }
            }
        }
    }
    
    for (DrawViewModel *model in models) {
        for (id tempCommad in model.commands) {
            if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
                id results = [self constraintsLine:model constraint:tempCommad models:models];
                if ([results isKindOfClass:[DrawConstraintLine class]]) {
                    [drawConstraintLines addObject:results];
                }else if([results isKindOfClass:[NSArray class]]){
                    for (DrawConstraintLine *modelLine in results) {
                        if([modelLine isKindOfClass:[DrawConstraintLine class]])[drawConstraintLines addObject:modelLine];
                    }
                }
            }
        }
    }
    
    return drawConstraintLines;
}

- (id)constraintsLine:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models{
    constraint.firstItem = model.idStr;
    if ([constraint.firstAttribute hasPrefix:@"-"]) {
        constraint.firstAttribute = [constraint.firstAttribute substringFromIndex:1];
        constraint.secondItem = model.superViewIdStr;
        constraint.secondAttribute = constraint.firstAttribute;
        return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
    }
    if ([constraint.firstAttribute isEqualToString:@"top"]) {
        if (constraint.secondItem.length<=0) {
            [[DrawViewParameterTool new] getTop:model constraint:constraint models:models];
            return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"left"]) {
        if (constraint.secondItem.length<=0) {
            [[DrawViewParameterTool new] getLeft:model constraint:constraint models:models];
            return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"right"]) {
        if (constraint.secondItem.length<=0) {
            [[DrawViewParameterTool new] getRight:model constraint:constraint models:models];
            return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"bottom"]) {
        if (constraint.secondItem.length<=0) {
            [[DrawViewParameterTool new] getBottom:model constraint:constraint models:models];
            return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"centerX"]) {
        if (constraint.secondItem.length<=0) {
            constraint.secondItem = model.superViewIdStr;
            constraint.secondAttribute = constraint.firstAttribute;
            return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"centerY"]) {
        if (constraint.secondItem.length<=0) {
            constraint.secondItem = model.superViewIdStr;
            constraint.secondAttribute = constraint.firstAttribute;
            return [self constraintsLine:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if (constraint.secondItem.length>0 && constraint.secondItem.length != [[CreatFatherFile new] getStoryBoardIdString].length) {
        constraint.secondItem = [[DrawViewParameterTool new] getDrawViewModel:constraint.secondItem models:models].idStr;//可能已经删除了
    }
    if (constraint.secondItem.length>0) {
        return [self getConstraintLine:constraint model:model models:models];
    }
    return nil;
}

- (id)getConstraintLine:(DrawViewConstarint *)constraint model:(DrawViewModel *)model models:(NSArray *)models{
    BOOL isInSuperView = [constraint.secondItem isEqualToString:model.superViewIdStr];
    UIView *superView = isInSuperView == YES ? ([self getDrawViewModelWithViewId:model.superViewIdStr models:models].relateView) : nil;
    UIView *secondView = isInSuperView == YES ? nil : ([self getDrawViewModelWithViewId:constraint.secondItem models:models].relateView);
    if (isInSuperView && [model.superViewIdStr isEqualToString:KsuperViewIdStr]) {
        superView = model.relateVC.view;
    }
    isInSuperView = (superView != nil);
    if(!([model.relateView isEqual:self.modelTarget.relateView] ||
       [superView isEqual:self.modelTarget.relateView] ||
       [secondView isEqual:self.modelTarget.relateView])
       ){
        return nil;
    }
    if ([constraint.firstAttribute isEqualToString:@"top"]) {
        if (isInSuperView) {
            return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.centerX, model.relateView.y) point2:CGPointMake(model.relateView.centerX, 0)];
        }else if(secondView){
            if ([constraint.secondAttribute isEqualToString:@"top"]) {
                return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.x, secondView.x), model.relateView.y) point2:CGPointMake(MAX(model.relateView.maxX, secondView.maxX), model.relateView.y)];
            }
            if ([constraint.secondAttribute isEqualToString:@"bottom"]) {
                return @[
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.centerX, secondView.centerX), model.relateView.y) point2:CGPointMake(MAX(model.relateView.centerX, secondView.centerX), model.relateView.y) color:[UIColor blueColor]],
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(secondView.centerX, MIN(model.relateView.y, secondView.maxY)) point2:CGPointMake(secondView.centerX, MAX(model.relateView.y, secondView.maxY))]
                         ];
            }
            if ([constraint.secondAttribute isEqualToString:@"centerY"]) {
                //暂时不加这个功能
            }
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"left"]) {
        if (isInSuperView) {
            return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, model.relateView.centerY) point2:CGPointMake(superView.x, model.relateView.centerY)];
        }else if(secondView){
            if ([constraint.secondAttribute isEqualToString:@"left"]) {
                return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, MIN(model.relateView.y, secondView.y)) point2:CGPointMake(model.relateView.x, MAX(model.relateView.maxY, secondView.maxY))];
            }
            if ([constraint.secondAttribute isEqualToString:@"right"]) {
                return @[
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, MIN(model.relateView.centerY, secondView.centerY)) point2:CGPointMake(model.relateView.x, MAX(model.relateView.centerY, secondView.centerY)) color:[UIColor blueColor]],
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.x, secondView.maxX),secondView.centerY) point2:CGPointMake(MAX(model.relateView.x, secondView.maxX),secondView.centerY)]
                         ];
            }
            if ([constraint.secondAttribute isEqualToString:@"centerX"]) {
                //暂时不加这个功能
            }
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"right"]) {
        if (isInSuperView) {
            return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.maxX, model.relateView.centerY) point2:CGPointMake(superView.maxX, model.relateView.centerY)];
        }else if(secondView){
            if ([constraint.secondAttribute isEqualToString:@"right"]) {
                return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.maxX, MIN(model.relateView.y, secondView.y)) point2:CGPointMake(model.relateView.maxX, MAX(model.relateView.maxY, secondView.maxY))];
            }
            if ([constraint.secondAttribute isEqualToString:@"left"]) {
                return @[
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.maxX, MIN(model.relateView.centerY, secondView.centerY)) point2:CGPointMake(model.relateView.maxX, MAX(model.relateView.centerY, secondView.centerY)) color:[UIColor blueColor]],
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.maxX, secondView.x),secondView.centerY) point2:CGPointMake(MAX(model.relateView.maxX, secondView.x),secondView.centerY)]
                         ];
            }
            if ([constraint.secondAttribute isEqualToString:@"centerX"]) {
                //暂时不加这个功能
            }
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"bottom"]) {
        if (isInSuperView) {
            return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.centerX, model.relateView.maxY) point2:CGPointMake(model.relateView.centerX, superView.height)];
        }else if(secondView){
            if ([constraint.secondAttribute isEqualToString:@"bottom"]) {
                return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.x, secondView.x), model.relateView.maxY) point2:CGPointMake(MAX(model.relateView.maxX, secondView.maxX), model.relateView.maxY)];
            }
            if ([constraint.secondAttribute isEqualToString:@"top"]) {
                return @[
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.centerX, secondView.centerX), secondView.y) point2:CGPointMake(MAX(model.relateView.centerX, secondView.centerX), secondView.y) color:[UIColor blueColor]],
                         [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.centerX, MIN(model.relateView.maxY, secondView.y)) point2:CGPointMake(model.relateView.centerX, MAX(model.relateView.maxY, secondView.y))]
                         ];
            }
            if ([constraint.secondAttribute isEqualToString:@"centerY"]) {
                //暂时不加这个功能
            }
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"centerX"]) {
        if (isInSuperView) {
            return @[
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(0, superView.height/2.0) point2:CGPointMake(superView.maxX, superView.height/2.0) color:[UIColor yellowColor]],
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(0, model.relateView.centerY) point2:CGPointMake(superView.maxX, model.relateView.centerY)]
                     ];
        }else if(secondView){
            if ([constraint.secondAttribute isEqualToString:@"centerX"]) {
                return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(MIN(model.relateView.x, secondView.x), model.relateView.centerY) point2:CGPointMake(MAX(model.relateView.maxX, secondView.maxX), model.relateView.centerY)];
            }
            if ([constraint.secondAttribute isEqualToString:@"left"]) {
                //暂时不加这个功能
            }
            if ([constraint.secondAttribute isEqualToString:@"right"]) {
                //暂时不加这个功能
            }
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"centerY"]) {
        if (isInSuperView) {
            return @[
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(superView.centerX, 0) point2:CGPointMake(superView.centerX, superView.height) color:[UIColor yellowColor]],
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.centerX, 0) point2:CGPointMake(model.relateView.centerX, superView.height)]
                     ];
        }else if(secondView){
            if ([constraint.secondAttribute isEqualToString:@"centerY"]) {
                return [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.centerX, MIN(model.relateView.y, secondView.y)) point2:CGPointMake(model.relateView.centerX, MAX(model.relateView.maxY, secondView.maxY))];
            }
            if ([constraint.secondAttribute isEqualToString:@"top"]) {
                //暂时不加这个功能
            }
            if ([constraint.secondAttribute isEqualToString:@"bottom"]) {
                //暂时不加这个功能
            }
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"width"]) {
        if (isInSuperView) {
            return @[
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(superView.x, superView.height/2.0) point2:CGPointMake(superView.maxX, superView.height/2.0) color:[UIColor yellowColor]],
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, model.relateView.y) point2:CGPointMake(model.relateView.maxX, model.relateView.y)]
                     ];
        }else if(secondView){
            return @[
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(secondView.x, secondView.y) point2:CGPointMake(secondView.maxX, secondView.y) color:[UIColor yellowColor]],
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.x, model.relateView.y) point2:CGPointMake(model.relateView.maxX, model.relateView.y)]
                     ];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"height"]) {
        if (isInSuperView) {
            return @[
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(superView.maxX-10, 0) point2:CGPointMake(superView.maxX-10, superView.height) color:[UIColor yellowColor]],
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.maxX, model.relateView.y) point2:CGPointMake(model.relateView.maxX, model.relateView.maxY)]
                     ];
        }else if(secondView){
            return @[
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(secondView.maxX, secondView.y) point2:CGPointMake(secondView.maxX, secondView.maxY) color:[UIColor yellowColor]],
                     [[DrawConstraintLine alloc]initWithPoint1:CGPointMake(model.relateView.maxX, model.relateView.y) point2:CGPointMake(model.relateView.maxX, model.relateView.maxY)]
                     ];
        }
    }
    return nil;
}

- (DrawViewModel *)getDrawViewModelWithViewId:(NSString *)viewId models:(NSArray *)models{
    for (DrawViewModel *model in models) if ([model.idStr isEqualToString:viewId]) return model;
    return nil;
}

@end
