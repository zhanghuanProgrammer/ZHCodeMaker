#import <UIKit/UIKit.h>

#define	BLOCK_NAME_KEY					@"name"				
#define BLOCK_END_NAMES_KEY				@"endNames"			
#define BLOCK_ARGUMENTS_KEY				@"args"				
#define BLOCK_START_MARKER_RANGE_KEY	@"startMarkerRange"	
#define BLOCK_VARIABLES_KEY				@"vars"				

#define TEMPLATE_ENGINE_ERROR_DOMAIN	@"MGTemplateEngineErrorDomain"

@class MGTemplateEngine;

@protocol MGTemplateEngineDelegate <NSObject>
@optional
- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo;

- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo;

- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine;

- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;

@end

#define MARKER_NAME_KEY					@"name"				
#define MARKER_TYPE_KEY					@"type"				
#define MARKER_TYPE_MARKER				@"marker"
#define MARKER_TYPE_EXPRESSION			@"expression"
#define MARKER_ARGUMENTS_KEY			@"args"				
#define MARKER_FILTER_KEY				@"filter"			
#define MARKER_FILTER_ARGUMENTS_KEY		@"filterArgs"		
#define MARKER_RANGE_KEY				@"range"			

@protocol MGTemplateEngineMatcher <NSObject>
@required
- (id)initWithTemplateEngine:(MGTemplateEngine *)engine;

- (void)engineSettingsChanged; 
- (NSDictionary *)firstMarkerWithinRange:(NSRange)range;

@end

#import "MGTemplateMarker.h"
#import "MGTemplateFilter.h"

@interface MGTemplateEngine : NSObject

@property(atomic,retain) NSString *markerStartDelimiter;

@property(atomic,retain) NSString *markerEndDelimiter;

@property(atomic,retain) NSString *expressionStartDelimiter;

@property(atomic,retain) NSString *expressionEndDelimiter;

@property(atomic,retain) NSString *filterDelimiter;

@property(atomic,retain) NSString *literalStartMarker;

@property(atomic,retain) NSString *literalEndMarker;

@property(atomic,readonly) NSRange remainingRange;

@property(atomic,weak) id <MGTemplateEngineDelegate> delegate;	
@property(atomic,retain) id <MGTemplateEngineMatcher> matcher;

@property(atomic,readonly) NSString *templateContents;

+ (NSString *)engineVersion;

+ (MGTemplateEngine *)templateEngine;

- (void)setObject:(id)anObject forKey:(id)aKey;

- (void)addEntriesFromDictionary:(NSDictionary *)dict;

- (id)objectForKey:(id)aKey;

- (void)loadMarker:(id<MGTemplateMarker>)marker;

- (void)loadFilter:(id<MGTemplateFilter>)filter;

- (NSObject *)resolveVariable:(NSString *)var;

- (NSDictionary *)templateVariables;

- (NSString *)processTemplate:(NSString *)templateString withVariables:(NSDictionary *)variables;

- (NSString *)processTemplateInFileAtPath:(NSString *)templatePath withVariables:(NSDictionary *)variables;

@end
