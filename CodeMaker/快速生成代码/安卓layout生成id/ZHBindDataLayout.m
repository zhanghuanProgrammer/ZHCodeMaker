#import "ZHBindDataLayout.h"

@implementation ZHBindDataLayout
- (NSString *)getBindDataLayoutWithParameter:(NSDictionary *)parameter{
    NSMutableString *textStrM=[NSMutableString string];
    
    [textStrM appendFormat:@"//----------对应的 onBindViewHolder-----------\n\n"];
    
    [self insertValueAndNewlines:@[@"if (object instanceof NormalModel&&holder instanceof ViewHolderNormal) {\n\
                                   ViewHolderNormal holderHead=(ViewHolderNormal) holder;\n\
                                   NormalModel model=(NormalModel)object;"] ToStrM:textStrM];
    if (parameter) {//如果含有子控件
        for (NSString *key in parameter) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"holderHead.%@.setText(model.get%@());",parameter[key],[ZHNSString upFirstCharacter:parameter[key]]]] ToStrM:textStrM];
        }
    }
    [self insertValueAndNewlines:@[@"}"] ToStrM:textStrM];
    
    return textStrM;
}

@end
