#import "ZHActivityXML.h"

@implementation ZHActivityXML

- (NSString *)getRecycleViewActivityXMLWithParameter:(NSDictionary *)parameter{
    
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
    <LinearLayout\n\
          xmlns:android=\"http://schemas.android.com/apk/res/android\"\n\
          xmlns:app=\"http://schemas.android.com/apk/res-auto\"\n\
          android:layout_width=\"match_parent\"\n\
          android:layout_height=\"match_parent\"\n\
          android:orientation=\"vertical\">\n\
          \n\
              <android.support.v7.widget.RecyclerView\n\
                     android:id=\"@+id/MyRecyclerView\"\n\
                     android:layout_width=\"match_parent\"\n\
                     android:layout_height=\"match_parent\"\n\
                     android:background=\"#eeeeee\"/>\n\
                                   \n\
              </LinearLayout>\n"] ToStrM:textStrM];

    return [[ZHXMLWordWrap new] wordWrapText:textStrM];
}

@end
