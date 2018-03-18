
#import "NSArray_DeepMutableCopy.h"


@implementation NSArray (DeepMutableCopy)

- (NSMutableArray *)deepMutableCopy
{
    NSMutableArray *newArray;
    NSUInteger index, count;
	
    count = [self count];
    newArray = [[NSMutableArray alloc] initWithCapacity:count];
    for (index = 0; index < count; index++) {
        id anObject;
		
        anObject = [self objectAtIndex:index];
        if ([anObject respondsToSelector:@selector(deepMutableCopy)]) {
            anObject = [anObject deepMutableCopy];
            [newArray addObject:anObject];
        } else if ([anObject respondsToSelector:@selector(mutableCopyWithZone:)]) {
            anObject = [anObject mutableCopyWithZone:nil];
            [newArray addObject:anObject];
        } else {
            [newArray addObject:anObject];
        }
    }
	
    return newArray;
}


@end
