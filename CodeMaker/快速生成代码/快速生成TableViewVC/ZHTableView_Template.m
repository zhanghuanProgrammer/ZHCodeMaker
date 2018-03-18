#import "ZHTableView_Template.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"

@implementation ZHTableView_Template
- (void)Begin:(NSString *)str toView:(UIView *)view{
    [self backUp:str];
    NSDictionary *dic=[self getDicFromFileName:str];
    
    NSMutableDictionary *parameter=[NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *cells=dic[@"自定义Cell,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    parameter[@"自定义Cell,以逗号隔开"]=arrCells;
    
    if(![self judge:dic[@"最大文件夹名字"]]){
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写文件夹名字,创建MVC失败!" withDuration:1 animated:NO];
        return;
    }
    
    NSString *fatherDirector=[self creatFatherFileDirector:dic[@"最大文件夹名字"] toFatherDirector:nil];
    [self creatFatherFileDirector:@"controller" toFatherDirector:fatherDirector];
    [self creatFatherFileDirector:@"view" toFatherDirector:fatherDirector];
    [self creatFatherFileDirector:@"model" toFatherDirector:fatherDirector];
    
    //如果没有填写dic[@"ViewController的名字"]那么就默认只生成MVC文件夹
    if (![self judge:dic[@"ViewController的名字"]]) {
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写 ViewController的名字 那么就默认只生成MVC文件夹!" withDuration:1 animated:NO];
        return;
    }
    
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    
    //1.创建ViewController.h
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"ViewController_h" ofType:@"txt"];
    NSString *textStrM=[engine processTemplateInFileAtPath:templatePath withVariables:parameter];
    
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"controller",[NSString stringWithFormat:@"%@ViewController.h",dic[@"ViewController的名字"]]]];
    
    
    //创建ViewController.m
    templatePath = [[NSBundle mainBundle] pathForResource:@"ViewController_m" ofType:@"txt"];
    textStrM=[engine processTemplateInFileAtPath:templatePath withVariables:parameter];

    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"controller",[NSString stringWithFormat:@"%@ViewController.m",dic[@"ViewController的名字"]]]];
    
    
    //3.创建cells 和models
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            
            NSDictionary *variables=@{@"CellModel":[NSString stringWithFormat:@"%@CellModel",cell],@"TableViewCell":[NSString stringWithFormat:@"%@TableViewCell",cell]};
            //创建cells
            templatePath = [[NSBundle mainBundle] pathForResource:@"TableViewCell_h" ofType:@"txt"];
            textStrM=[engine processTemplateInFileAtPath:templatePath withVariables:variables];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@TableViewCell.h",cell]]];
            
            templatePath = [[NSBundle mainBundle] pathForResource:@"TableViewCell_m" ofType:@"txt"];
            textStrM=[engine processTemplateInFileAtPath:templatePath withVariables:variables];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@TableViewCell.m",cell]]];
            
            //创建models
            templatePath = [[NSBundle mainBundle] pathForResource:@"CellModel_h" ofType:@"txt"];
            textStrM=[engine processTemplateInFileAtPath:templatePath withVariables:variables];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"model",[NSString stringWithFormat:@"%@CellModel.h",cell]]];
            
            templatePath = [[NSBundle mainBundle] pathForResource:@"CellModel_m" ofType:@"txt"];
            textStrM=[engine processTemplateInFileAtPath:templatePath withVariables:variables];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"model",[NSString stringWithFormat:@"%@CellModel.m",cell]]];
        }
    }
    
    //如果需要StroyBoard
    if([dic[@"是否需要对应的StroyBoard 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        //这里有较多需要判断的情况
        //1.假如  ViewController的名字 不存在
        if (![self judge:dic[@"ViewController的名字"]]) {
            [self saveStoryBoard:@"" TableViewCells:nil toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
        }else{
            //没有cells
            if (![self judge:dic[@"自定义Cell,以逗号隔开"]]) {
                [self saveStoryBoard:dic[@"ViewController的名字"] TableViewCells:nil toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
            }else{//有cells
                NSArray *arr=[dic[@"自定义Cell,以逗号隔开"] componentsSeparatedByString:@","];
                NSMutableArray *arrM=[NSMutableArray array];
                for (NSString *str in arr) {
                    [arrM addObject:[str stringByAppendingString:@"TableViewCell"]];
                }
                [self saveStoryBoard:dic[@"ViewController的名字"] TableViewCells:arrM toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
            }
        }
    }
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
    
    [MBProgressHUD showHUDAddedToView:view withText:@"生成成功!" withDuration:1 animated:NO];
}
@end
