#import "ZHAndroifAdapter.h"

@implementation ZHAndroifAdapter
- (NSString *)getAndroifAdapterWithParameter:(NSDictionary *)parameter{
    NSMutableString *textStrM=[NSMutableString string];
    NSString *ActivityName=parameter[@"Activity名字"];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"package %@.%@;",parameter[@"package"],parameter[@"Activity名字"]]] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[
                                   [NSString stringWithFormat:@"/**\n\
                                    * Created by mac on %@.\n\
                                    */",[DateTools currentDate_yyyy_MM_dd]],
                                   [NSString stringWithFormat:@"public class %@Adapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {\n",ActivityName]
                                   ] ToStrM:textStrM];
    
    NSString *cells=parameter[@"自定义item,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"private static final int DefaultItem = 0;"]] ToStrM:textStrM];
    
    if ([self judge:cells]) {
        NSInteger index=1;
        for (NSString *cell in arrCells) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"private static final int %@Item = %zd;",cell,index]] ToStrM:textStrM];
            index++;
        }
    }
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\npublic ArrayList datas = null;\n\
                                    private Context mContext=null;\n\
                                    \n\
                                    public %@Adapter(ArrayList datas,Context mContext) {\n\
                                    this.datas = datas;\n\
                                    this.mContext=mContext;\n\
                                    }",ActivityName]] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n@Override\n\
                                    public int getItemCount() {\n\
                                    return datas.size();\n\
                                    }\n"],
                                   @"@Override\n\
                                   public int getItemViewType(int position) {\n\
                                   Object object=datas.get(position);"] ToStrM:textStrM];
    
    NSMutableString *fakeDataStrM=[NSMutableString string];
    if ([self judge:cells]) {
        NSInteger index=0;
        for (NSString *cell in arrCells) {
            if (index==0) {
                [fakeDataStrM appendFormat:@"if (object instanceof %@Model) {\n\
                 return %@Item;\n\
                 }",cell,cell];
            }else{
                [fakeDataStrM appendFormat:@"else if (object instanceof %@Model) {\n\
                 return %@Item;\n\
                 }",cell,cell];
            }
            index++;
        }
    }
    [fakeDataStrM appendFormat:@"\nreturn DefaultItem;"];
    if (fakeDataStrM.length>0)
        [self insertValueAndNewlines:@[fakeDataStrM] ToStrM:textStrM];
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    
    
    [self insertValueAndNewlines:@[@"@Override\n\
                                   public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {\n\
                                   Object object=datas.get(position);"] ToStrM:textStrM];
    
    [fakeDataStrM setString:@""];
    if ([self judge:cells]) {
        NSInteger index=0;
        for (NSString *cell in arrCells) {
            if (index==0) {
                [fakeDataStrM appendFormat:@"if (object instanceof %@Model&&holder instanceof ViewHolder%@) {\n\
                 ViewHolder%@ holder%@=(ViewHolder%@) holder;\n\
                 %@Model model=(%@Model)object;\n\
                 holder%@.bindData(model,position);\n\
                 }",cell,cell,cell,cell,cell,cell,cell,cell];
            }else{
                [fakeDataStrM appendFormat:@"else if (object instanceof %@Model&&holder instanceof ViewHolder%@) {\n\
                 ViewHolder%@ holder%@=(ViewHolder%@) holder;\n\
                 %@Model model=(%@Model)object;\n\
                 holder%@.bindData(model,position);\n\
                 }",cell,cell,cell,cell,cell,cell,cell,cell];
            }
            index++;
        }
    }
    if (fakeDataStrM.length>0)
        [self insertValueAndNewlines:@[fakeDataStrM] ToStrM:textStrM];
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"@Override\n\
                                   public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {\n\
                                   View view=new TextView(mContext);\n\
                                   switch (viewType){"] ToStrM:textStrM];
    
    [fakeDataStrM setString:@""];
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [fakeDataStrM appendFormat:@"case %@Item:{\n\
             view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.%@_item,viewGroup,false);\n\
             return new ViewHolder%@(view);\n\
             }\n",cell,[cell underlineFromCamel],cell];
        }
    }
    if (fakeDataStrM.length>0)
        [self insertValueAndNewlines:@[fakeDataStrM] ToStrM:textStrM];
    [self insertValueAndNewlines:@[@"}\n\
                                   return new ViewHolderDefault(view);\n\
                                   }\n"] ToStrM:textStrM];
    
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"public static class ViewHolder%@ extends RecyclerView.ViewHolder {\n",cell]] ToStrM:textStrM];
            NSDictionary *itemParameter=parameter[cell];
            if (itemParameter) {//如果含有子控件
                for (NSString *key in itemParameter) {
                    NSString *values=itemParameter[key];
                    NSArray *arrValues=[values componentsSeparatedByString:@","];
                    if ([self judge:values]) {
                        for (NSString *value in arrValues) {
                            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"public %@ %@;",key,value]] ToStrM:textStrM];
                        }
                    }
                }
            }
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\npublic ViewHolder%@(View view){\nsuper(view);",cell]] ToStrM:textStrM];
            if (itemParameter) {//如果含有子控件
                for (NSString *key in itemParameter) {
                    NSString *values=itemParameter[key];
                    NSArray *arrValues=[values componentsSeparatedByString:@","];
                    if ([self judge:values]) {
                        for (NSString *value in arrValues) {
                            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@ = (%@) view.findViewById(R.id.%@);",value,key,value]] ToStrM:textStrM];
                        }
                    }
                }
            }
            [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"public void bindData(%@Model model, int position) {",cell]] ToStrM:textStrM];
            if (itemParameter) {//如果含有子控件
                for (NSString *key in itemParameter) {
                    NSString *values=itemParameter[key];
                    NSArray *arrValues=[values componentsSeparatedByString:@","];
                    if ([self judge:values]) {
                        for (NSString *value in arrValues) {
                            if ([key isEqualToString:@"ImageView"]) {
                                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@.setImageResource(Integer.parseInt(model.get%@()));",value,[ZHNSString upFirstCharacter:value]]] ToStrM:textStrM];
                            }else{
                                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@.setText(model.get%@());",value,[ZHNSString upFirstCharacter:value]]] ToStrM:textStrM];
                            }
                        }
                    }
                }
            }
            [self insertValueAndNewlines:@[@"}\n}\n"] ToStrM:textStrM];
        }
    }
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"public static class ViewHolderDefault extends RecyclerView.ViewHolder{\n\
                                    public ViewHolderDefault(View itemView) {\n\
                                    super(itemView);\n\
                                    }\n\
                                    }\n"]] ToStrM:textStrM];
    
    
    [self insertValueAndNewlines:@[@"}"] ToStrM:textStrM];
    
    return textStrM;
}
@end
