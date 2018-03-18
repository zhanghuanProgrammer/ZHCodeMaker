#import "JGShop.h"

@implementation JGShop
- (NSString *)description{
    return [NSString stringWithFormat:@"%@-%@-%f-%f",self.price,self.img,self.w,self.h];
}
@end
