#import "ZHAndroidItemXml.h"

@implementation ZHAndroidItemXml

- (NSString *)getAndroidItemXmlWithParameter:(NSDictionary *)parameter{
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
                                   <LinearLayout xmlns:android=\"http://schemas.android.com/apk/res/android\"\n\
                                   android:orientation=\"vertical\"\n\
                                   android:background=\"#ffffff\"\n\
                                   android:layout_width=\"match_parent\"\n\
                                   android:layout_height=\"wrap_content\">\n\
                                   <RelativeLayout\n\
                                   android:layout_width=\"match_parent\"\n\
                                   android:layout_height=\"44dp\">"] ToStrM:textStrM];
    if (parameter) {//如果含有子控件
        for (NSString *key in parameter) {
            NSString *values=parameter[key];
            NSArray *arrValues=[values componentsSeparatedByString:@","];
            if ([self judge:values]) {
                for (NSString *value in arrValues) {
                    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"<%@\n\
                                                    android:id=\"@+id/%@\"\n\
                                                    android:layout_width=\"wrap_content\"\n\
                                                    android:layout_height=\"wrap_content\"\n\
                                                    />",key,value]] ToStrM:textStrM];
                }
            }
        }
    }
    [self insertValueAndNewlines:@[@"</RelativeLayout>\n\
                                   </LinearLayout>"] ToStrM:textStrM];
    return [[ZHXMLWordWrap new] wordWrapText:textStrM];
}

@end
