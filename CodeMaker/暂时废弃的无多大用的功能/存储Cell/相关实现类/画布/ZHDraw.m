#import "ZHDraw.h"
#import "ZHDrawViewColor.h"
#import "ZHDrawSubViewHelp.h"

@interface ZHDraw ()

@property (nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation ZHDraw

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}

- (void)clearData{
    [self.dataArr removeAllObjects];
    [self setNeedsDisplay];
}

- (void)addZHDrawModel:(ZHDrawModel *)model{
    if ([self.dataArr containsObject:model]==NO) {
        [self.dataArr addObject:model];
    }
}

- (void)drawRect:(CGRect)rect{
    if (self.type==ZHDrawTypeDraw) {
        for (ZHDrawModel *model in self.dataArr) {
            if ([model isKindOfClass:[ZHDrawModel class]]) {
                switch (model.type) {
                    case ZHDrawModelTypeRect:
                        [self drawViewRect:model.rect viewCategory:model.categoryView];
                        break;
                    case ZHDrawModelTypeString:
                        [self drawString:model.string rect:model.rect viewCategory:model.categoryView];
                        break;
                    default:break;
                }
            }
        }
    }
}

/**绘制文字*/
- (void)drawString:(NSString *)string rect:(CGRect)rect viewCategory:(NSString *)categoryView{
    [string drawInRect:CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width, rect.size.height) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Mishafi" size:10],NSForegroundColorAttributeName:[ZHDrawViewColor getStringColorWithViewCategory:categoryView]}];
}

/**绘制控件矩形框*/
- (void)drawViewRect:(CGRect)rect viewCategory:(NSString *)categoryView{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    [[ZHDrawViewColor getRectColorWithViewCategory:categoryView] setStroke];
    [path stroke];
}

/**脱屏渲染*/
- (void)takeOffScreenRendering{
    [self setNeedsDisplay];
}
#pragma mark ********************上面是绘制矩形控件,不是真实的控件********************




#pragma mark ********************下面是绘制真实的控件********************
- (void)creatSubViews{
    [self.dataArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        
        ZHDrawModel *model1=obj1,*model2=obj2;
        
        return model1.SameLayerCountIndex>model2.SameLayerCountIndex;
        
        //没用到层
//        if (model1.layerCount==model2.layerCount) {
//            return model1.SameLayerCountIndex>model2.SameLayerCountIndex;
//        }
//        return model1.layerCount>model2.layerCount;
    }];
    for (ZHDrawModel *model in self.dataArr) {
        if ([model isKindOfClass:[ZHDrawModel class]]) {
//            NSLog(@"%@-%@",@(model.layerCount),@(model.SameLayerCountIndex));
            switch (model.type) {
                case ZHDrawModelTypeRect:
                {
                    UIView *view=[ZHDrawSubViewHelp getViewWithFrame:model.rect withViewCategory:model.categoryView];
                    [view addShadowWithShadowOffset:CGSizeZero];
                    [view addBlurEffectWithAlpha:0.1];
                    [self addSubview:view];
                }
                    break;
                case ZHDrawModelTypeString:
                    break;
                default:break;
            }
        }
    }
}

@end
