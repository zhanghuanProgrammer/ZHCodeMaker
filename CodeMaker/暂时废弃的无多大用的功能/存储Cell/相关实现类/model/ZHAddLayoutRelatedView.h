#import <Foundation/Foundation.h>

@interface ZHAddLayoutRelatedView : NSObject

@property (nonatomic,strong)ZHAddLayoutRelatedView *fatherRelatedView;
@property (nonatomic,strong)NSDictionary *selfView;
@property (nonatomic,copy)NSString *categoryView;

@property (nonatomic,assign)NSInteger layerCount;//处于第几层嵌套
@property (nonatomic,assign)NSInteger SameLayerCountIndex;//处于同一层位置上的上下级顺序
@end
