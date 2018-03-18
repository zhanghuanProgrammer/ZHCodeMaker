#import "StringSimilarity.h"

@implementation StringSimilarity
+ (NSInteger)min:(NSInteger)a :(NSInteger)b :(NSInteger)c{
    if(a < b) {
        if(a < c)
            return a;
        else
            return c;
    } else {
        if(b < c)
            return b;
        else
            return c;
    }
}
+ (NSInteger)compute_distance:(NSString *)strA :(NSInteger)len_a :(NSString *)strB :(NSInteger)len_b :(NSInteger **)temp{
    NSInteger i, j;
    
    for(i = 1; i <= len_a; i++) {
        temp[i][0] = i;
    }
    
    for(j = 1; j <= len_b; j++) {
        temp[0][j] = j;
    }
    
    temp[0][0] = 0;
    
    for(i = 1; i <= len_a; i++) {
        for(j = 1; j <= len_b; j++) {
            if([strA characterAtIndex:i -1] == [strB characterAtIndex:j - 1]) {
                temp[i][j] = temp[i - 1][j - 1];
            } else {
                temp[i][j] =[self min:temp[i - 1][j] :temp[i][j - 1] :temp[i - 1][j - 1]] + 1;
            }
        }
    }
    return temp[len_a][len_b];
}

+ (NSInteger)similarity:(NSString *)stringA :(NSString *)stringB{
    NSInteger len_a = stringA.length;
    NSInteger len_b = stringB.length;
    NSInteger **temp = (NSInteger**)malloc(sizeof(NSInteger*) * (len_a + 1));
    for(int i = 0; i < len_a + 1; i++) {
        temp[i] = (NSInteger*)malloc(sizeof(NSInteger) * (len_b + 1));
        memset(temp[i], 0, sizeof(NSInteger) * (len_b + 1));
    }
    NSInteger distance =[self compute_distance:stringA :len_a :stringB :len_b :temp];
    for(int i = 0; i < len_a + 1; i++) {
        free(temp[i]);
    }
    free(temp);
    return distance;
}

@end
