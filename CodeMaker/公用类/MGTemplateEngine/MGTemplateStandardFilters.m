
#import "MGTemplateStandardFilters.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"

#define UPPERCASE		@"uppercase"
#define ColorFloat      @"colorfloat"
#define LOWERCASE		@"lowercase"
#define CAPITALIZED		@"capitalized"
#define DATE_FORMAT		@"date_format"
#define COLOR_FORMAT	@"color_format"
#define DEFAULT         @"default"
#define RECURRENCE      @"recurrence"
#define COMPONENT       @"component"

@implementation MGTemplateStandardFilters


- (NSArray *)filters
{
    return [NSArray arrayWithObjects:
             UPPERCASE, LOWERCASE, CAPITALIZED, 
             DATE_FORMAT, COLOR_FORMAT,
             DEFAULT,ColorFloat,RECURRENCE,COMPONENT,
             nil];
}

- (NSString*) stringsConcatenatedWithSpaces: (NSArray*) array {
    NSMutableString* result = [NSMutableString string];
    for (NSString* item in array) {
        [result appendFormat: @"%@ ", item];
    }
    return result;
}

- (id)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(id)value
{
	if ([filter isEqualToString:UPPERCASE]) {
		return [[NSString stringWithFormat:@"%@", value] uppercaseString];
		
	} else if ([filter isEqualToString:LOWERCASE]) {
		return [[NSString stringWithFormat:@"%@", value] lowercaseString];
		
    } else if ([filter isEqualToString:ColorFloat]) {
        return [NSString stringWithFormat:@"%f",[[NSString stringWithFormat:@"%@", value] floatValue]/255.0];
        
    } else if ([filter isEqualToString:COMPONENT]) {
        if ([value isKindOfClass:[NSArray class]]) {
            return [(NSArray *)value componentsJoinedByString:@"\n"];
        }
    } else if ([filter isEqualToString:CAPITALIZED]) {
		return [[NSString stringWithFormat:@"%@", value] capitalizedString];
		
    } else if ([filter isEqualToString:RECURRENCE]) {
        if ([value isKindOfClass:[NSDictionary class]] && [args count] == 1) {
            NSString *fileName = [args objectAtIndex:0];
            MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
            [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
            NSString *templatePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
            NSString *resultH = [engine processTemplateInFileAtPath:templatePath withVariables:@{@"root":value}];
            return resultH;
        }
        
    } else if ([filter isEqualToString:DATE_FORMAT]) {
		if ([value isKindOfClass:[NSDate class]] && [args count] == 1) {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			NSString *format = [args objectAtIndex:0];
			[dateFormatter setDateFormat:format];
			return [dateFormatter stringFromDate:(NSDate *)value];
		}
		
	} else if ([filter isEqualToString:COLOR_FORMAT]) {
#if TARGET_OS_IPHONE
        if ([value isKindOfClass:[UIColor class]] && [args count] == 1) {
#else
		if ([value isKindOfClass:[NSColor class]] && [args count] == 1) {
#endif
			NSString *format = [[args objectAtIndex:0] lowercaseString];
			if ([format isEqualToString:@"hex"]) {
#if TARGET_OS_IPHONE
                CGColorRef color = [(UIColor *)value CGColor];
                CGColorSpaceRef colorSpace = CGColorGetColorSpace(color);
                CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
                
                if (colorSpaceModel != kCGColorSpaceModelRGB)
                    return @"000000";
                
                const CGFloat *components = CGColorGetComponents(color);
                NSString *colorHex = [NSString stringWithFormat:@"%02x%02x%02x",
                                      (unsigned int)(components[0] * 255),
                                      (unsigned int)(components[1] * 255),
                                      (unsigned int)(components[2] * 255)];
                return colorHex;
#else
				NSColor *color = [(NSColor *)value colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
				if (!color) { 
					return @"000000"; 
				} else {
					NSString *colorHex = [NSString stringWithFormat:@"%02x%02x%02x", 
										  (unsigned int)([color redComponent] * 255),
										  (unsigned int)([color greenComponent] * 255),
										  (unsigned int)([color blueComponent] * 255)];
					return colorHex;
				}
#endif
			}
		}
    } else if ([filter isEqualToString: DEFAULT]) {
        if (!value) {
            return [self stringsConcatenatedWithSpaces: args];
        }
        if ([value isKindOfClass: [NSString class]] && [(NSString*)value length] == 0) {
            return [self stringsConcatenatedWithSpaces: args];
        }
    }
    return value;
}


@end
