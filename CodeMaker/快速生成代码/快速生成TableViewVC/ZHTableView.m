#import "ZHTableView.h"

@implementation ZHTableView
- (void)Begin:(NSString *)str toView:(UIView *)view{
    [self backUp:str];
    NSDictionary *dic=[self getDicFromFileName:str];
    
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
    //1.创建ViewController.h
    
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>\n",[NSString stringWithFormat:@"@interface %@ViewController : UIViewController",dic[@"ViewController的名字"]],@"",@"@end",@""] ToStrM:textStrM];
    
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"controller",[NSString stringWithFormat:@"%@ViewController.h",dic[@"ViewController的名字"]]]];
    
    [textStrM setString:@""];
    
    //创建ViewController.m
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@ViewController.h\"",dic[@"ViewController的名字"]],@""] ToStrM:textStrM];
    
    NSString *cells=dic[@"自定义Cell,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@TableViewCell.h\"",cell]] ToStrM:textStrM];
        }
    }
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n@interface %@ViewController ()<UITableViewDataSource,UITableViewDelegate>\n",dic[@"ViewController的名字"]],@"@property (weak, nonatomic) IBOutlet UITableView *tableView;\n"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"@property (nonatomic,strong)NSMutableArray *dataArr;",@""] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"@end",@"\n",[NSString stringWithFormat:@"@implementation %@ViewController",dic[@"ViewController的名字"]]] ToStrM:textStrM];
    
    //假数据
    NSMutableString *fakeDataStrM=[NSMutableString string];
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [fakeDataStrM appendFormat:@"%@CellModel *%@Model=[%@CellModel new];\n%@Model.title=@\"\";\n%@Model.iconImageName=@\"\";\n[_dataArr addObject:%@Model];\n//[self.dataArr addObject:%@Model];\n",cell,[ZHNSString lowerFirstCharacter:cell],cell,[ZHNSString lowerFirstCharacter:cell],[ZHNSString lowerFirstCharacter:cell],[ZHNSString lowerFirstCharacter:cell],[ZHNSString lowerFirstCharacter:cell]];
            }
        }
    }
    
    if (fakeDataStrM.length==0)[fakeDataStrM setString:@""];;
    [self insertValueAndNewlines:@[@"\n- (NSMutableArray *)dataArr{",@"if (!_dataArr) {",@"_dataArr=[NSMutableArray array];",fakeDataStrM,@"}",@"return _dataArr;",@"}"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"\n- (void)viewDidLoad{",@"[super viewDidLoad];",@"self.tableView.delegate=self;",@"self.tableView.dataSource=self;",@"self.tableView.tableFooterView=[UIView new];",@"//self.edgesForExtendedLayout=UIRectEdgeNone;"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    
    if ([dic[@"是否分组 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"#pragma mark - TableViewDelegate实现的方法:",@"- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{",@"return self.dataArr.count;",@"}"] ToStrM:textStrM];
        [self insertValueAndNewlines:@[@"- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{",@"return [self.dataArr[section] count];",@"}"] ToStrM:textStrM];
    }else{
        [self insertValueAndNewlines:@[@"#pragma mark - TableViewDelegate实现的方法:",@"- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{",@"return 1;",@"}"] ToStrM:textStrM];
        [self insertValueAndNewlines:@[@"- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{",@"return self.dataArr.count;",@"}"] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{"] ToStrM:textStrM];

    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"])[self insertValueAndNewlines:@[@"id modelObjct=self.dataArr[indexPath.row];"] ToStrM:textStrM];
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:cell];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cell],[NSString stringWithFormat:@"%@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];",cell,tempCell,cell],[NSString stringWithFormat:@"%@CellModel *model=modelObjct;",cell],[NSString stringWithFormat:@"[%@Cell refreshUI:model];",tempCell],[NSString stringWithFormat:@"return %@Cell;",tempCell],@"}"] ToStrM:textStrM];
            }else{
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];",cell,tempCell,cell]] ToStrM:textStrM];
            }
        }
    }
    [self insertValueAndNewlines:@[@"//随便给一个cell\nUITableViewCell *cell=[UITableViewCell new];",@"return cell;",@"}"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{"] ToStrM:textStrM];
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"])[self insertValueAndNewlines:@[@"id modelObjct=self.dataArr[indexPath.row];"] ToStrM:textStrM];
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cell],@"return 44.0f;",@"}"] ToStrM:textStrM];
            }
        }
    }
    [self insertValueAndNewlines:@[@"return 44.0f;",@"}"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{",@"[tableView deselectRowAtIndexPath:indexPath animated:YES];",@"}",@"\n"] ToStrM:textStrM];
    
    if ([dic[@"是否分组 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{\n\
                                       if (section==0) {\n\
                                       return 0.001;\n\
                                       }\n\
                                       return 15.0f;\n\
                                       }\n\
                                       \n\
                                       - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{\n\
                                       if (section==self.dataArr.count-1) {\n\
                                       return 15.0f;\n\
                                       }\n\
                                       return 0.001;\n\
                                       }"] ToStrM:textStrM];
    }
    
    if ([dic[@"自定义cell可编辑(删除) 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        
        [self insertValueAndNewlines:@[@"/**是否可以编辑*/\n- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{\nif (indexPath.row==self.dataArr.count) {\nreturn NO;\n}\nreturn YES;\n}\n\n/**编辑风格*/\n- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{\nreturn UITableViewCellEditingStyleDelete;\n}\n\n",@"/**设置编辑的控件  删除,置顶,收藏*/\n- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{\n\n//设置删除按钮\n\
                                       UITableViewRowAction *deleteRowAction=[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@\"删除\" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {\n\
            [self.dataArr removeObjectAtIndex:indexPath.row];\n\
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:\(UITableViewRowAnimationAutomatic)];\n\
        }];\n\
                                       return  @[deleteRowAction];\n\
                                       }\n\n"
                                       ] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"controller",[NSString stringWithFormat:@"%@ViewController.m",dic[@"ViewController的名字"]]]];
    
    //3.创建cells 和models
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [textStrM setString:@""];
            [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>"] ToStrM:textStrM];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell]] ToStrM:textStrM];
            }
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@TableViewCell : UITableViewCell",cell]] ToStrM:textStrM];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n- (void)refreshUI:(%@CellModel *)dataModel;\n",cell]] ToStrM:textStrM];
            }
            [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@TableViewCell.h",cell]]];
            
            [textStrM setString:@""];
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@TableViewCell.h\"\n",cell]] ToStrM:textStrM];
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@TableViewCell ()\n",cell],@"@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;",@"@property (weak, nonatomic) IBOutlet UILabel *nameLabel;",@"",[NSString stringWithFormat:@"@property (nonatomic,weak)%@CellModel *dataModel;",cell],@"\n@end\n"] ToStrM:textStrM];
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@implementation %@TableViewCell",cell]] ToStrM:textStrM];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel{",cell],@"_dataModel=dataModel;",@"self.nameLabel.text=dataModel.title;\n\
                                               self.iconImageView.image=[UIImage imageNamed:dataModel.iconImageName];",@"}\n"] ToStrM:textStrM];
            }
            [self insertValueAndNewlines:@[@"- (void)awakeFromNib {",@"[super awakeFromNib];",@"//self.selectionStyle=UITableViewCellSelectionStyleNone;\n\
                                           //self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;",@"}\n\n",@"- (void)setSelected:(BOOL)selected animated:(BOOL)animated {",@"[super setSelected:selected animated:animated];",@"}\n",@"@end"] ToStrM:textStrM];
            
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@TableViewCell.m",cell]]];
            
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [textStrM setString:@""];
                
                [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>",[NSString stringWithFormat:@"@interface %@CellModel : NSObject",cell],@"\n@property (nonatomic,copy)NSString *iconImageName;\n\
                                               @property (nonatomic,assign)BOOL isSelect;\n\
                                               @property (nonatomic,assign)BOOL shouldShowImage;\n\
                                               @property (nonatomic,copy)NSString *title;\n\
                                               \n\
                                               @property (nonatomic,copy)NSString *content;\n\
                                               @property (nonatomic,assign)CGSize size;\n\
                                               @property (nonatomic,assign)CGFloat width;\n\
                                               @property (nonatomic,strong)NSMutableArray *dataArr;\n",@"@end"] ToStrM:textStrM];
                
                [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"model",[NSString stringWithFormat:@"%@CellModel.h",cell]]];
                
                [textStrM setString:@""];
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell],[NSString stringWithFormat:@"\n@implementation %@CellModel",cell],@"\n- (NSMutableArray *)dataArr{\n\
                                               if (!_dataArr) {\n\
                                               _dataArr=[NSMutableArray array];\n\
                                               }\n\
                                               return _dataArr;\n\
                                               }",@"- (void)setContent:(NSString *)content{\n\
                                               _content=content;\n\
                                               if (self.width==0) {\n\
                                               self.width=200;\n\
                                               }\n\
                                               self.size=[content boundingRectWithSize:CGSizeMake(self.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;\n\
                                               }",@"\n@end"] ToStrM:textStrM];
                
                [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"model",[NSString stringWithFormat:@"%@CellModel.m",cell]]];
            }
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
