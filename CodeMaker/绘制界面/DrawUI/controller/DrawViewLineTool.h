
#import <Foundation/Foundation.h>
@class DrawViewModel;

@interface DrawViewLineTool : NSObject

- (NSArray *)getDrawConstraintLine:(DrawViewModel *)modelTarget models:(NSArray *)models;

@end
