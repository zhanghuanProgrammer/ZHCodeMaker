
#import "MGTemplateEngine.h"

@interface ICUTemplateMatcher : NSObject <MGTemplateEngineMatcher>

@property(atomic,assign) MGTemplateEngine *engine; 
@property(atomic,retain) NSString *markerStart;

@property(atomic,retain) NSString *markerEnd;

@property(atomic,retain) NSString *exprStart;

@property(atomic,retain) NSString *exprEnd;

@property(atomic,retain) NSString *filterDelimiter;

@property(atomic,retain) NSString *templateString;

@property(atomic,retain) NSString *regex;

+ (ICUTemplateMatcher *)matcherWithTemplateEngine:(MGTemplateEngine *)theEngine;

- (NSArray *)argumentsFromString:(NSString *)argString;

@end
