
#import <Foundation/Foundation.h>
@class DrawViewModel;
@class DrawViewConstarint;

#define KsuperViewIdStr @"9ju-6x-dsY"

@interface DrawViewParameterTool : NSObject

//direct 0:⬅️ 1:⬆️ 2:➡️ 3:⬇️
- (DrawViewModel *)getDirectView:(DrawViewModel *)modelTarget models:(NSArray *)models direct:(NSInteger)direct;
- (NSInteger)getDirectViewDistance:(DrawViewModel *)modelTarget models:(NSArray *)models direct:(NSInteger)direct;
- (NSArray *)getFatherView:(DrawViewModel *)modelTarget models:(NSArray *)models;
- (NSArray *)getChildView:(DrawViewModel *)modelTarget models:(NSArray *)models;

- (NSDictionary *)parameterFromDrawViewModels:(NSArray *)models;

- (DrawViewModel *)getDrawViewModel:(NSString *)viewIp models:(NSArray *)models;
- (DrawViewModel *)getTop:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models;
- (DrawViewModel *)getBottom:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models;
- (DrawViewModel *)getLeft:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models;
- (DrawViewModel *)getRight:(DrawViewModel *)model constraint:(DrawViewConstarint *)constraint models:(NSArray *)models;

@end
