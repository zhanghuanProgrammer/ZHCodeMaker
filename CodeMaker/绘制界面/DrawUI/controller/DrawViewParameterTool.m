
#import "DrawViewParameterTool.h"
#import "DrawViewModel.h"
#import "NSObject+YYModel.h"
#import "DrawViewConstarint.h"
#import "DrawConstraintLine.h"

@implementation DrawViewParameterTool

- (NSArray *)getFatherView:(DrawViewModel *)modelTarget models:(NSArray *)models{
    if ([modelTarget isInOtherView]) return nil;
    NSMutableArray *fathers = [NSMutableArray array];
    for (DrawViewModel *model in models){
        if ([model isEqual:modelTarget]) continue;
        if (CGRectContainsRect(model.relateView.frame, modelTarget.relateView.frame)) [fathers addObject:model];
    }
    return fathers;
}

- (NSArray *)getChildView:(DrawViewModel *)modelTarget models:(NSArray *)models{
    NSMutableArray *fathers = [NSMutableArray array];
    for (DrawViewModel *model in models){
        if ([model isEqual:modelTarget]) continue;
        if (CGRectContainsRect(modelTarget.relateView.frame,model.relateView.frame) && (![model isInOtherView])) [fathers addObject:model];
    }
    return fathers;
}

//direct 0:⬅️ 1:⬆️ 2:➡️ 3:⬇️
- (DrawViewModel *)getDirectView:(DrawViewModel *)modelTarget models:(NSArray *)models direct:(NSInteger)direct{
    NSMutableArray *copys = [NSMutableArray array];
    for (DrawViewModel *model in models){
        DrawViewModel *copyNew = [model copyNew];
        [copys addObject:copyNew];
        if([model isEqual:modelTarget])modelTarget = copyNew;
    }
    models = [NSArray arrayWithArray:copys];
    
    for (DrawViewModel *model in models) {
        if(model.idStr.length<=0)model.idStr = [[CreatFatherFile new] getStoryBoardIdString];
        model.x=model.relateView.x;model.y=model.relateView.y;
        model.w=model.relateView.width;model.h=model.relateView.height;
        for (id tempCommad in model.commands) {
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
    }
    if(direct == 0) return [self getLeft:modelTarget constraint:nil models:models];
    if(direct == 1) return [self getTop:modelTarget constraint:nil models:models];
    if(direct == 2) return [self getRight:modelTarget constraint:nil models:models];
    if(direct == 3) return [self getBottom:modelTarget constraint:nil models:models];
    return nil;
}

//direct 0:⬅️ 1:⬆️ 2:➡️ 3:⬇️
- (NSInteger)getDirectViewDistance:(DrawViewModel *)modelTarget models:(NSArray *)models direct:(NSInteger)direct{
    DrawViewModel *model = [self getDirectView:modelTarget models:models direct:direct];
    UIView *targetView = nil;
    UIView *curView = modelTarget.relateView;
    if (model) targetView = model.relateView;
    else targetView = [self getDrawViewWithViewId:model.superViewIdStr model:modelTarget models:models];
    if (targetView) {
        if(direct == 0 && (targetView.maxX < curView.x)) return (NSInteger)(curView.x - targetView.maxX);
        if(direct == 1 && (targetView.maxY < curView.y)) return (NSInteger)(curView.y - targetView.maxY);
        if(direct == 2 && (curView.maxX < targetView.x)) return (NSInteger)(targetView.x - curView.maxX);
        if(direct == 3 && (curView.maxY < targetView.y)) return (NSInteger)(targetView.y - curView.maxY);
    }
    return 0;
}

- (UIView *)getDrawViewWithViewId:(NSString *)viewId model:(DrawViewModel *)model models:(NSArray *)models{
    if ([viewId isEqualToString:KsuperViewIdStr]) return model.relateVC.view;
    for (DrawViewModel *model in models) if ([model.idStr isEqualToString:viewId]) return model.relateView;
    return nil;
}

- (NSDictionary *)parameterFromDrawViewModels:(NSArray *)models{
    NSMutableArray *copys = [NSMutableArray array];
    for (DrawViewModel *model in models){
        [copys addObject:[model copyNew]];
    }
    models = copys.copy;
    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    NSMutableDictionary *parametersDicM = [NSMutableDictionary dictionary];
    
    for (DrawViewModel *model in models) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if(model.idStr.length<=0)model.idStr = [[CreatFatherFile new] getStoryBoardIdString];
        model.x=model.relateView.x;model.y=model.relateView.y;model.w=model.relateView.width;model.h=model.relateView.height;
        NSMutableDictionary *commands = [NSMutableDictionary dictionary];
        NSMutableArray *inConstraints = [NSMutableArray array];
        for (id tempCommad in model.commands) {
            if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
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
                }else[commands setValuesForKeysWithDictionary:tempCommad];
            }
        }
        if(model.superViewIdStr.length<=0)model.superViewIdStr=KsuperViewIdStr;
        [parameters setValue:model.categoryView forKey:@"viewType"];
        [parameters setValue:model.idStr forKey:@"idStr"];
        [parameters setValue:StringNumber(@(model.x)) forKey:@"x"];
        [parameters setValue:StringNumber(@(model.y)) forKey:@"y"];
        [parameters setValue:StringNumber(@(model.w)) forKey:@"width"];
        [parameters setValue:StringNumber(@(model.h)) forKey:@"height"];
        if(commands.count>0)[parameters setValue:commands forKey:@"commands"];
        if (inConstraints.count > 0) {
            NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:inConstraints.count];
            for (DrawViewConstarint *modelConstarint in inConstraints) {
                if ([modelConstarint.firstAttribute isEqualToString:@"ratio"]) {
                    [constraints addObject:[NSString stringWithFormat:@"<constraint firstAttribute=\"width\" secondItem=\"%@\" secondAttribute=\"height\" multiplier=\"%@\" id=\"%@\"/>",model.idStr,modelConstarint.constant,[[CreatFatherFile new] getStoryBoardIdString]]];
                }
                if ([modelConstarint.firstAttribute isEqualToString:@"width"]||[modelConstarint.firstAttribute isEqualToString:@"height"]) {
                    [constraints addObject:[NSString stringWithFormat:@"<constraint firstAttribute=\"%@\" constant=\"%@\" id=\"%@\"/>",modelConstarint.firstAttribute,modelConstarint.constant,[[CreatFatherFile new] getStoryBoardIdString]]];
                }
            }
            [parameters setValue:constraints forKey:@"constraints"];
        }
        [parametersDicM setValue:parameters forKey:[NSString stringWithFormat:@"%p",model]];
    }
    
    NSMutableArray *views = [NSMutableArray array];
    [self getViews:parametersDicM models:models.mutableCopy toViews:views index:0];
    root[@"views"]=views;
    root[@"idStr"]=KsuperViewIdStr;
    
    NSMutableDictionary *constraintsDicM = [NSMutableDictionary dictionary];
    for (DrawViewModel *model in models) {
        for (id tempCommad in model.commands) {
            if ([tempCommad isKindOfClass:[DrawViewConstarint class]]) {
                NSString *constraintString = [self constraintsString:model constraint:tempCommad models:models];
                if (constraintString.length>0) {
                    [constraintsDicM setValue:model.superViewIdStr forKey:constraintString];
                }
            }
        }
    }
    [self getConstraint:constraintsDicM root:root];
    NSLog(@"%@",[@{@"root":root} jsonPrettyStringEncoded]);
    return @{@"root":root};
}

- (void)getConstraint:(NSMutableDictionary *)constraintsDicM root:(NSMutableDictionary *)root{
    if (constraintsDicM.count>0) {
        NSString *superViewIdStr = [constraintsDicM allValues][0];
        NSArray *sameSuperViewConstraints = [self getSameSuperViewConstraint:constraintsDicM superViewIdStr:superViewIdStr];
        [self insertConstraints:sameSuperViewConstraints toRoot:root superViewIdStr:superViewIdStr];
        [self getConstraint:constraintsDicM root:root];
    }
}

- (BOOL)insertConstraints:(NSArray *)constraints toRoot:(NSMutableDictionary *)root superViewIdStr:(NSString *)superViewIdStr{
    if([root[@"idStr"] isEqualToString:superViewIdStr]){//找到了
        NSMutableArray * inConstraints = root[@"constraints"];
        if (!inConstraints) inConstraints = [NSMutableArray array];
        [inConstraints addObjectsFromArray:constraints];
        [root setValue:inConstraints forKey:@"constraints"];
        return YES;
    }else{
        for (NSMutableDictionary *subView in root[@"views"]) {
            if ([self insertConstraints:constraints toRoot:subView superViewIdStr:superViewIdStr]) {
                return YES;
            }
        }
    }
    if([root[@"idStr"] isEqualToString:KsuperViewIdStr]){
        NSMutableArray * inConstraints = root[@"constraints"];
        if (!inConstraints) inConstraints = [NSMutableArray array];
        [inConstraints addObjectsFromArray:constraints];
        [root setValue:inConstraints forKey:@"constraints"];
        return YES;
    }
    return NO;
}

- (NSArray *)getSameSuperViewConstraint:(NSMutableDictionary *)constraintsDicM superViewIdStr:(NSString *)superViewIdStr{
    NSMutableArray *constraints = [NSMutableArray array];
    for (NSString *constraint in constraintsDicM) {
        if([constraintsDicM[constraint] isEqualToString:superViewIdStr]){
            [constraints addObject:constraint];
        }
    }
    for (NSString *constraint in constraints) {
        [constraintsDicM removeObjectForKey:constraint];
    }
    return constraints;
}

- (void)getViews:(NSMutableDictionary *)parametersDicM models:(NSMutableArray *)models toViews:(NSMutableArray *)views index:(NSInteger)index{
    if(index<parametersDicM.count) {
        NSString *modelKey = [parametersDicM allKeys][index];
        DrawViewModel *model = [self getModelIp:modelKey models:models];
        if (model) {
            if (![self haveSubModel:model models:models]) {//如果没有子view
                if([self haveSurperModel:model models:models]){//但是有父控件,说明这个是叶子节点,要加进去
                    DrawViewModel *superModel = [self getSurperModel:model models:models];
                    NSMutableDictionary *valueDicM = parametersDicM[[NSString stringWithFormat:@"%p",superModel]];
                    NSMutableArray *subViews = valueDicM[@"views"];
                    if(subViews==nil)subViews=[NSMutableArray array];
                    [subViews addObject:parametersDicM[modelKey]];
                    [valueDicM setValue:subViews forKey:@"views"];
                    [parametersDicM removeObjectForKey:modelKey];
                    [models removeObject:model];
                    [self getViews:parametersDicM models:models toViews:views index:0];
                }else{//如果没有子view,也没有父控件,说明这个根节点,直接加进去
                    [views addObject:parametersDicM[modelKey]];
                    [parametersDicM removeObjectForKey:modelKey];
                    [models removeObject:model];
                    [self getViews:parametersDicM models:models toViews:views index:0];
                }
            }else{//如果有子view
                [self getViews:parametersDicM models:models toViews:views index:index+1];
            }
        }else{
            [parametersDicM removeObjectForKey:modelKey];
            [models removeObject:model];
            [self getViews:parametersDicM models:models toViews:views index:index+1];
        }
    }
}

- (DrawViewModel *)getModelIp:(NSString *)modelIp models:(NSArray *)models{
    for (DrawViewModel *model in models){
        if ([[NSString stringWithFormat:@"%p",model] isEqualToString:modelIp]) {
            return model;
        }
    }
    return nil;
}
/**有没有子view*/
- (BOOL)haveSubModel:(DrawViewModel *)model models:(NSArray *)models{
    for (DrawViewModel *subModel in models){
        if ([subModel.superViewIdStr isEqualToString:model.idStr]) {
            return YES;
        }
    }
    return NO;
}
/**有没有父view 只的是models里面的,而不是最大的view*/
- (BOOL)haveSurperModel:(DrawViewModel *)model models:(NSArray *)models{
    for (DrawViewModel *subModel in models){
        if ([model.superViewIdStr isEqualToString:subModel.idStr]) {
            return YES;
        }
    }
    return NO;
}
- (DrawViewModel *)getSurperModel:(DrawViewModel *)model models:(NSArray *)models{
    for (DrawViewModel *subModel in models){
        if ([model.superViewIdStr isEqualToString:subModel.idStr]) {
            return subModel;
        }
    }
    return nil;
}

- (NSString *)constraintsString:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models{
    constraint.firstItem = model.idStr;
    if ([constraint.firstAttribute hasPrefix:@"-"]) {
        constraint.firstAttribute = [constraint.firstAttribute substringFromIndex:1];
        constraint.secondItem = model.superViewIdStr;
        constraint.secondAttribute = constraint.firstAttribute;
        return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
    }
    if ([constraint.firstAttribute isEqualToString:@"top"]) {
        if (constraint.secondItem.length<=0) {
            [self getTop:model constraint:constraint models:models];
            return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"left"]) {
        if (constraint.secondItem.length<=0) {
            [self getLeft:model constraint:constraint models:models];
            return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"right"]) {
        if (constraint.secondItem.length<=0) {
            [self getRight:model constraint:constraint models:models];
            return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"bottom"]) {
        if (constraint.secondItem.length<=0) {
            [self getBottom:model constraint:constraint models:models];
            return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"centerX"]) {
        if (constraint.secondItem.length<=0) {
            constraint.secondItem = model.superViewIdStr;
            constraint.secondAttribute = constraint.firstAttribute;
            return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if ([constraint.firstAttribute isEqualToString:@"centerY"]) {
        if (constraint.secondItem.length<=0) {
            constraint.secondItem = model.superViewIdStr;
            constraint.secondAttribute = constraint.firstAttribute;
            return [self constraintsString:model constraint:[[DrawViewConstarint new] reSetValue:constraint] models:models];
        }
    }
    if (constraint.secondItem.length>0 && constraint.secondItem.length != [[CreatFatherFile new] getStoryBoardIdString].length) {
        constraint.secondItem = [self getDrawViewModel:constraint.secondItem models:models].idStr;//可能已经删除了
    }
    if (constraint.secondItem.length>0) {
        return [self getConstraintString:constraint];
    }
    return @"";
}
- (NSString *)getOrigainalAttribute:(NSString *)attribute{
    if ([attribute isEqualToString:@"left"]) return @"leading";
    if ([attribute isEqualToString:@"right"]) return @"trailing";
    return attribute;
}
- (NSString *)getConstraintString:(DrawViewConstarint *)constraint{
    if(constraint.constant.length > 0 && [constraint.firstAttribute isEqualToString:constraint.secondAttribute]){
        if([constraint.firstAttribute isEqualToString:@"bottom"]||[constraint.firstAttribute isEqualToString:@"right"]){
            constraint = [constraint copyNew];
            NSString *secondItem = constraint.secondItem;
            constraint.secondItem = constraint.firstItem;
            constraint.firstItem = secondItem;
        }
    }
    if ([constraint.multiplier isEqualToString:@"1"]) {
        return [NSString stringWithFormat:@"<constraint firstItem=\"%@\" firstAttribute=\"%@\" secondItem=\"%@\" secondAttribute=\"%@\" constant=\"%@\" id=\"%@\"/>",constraint.firstItem,[self getOrigainalAttribute:constraint.firstAttribute],
                constraint.secondItem,[self getOrigainalAttribute:constraint.secondAttribute],constraint.constant,[[CreatFatherFile new] getStoryBoardIdString]];
    }else{
        return [NSString stringWithFormat:@"<constraint firstItem=\"%@\" firstAttribute=\"%@\" secondItem=\"%@\" secondAttribute=\"%@\" multiplier=\"%@\" constant=\"%@\" id=\"%@\"/>",constraint.firstItem,[self getOrigainalAttribute:constraint.firstAttribute],constraint.secondItem,[self getOrigainalAttribute:constraint.secondAttribute],constraint.multiplier,constraint.constant,[[CreatFatherFile new] getStoryBoardIdString]];
    }
}

- (DrawViewModel *)getDrawViewModel:(NSString *)viewIp models:(NSArray *)models{
    for (DrawViewModel *model in models) if ([[NSString stringWithFormat:@"%p",model.relateView]isEqualToString:viewIp]) return model;
    return nil;
}
- (DrawViewModel *)getTop:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models{
    NSArray *filters = [self getFilters:model models:models];
    DrawViewModel *target = nil;
    for (NSInteger i=(NSInteger)model.y; i>=0; i--) {
        if(target)break;
        CGPoint point  = CGPointMake(model.x, i);
        CGPoint point1 = CGPointMake(model.x+model.w/2.0, i);
        CGPoint point2 = CGPointMake(model.x+model.w, i);
        for (DrawViewModel *subModel in filters) {
            if (CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point1)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point2)) {
                target = subModel;
                break;
            }
        }
    }
    if (target) {
        constraint.secondItem = target.idStr;
        constraint.secondAttribute = @"bottom";
    }else{
        constraint.secondItem = model.superViewIdStr;
        constraint.secondAttribute = constraint.firstAttribute;
    }
    return target;
}
- (DrawViewModel *)getBottom:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models{
    NSArray *filters = [self getFilters:model models:models];
    DrawViewModel *target = nil;
    for (NSInteger i=(NSInteger)model.y+(NSInteger)model.h; i<=[UIScreen mainScreen].bounds.size.height; i++) {
        if(target)break;
        CGPoint point  = CGPointMake(model.x, i);
        CGPoint point1 = CGPointMake(model.x+model.w/2.0, i);
        CGPoint point2 = CGPointMake(model.x+model.w, i);
        for (DrawViewModel *subModel in filters) {
            if (CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point1)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point2)) {
                target = subModel;
                break;
            }
        }
    }
    if (target) {
        constraint.secondItem = target.idStr;
        constraint.secondAttribute = @"top";
    }else{
        constraint.secondItem = model.superViewIdStr;
        constraint.secondAttribute = constraint.firstAttribute;
    }
    return target;
}
- (DrawViewModel *)getLeft:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models{
    NSArray *filters = [self getFilters:model models:models];
    DrawViewModel *target = nil;
    for (NSInteger i=(NSInteger)model.x; i>=0; i--) {
        if(target)break;
        CGPoint point = CGPointMake(i, model.y);
        CGPoint point1 = CGPointMake(i, model.y+model.h/2.0);
        CGPoint point2 = CGPointMake(i, model.y+model.h);
        for (DrawViewModel *subModel in filters) {
            if (CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point1)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point2)) {
                target = subModel;
                break;
            }
        }
    }
    if (target) {
        constraint.secondItem = target.idStr;
        constraint.secondAttribute = @"right";
    }else{
        constraint.secondItem = model.superViewIdStr;
        constraint.secondAttribute = constraint.firstAttribute;
    }
    return target;
}
- (DrawViewModel *)getRight:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models{
    NSArray *filters = [self getFilters:model models:models];
    DrawViewModel *target = nil;
    for (NSInteger i=(NSInteger)model.x+(NSInteger)model.w; i<=[UIScreen mainScreen].bounds.size.width; i++) {
        if(target)break;
        CGPoint point = CGPointMake(i, model.y);
        CGPoint point1 = CGPointMake(i, model.y+model.h/2.0);
        CGPoint point2 = CGPointMake(i, model.y+model.h);
        for (DrawViewModel *subModel in filters) {
            if (CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point1)||
                CGRectContainsPoint(CGRectMake(subModel.x, subModel.y, subModel.w, subModel.h), point2)) {
                target = subModel;
                break;
            }
        }
    }
    if (target) {
        constraint.secondItem = target.idStr;
        constraint.secondAttribute = @"left";
    }else{
        constraint.secondItem = model.superViewIdStr;
        constraint.secondAttribute = constraint.firstAttribute;
    }
    return target;
}
- (NSArray *)getFilters:(DrawViewModel *)model models:(NSArray *)models{
    NSMutableArray *filters = [NSMutableArray array];
    for (DrawViewModel *subModel in models) {
        if(subModel == model)continue;
        if ([subModel.superViewIdStr isEqualToString:model.superViewIdStr]) {
            [filters addObject:subModel];
        }
    }
    return filters;
}

@end
