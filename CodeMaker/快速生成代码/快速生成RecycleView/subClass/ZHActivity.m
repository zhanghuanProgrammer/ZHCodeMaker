#import "ZHActivity.h"

@implementation ZHActivity
- (NSString *)getRecycleViewActivityWithParameter:(NSDictionary *)parameter{
    
    NSMutableString *textStrM=[NSMutableString string];
    NSString *ActivityName=parameter[@"Activity名字"];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"package %@;",parameter[@"package"]],@""] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[
                                   [NSString stringWithFormat:@"/**\n\
                                    * Created by mac on %@.\n\
                                    */",[DateTools currentDate_yyyy_MM_dd]],
                                   [NSString stringWithFormat:@"public class %@ extends AppCompatActivity {\n\
                                    \n\
                                    private RecyclerView mRecyclerView;\n\
                                    private %@Adapter mAdapter;\n\
                                    private ArrayList listData;\n\
                                    \n\
                                    protected void onCreate(Bundle savedInstanceState) {\n\
                                    super.onCreate(savedInstanceState);\n\
                                    setContentView(R.layout.activity_%@);\n\
                                    \n\
                                    mRecyclerView=(RecyclerView) findViewById(R.id.MyRecyclerView);\n\
                                    GridLayoutManager layoutManager=new GridLayoutManager(this, 1);\n\
                                    mRecyclerView.setLayoutManager(layoutManager);\n\
                                    \n\
                                    listData=new ArrayList <>();\n\
                                    initData();\n\
                                    \n\
                                    mAdapter=new %@Adapter(listData, this);\n\
                                    mRecyclerView.setAdapter(mAdapter);\n\
                                    }\n\
                                    ",ActivityName,ActivityName,[[ActivityName firstCharLower]underlineFromCamel],ActivityName]
                                   ,@"private void initData(){"] ToStrM:textStrM];
    
    NSString *cells=parameter[@"自定义item,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    
    //假数据
    NSMutableString *fakeDataStrM=[NSMutableString string];
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@Model %@Model=new %@Model();",cell,[cell firstCharLower],cell]] ToStrM:fakeDataStrM];
            NSDictionary *itemParameter=parameter[cell];
            if (itemParameter) {//如果含有子控件
                for (NSString *key in itemParameter) {
                    NSString *values=itemParameter[key];
                    NSArray *arrValues=[values componentsSeparatedByString:@","];
                    if ([self judge:values]) {
                        for (NSString *value in arrValues) {
                            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@Model.set%@(\"\");",[cell firstCharLower],[ZHNSString upFirstCharacter:value]]] ToStrM:fakeDataStrM];
                        }
                    }
                }
            }
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"listData.add(%@Model);\n",[cell firstCharLower]]] ToStrM:fakeDataStrM];
        }
    }
    
    if (fakeDataStrM.length>0)
    [self insertValueAndNewlines:@[fakeDataStrM] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"}\n\
                                   }\n"] ToStrM:textStrM];
    
    return textStrM;
}
@end
