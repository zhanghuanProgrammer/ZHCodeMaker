

#import "MGTemplateEngine.h"

@protocol MGTemplateMarker <NSObject>
@required
- (id)initWithTemplateEngine:(MGTemplateEngine *)engine;

- (NSArray *)markers; 
- (NSArray *)endMarkersForMarker:(NSString *)marker; 
- (NSObject *)markerEncountered:(NSString *)marker withArguments:(NSArray *)args inRange:(NSRange)markerRange blockStarted:(BOOL *)blockStarted blockEnded:(BOOL *)blockEnded
				  outputEnabled:(BOOL *)outputEnabled nextRange:(NSRange *)nextRange 
			   currentBlockInfo:(NSDictionary *)blockInfo newVariables:(NSDictionary **)newVariables;

- (void)engineFinishedProcessingTemplate;

@end
