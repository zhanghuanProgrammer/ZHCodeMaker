#import "ZHRecycleView.h"
#import "ZHActivity.h"
#import "ZHActivityXML.h"
#import "ZHAndroidModel.h"
#import "ZHAndroifAdapter.h"
#import "ZHAndroidItemXml.h"

@implementation ZHRecycleView

- (void)Begin:(NSString *)str toView:(UIView *)view{
    [self backUp:str];
    NSDictionary *dic=[self getDicFromFileName:str];
    
    if(![self judge:dic[@"最大文件夹名字"]]){
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写文件夹名字,创建失败!" withDuration:1 animated:NO];
        return;
    }
    
    NSString *fatherDirector=[self creatFatherFileDirector:dic[@"最大文件夹名字"] toFatherDirector:nil];
    [self creatFatherFileDirector:dic[@"Activity名字"] toFatherDirector:fatherDirector];
    [self creatFatherFileDirector:[dic[@"Activity名字"] stringByAppendingString:@"Layout"] toFatherDirector:fatherDirector];
    
    //如果没有填写dic[@"ViewController的名字"]那么就默认只生成MVC文件夹
    if (![self judge:dic[@"Activity名字"]]) {
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写 Activity名字 那么就默认只生成文件夹!" withDuration:1 animated:NO];
        return;
    }
    
    //1.创建Activity.java
    NSMutableString *textStrM=[NSMutableString string];
    [textStrM setString:[[ZHActivity new] getRecycleViewActivityWithParameter:dic]];
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],dic[@"Activity名字"],[NSString stringWithFormat:@"%@.java",dic[@"Activity名字"]]]];
    
    //2.创建Activity.xml
    [textStrM setString:@""];
    [textStrM setString:[[ZHActivityXML new] getRecycleViewActivityXMLWithParameter:dic]];
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],[dic[@"Activity名字"] stringByAppendingString:@"Layout"],[NSString stringWithFormat:@"%@.xml",[@"activity_" stringByAppendingString:[dic[@"Activity名字"] underlineFromCamel]]]]];
    
    //3.创建models.java
    NSString *cells=dic[@"自定义item,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [textStrM setString:@""];
            [textStrM setString:[[ZHAndroidModel new] getAndroidModelWithModelName:cell package:dic[@"package"] fileDirector:dic[@"Activity名字"] WithParameter:dic[cell]]];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],dic[@"Activity名字"],[NSString stringWithFormat:@"%@Model.java",cell]]];
        }
    }
    
    //4.创建Adapter.java
    [textStrM setString:@""];
    [textStrM setString:[[ZHAndroifAdapter new] getAndroifAdapterWithParameter:dic]];
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],dic[@"Activity名字"],[NSString stringWithFormat:@"%@Adapter.java",dic[@"Activity名字"]]]];
    
    //4.创建items.java
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [textStrM setString:@""];
            [textStrM setString:[[ZHAndroidItemXml new] getAndroidItemXmlWithParameter:dic[cell]]];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],[dic[@"Activity名字"] stringByAppendingString:@"Layout"],[NSString stringWithFormat:@"%@_item.xml",[cell underlineFromCamel]]]];
        }
    }
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
    [MBProgressHUD showHUDAddedToView:view withText:@"生成成功!" withDuration:1 animated:NO];
}
@end
