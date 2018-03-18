#import "tableViewContainColloectionView.h"

@implementation tableViewContainColloectionView
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
    
    if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [[self getZHBlockSingleCategroy_H] writeToFile:[fatherDirector stringByAppendingPathComponent:@"ZHBlockSingleCategroy.h"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [[self getZHBlockSingleCategroy_M] writeToFile:[fatherDirector stringByAppendingPathComponent:@"ZHBlockSingleCategroy.m"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    //1.创建ViewController.h
    
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>\n",[NSString stringWithFormat:@"@interface %@ViewController : UIViewController",dic[@"ViewController的名字"]],@"",@"@end",@""] ToStrM:textStrM];
    
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"controller",[NSString stringWithFormat:@"%@ViewController.h",dic[@"ViewController的名字"]]]];
    
    [textStrM setString:@""];
    
    //创建ViewController.m
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@ViewController.h\"",dic[@"ViewController的名字"]],@""] ToStrM:textStrM];
    
    if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"#import \"ZHBlockSingleCategroy.h\"",@""] ToStrM:textStrM];
    }
    
    NSString *cells=dic[@"自定义Cell,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@TableViewCell.h\"",cell]] ToStrM:textStrM];
        }
    }
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n@interface %@ViewController ()<UITableViewDataSource,UITableViewDelegate>\n",dic[@"ViewController的名字"]],@"@property (weak, nonatomic) IBOutlet UITableView *tableView;\n"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"@property (nonatomic,strong)NSMutableArray *dataArr;",@""] ToStrM:textStrM];
    
    
    if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"@property (nonatomic,strong)NSMutableDictionary *rowHeightDic;"] ToStrM:textStrM];
    }
    
    
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
    if (fakeDataStrM.length==0)[fakeDataStrM setString:@""];
    
    [self insertValueAndNewlines:@[@"- (NSMutableArray *)dataArr{",@"if (!_dataArr) {",@"_dataArr=[NSMutableArray array];",fakeDataStrM,@"}",@"return _dataArr;",@"}"] ToStrM:textStrM];
    
    if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"- (NSMutableDictionary *)rowHeightDic{\n\
                                       if (!_rowHeightDic) {\n\
                                       _rowHeightDic=[NSMutableDictionary dictionary];\n\
                                       }\n\
                                       return _rowHeightDic;\n\
                                       }"] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"\n- (void)viewDidLoad{",@"[super viewDidLoad];",@"self.tableView.delegate=self;",@"self.tableView.dataSource=self;",@"self.tableView.tableFooterView=[UIView new];",@"//self.edgesForExtendedLayout=UIRectEdgeNone;"] ToStrM:textStrM];
    
    if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n__weak typeof(self) weakSelf=self;\n\
                                        [ZHBlockSingleCategroy addBlockWithThreeCGFloat:^(CGFloat Float1, CGFloat Float2, CGFloat Float3) {\n\
                                        //Float1是indexPath.row Float2是indexPath.section Float3是嵌套控件的内容高度值 当cell中嵌套控件高度发生改变时,就会调用这个block来重新刷新对应行\n\
                                        \n//其实就是把每一行的高度保存到字典中\n\
                                        weakSelf.rowHeightDic[[NSString stringWithFormat:@\"%%ld_%%ld\",(long)Float1,(long)Float2]]=@(Float3+85);\n\
                                        [weakSelf.tableView reloadData];\n\
                                        } WithIdentity:@\"%@CellHeight\"];",dic[@"ViewController的名字"]]] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    
    
    [self insertValueAndNewlines:@[@"#pragma mark - TableViewDelegate实现的方法:",@"- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{",@"return 1;",@"}"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{",@"return self.dataArr.count;",@"}",@"- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{"] ToStrM:textStrM];
    
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"])[self insertValueAndNewlines:@[@"id modelObjct=self.dataArr[indexPath.row];"] ToStrM:textStrM];
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:cell];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cell],[NSString stringWithFormat:@"%@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];",cell,tempCell,cell],[NSString stringWithFormat:@"%@CellModel *model=modelObjct;",cell]] ToStrM:textStrM];
                if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
                    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@Cell.indexPath=indexPath;",tempCell]] ToStrM:textStrM];
                }
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"[%@Cell refreshUI:model];",tempCell],[NSString stringWithFormat:@"return %@Cell;",tempCell],@"}"] ToStrM:textStrM];
            }else{
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];",cell,tempCell,cell]] ToStrM:textStrM];
            }
        }
    }
    [self insertValueAndNewlines:@[@"//随便给一个cell\nUITableViewCell *cell=[UITableViewCell new];",@"return cell;",@"}"] ToStrM:textStrM];
    
    
    [self insertValueAndNewlines:@[@"- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{"] ToStrM:textStrM];
    
    if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"//如果字典中不存在这一行的高度,返回默认值,否则就会返回这一行最新的高度\n\
                                       if (self.rowHeightDic[[NSString stringWithFormat:@\"%ld_%ld\",indexPath.row,indexPath.section]]==nil) {\n\
                                       return 370.0;//返回默认高度,这个由自己写\n\
                                       }\n\
                                       return [self.rowHeightDic[[NSString stringWithFormat:@\"%ld_%ld\",indexPath.row,indexPath.section]] floatValue];"] ToStrM:textStrM];
    }else{
        if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"])[self insertValueAndNewlines:@[@"id modelObjct=self.dataArr[indexPath.row];"] ToStrM:textStrM];
        if ([self judge:cells]) {
            for (NSString *cell in arrCells) {
                if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cell],@"return 44.0f;",@"}"] ToStrM:textStrM];
                }
            }
        }
        [self insertValueAndNewlines:@[@"return 44.0f;"] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"}"] ToStrM:textStrM];
    
    
    [self insertValueAndNewlines:@[@"- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{",@"[tableView deselectRowAtIndexPath:indexPath animated:YES];",@"}",@"\n"] ToStrM:textStrM];
    
    if ([dic[@"是否需要titleForSection 1:0 (不填写么默认为否)"] isEqualToString:@"1"]&&[dic[@"是否需要右边的滑栏 1:0 (不填写么默认为否)"] isEqualToString:@"0"]) {
        [self insertValueAndNewlines:@[@"- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{\n\
                                       return @\"\";\n\
                                       }"] ToStrM:textStrM];
    }
    
    if ([dic[@"是否需要heightForSection 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
        [self insertValueAndNewlines:@[@"- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{\n\
                                       return 40.0f;\n\
                                       }\n\
                                       - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{\n\
                                       return 0.001f;\n\
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
    
    NSString *cellsContains=dic[@"自定义Cell标识符:(无:0 TableView:1(子cell以;隔开) ColloectionView:2(子cell以;隔开)),以逗号隔开"];
    NSArray *arrCellsContains=[cellsContains componentsSeparatedByString:@","];
    NSMutableArray *ContainArrM=[NSMutableArray array];
    NSMutableArray *subTableCells=[NSMutableArray array];
    BOOL hasContain=NO;//判断是否有嵌套
    if (arrCellsContains.count==arrCells.count) {
        hasContain=YES;
        
        NSInteger index=0;
        for (NSString *str in arrCellsContains) {
            if ([str isEqualToString:@"0"]) {
                [ContainArrM addObject:@"0"];
                [subTableCells addObject:[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@[] forKey:@"0"] forKey:arrCells[index]]];
            }else if ([str hasPrefix:@"1"]){
                NSMutableArray *tableViewCells=[NSMutableArray array];
                NSMutableArray *tableViewCells_new=[NSMutableArray array];
                [tableViewCells addObject:@"1"];
                NSString *subStr=[str substringFromIndex:1];
                if ([subStr hasPrefix:@"("]) {
                    subStr=[subStr substringFromIndex:1];
                }
                if ([subStr hasSuffix:@")"]) {
                    subStr=[subStr substringToIndex:subStr.length-1];
                }
                if ([subStr rangeOfString:@";"].location!=NSNotFound) {
                    NSArray *subArr=[subStr componentsSeparatedByString:@";"];
                    [tableViewCells_new addObjectsFromArray:subArr];
                    [tableViewCells addObjectsFromArray:subArr];
                }else{
                    [tableViewCells addObject:subStr];
                    [tableViewCells_new addObject:subStr];
                }
                
                [ContainArrM addObject:tableViewCells];
                [subTableCells addObject:[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:tableViewCells_new forKey:@"1"] forKey:arrCells[index]]];
            }else if ([str hasPrefix:@"2"]){
                NSMutableArray *collectionViewCells=[NSMutableArray array];
                NSMutableArray *collectionViewCells_new=[NSMutableArray array];
                
                [collectionViewCells addObject:@"2"];
                NSString *subStr=[str substringFromIndex:1];
                if ([subStr hasPrefix:@"("]) {
                    subStr=[subStr substringFromIndex:1];
                }
                if ([subStr hasSuffix:@")"]) {
                    subStr=[subStr substringToIndex:subStr.length-1];
                }
                if ([subStr rangeOfString:@";"].location!=NSNotFound) {
                    NSArray *subArr=[subStr componentsSeparatedByString:@";"];
                    [collectionViewCells addObjectsFromArray:subArr];
                    [collectionViewCells_new addObjectsFromArray:subArr];
                }else{
                    [collectionViewCells addObject:subStr];
                    [collectionViewCells_new addObject:subStr];
                }
                
                [ContainArrM addObject:collectionViewCells];
                [subTableCells addObject:[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:collectionViewCells_new forKey:@"2"] forKey:arrCells[index]]];
            }
            index++;
        }
    }
    
    if ([self judge:cells]) {
        NSInteger count=0;
        for (NSString *cell in arrCells) {
            [self createTableViewCell:cell withStrM:textStrM withInfoDic:dic withContainArrM:ContainArrM withhasContain:hasContain withIndex:count];
            count++;
        }
    }
    
    if (hasContain) {
        for (id obj in ContainArrM) {
            if ([obj isKindOfClass:[NSString class]]) {
                if ([obj isEqualToString:@"0"]) {
                    continue;
                }
            }else if ([obj isKindOfClass:[NSArray class]]){
                BOOL isTableView=NO;
                for (NSString *subStr in (NSArray *)obj) {
                    if ([subStr isEqualToString:@"1"]) {
                        isTableView=YES;
                        continue;
                    }else if ([subStr isEqualToString:@"2"]){
                        isTableView=NO;
                        continue;
                    }
                    
                    if (isTableView==YES) {
                        [self createTableViewCell:subStr withStrM:textStrM withInfoDic:dic withContainArrM:arrCellsContains withhasContain:NO withIndex:-1];
                    }else{
                        [self createCollectionViewCell:subStr withStrM:textStrM withInfoDic:dic withContainArrM:arrCellsContains withhasContain:NO];
                    }
                    
                }
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
                [self saveStoryBoard:dic[@"ViewController的名字"] TableViewCells:arrM subTableCells:subTableCells toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
            }
        }
    }
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
    
    [MBProgressHUD showHUDAddedToView:view withText:@"生成成功!" withDuration:1 animated:NO];
}

- (void)createTableViewCell:(NSString *)cell withStrM:(NSMutableString *)textStrM withInfoDic:(NSDictionary *)dic withContainArrM:(NSArray *)ContainArrM withhasContain:(BOOL)hasContain withIndex:(NSInteger)index{
    
    
    //TableViewCell.h
    
    [textStrM setString:@""];
    
    [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>"] ToStrM:textStrM];
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell]] ToStrM:textStrM];
    }
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@TableViewCell : UITableViewCell",cell]] ToStrM:textStrM];
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel;",cell]] ToStrM:textStrM];
    }
    if (hasContain) {
        if([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
            [self insertValueAndNewlines:@[@"\n@property (nonatomic,strong)NSIndexPath *indexPath;\n"] ToStrM:textStrM];
        }
    }
    [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@TableViewCell.h",cell]]];
    
    //TableViewCell.m
    
    [textStrM setString:@""];
    
    NSMutableArray *arrTableViewCells=[NSMutableArray array];
    NSMutableArray *arrCollectionViewCells=[NSMutableArray array];
    BOOL isTableView=NO;
    if (hasContain) {
        if (ContainArrM.count>index) {
            if ([ContainArrM[index] isKindOfClass:[NSArray class]]) {
                for (NSString *str in ContainArrM[index]) {
                    if ([str isEqualToString:@"1"]) {
                        isTableView=YES;
                        continue;
                    }
                    else if ([str isEqualToString:@"2"]) {
                        isTableView=NO;
                        continue;
                    }
                    if (isTableView==YES) {
                        [arrTableViewCells addObject:str];
                    }else{
                        [arrCollectionViewCells addObject:str];
                    }
                }
            }else if([ContainArrM[index] isKindOfClass:[NSString class]]){
                if ([ContainArrM[index] isEqualToString:@"0"]) {
                    hasContain=NO;
                }
            }
        }
    }
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@TableViewCell.h\"\n",cell]] ToStrM:textStrM];
    
    if (hasContain){
        
        if ([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]) {
            [self insertValueAndNewlines:@[@"#import \"ZHBlockSingleCategroy.h\"",@""] ToStrM:textStrM];
        }
        
        if (isTableView) {
            for (NSString *str in arrTableViewCells) {
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@TableViewCell.h\"",str]] ToStrM:textStrM];
            }
        }else{
            for (NSString *str in arrCollectionViewCells) {
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CollectionViewCell.h\"",str]] ToStrM:textStrM];
            }
        }
    }
    
    if (hasContain){
        if (isTableView) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@TableViewCell ()<UITableViewDataSource,UITableViewDelegate>",cell],@"",@"@property (nonatomic,strong)NSMutableArray *dataArr;",@"@property (weak, nonatomic) IBOutlet UITableView *tableView;"] ToStrM:textStrM];
        }else{
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@TableViewCell ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>",cell],@"",@"@property (nonatomic,strong)NSMutableArray *dataArr;",@"@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;"] ToStrM:textStrM];
            
        }
    }else{
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@TableViewCell ()",cell]] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;",@"@property (weak, nonatomic) IBOutlet UILabel *nameLabel;",@"",[NSString stringWithFormat:@"@property (nonatomic,weak)%@CellModel *dataModel;",cell]] ToStrM:textStrM];
    
    
    [self insertValueAndNewlines:@[@"@end\n",[NSString stringWithFormat:@"@implementation %@TableViewCell",cell]] ToStrM:textStrM];
    
    if (hasContain){
        [self insertValueAndNewlines:@[@"- (NSMutableArray *)dataArr{\n\
                                       if (!_dataArr) {\n\
                                       _dataArr=[NSMutableArray array];\n\
                                       }\n\
                                       return _dataArr;\n\
                                       }"] ToStrM:textStrM];
    }
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel{",cell],@"_dataModel=dataModel;",@"self.nameLabel.text=dataModel.title;\n\
                                       self.iconImageView.image=[UIImage imageNamed:dataModel.iconImageName];"] ToStrM:textStrM];
        if (hasContain){
            if (isTableView) {
                [self insertValueAndNewlines:@[@"[self.dataArr removeAllObjects];",@"[self.tableView reloadData];"] ToStrM:textStrM];
            }else{
                [self insertValueAndNewlines:@[@"[self.dataArr removeAllObjects];",@"[self.collectionView reloadData];"] ToStrM:textStrM];
            }
        }
        
        [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    }
    
    [self insertValueAndNewlines:@[@"- (void)awakeFromNib {",@"[super awakeFromNib];",@"//self.selectionStyle=UITableViewCellSelectionStyleNone;\n\
                                   //self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;"] ToStrM:textStrM];
    if (hasContain){
        if (isTableView==NO) {
            [self insertValueAndNewlines:@[@"[self addFlowLayoutToCollectionView:self.collectionView];\nself.collectionView.bounces=NO;"] ToStrM:textStrM];
        }else{
            [self insertValueAndNewlines:@[@"self.tableView.delegate=self;\n\
                                           self.tableView.dataSource=self;\n\
                                           self.tableView.tableFooterView=[UIView new];\
                                           \nself.tableView.bounces=NO;"] ToStrM:textStrM];
        }
    }
    
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"- (void)setSelected:(BOOL)selected animated:(BOOL)animated {",@"[super setSelected:selected animated:animated];",@"}\n"] ToStrM:textStrM];
    
    if (hasContain){
        if (isTableView==NO) {
            [self insertValueAndNewlines:@[@"/**为collectionView添加布局*/\n\
                                           - (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView{\n\
                                           UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];\n\
                                           \n\
                                           //flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平\n\
                                           flow.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直\n\
                                           \n\
                                           flow.minimumInteritemSpacing = 10;\n\
                                           flow.minimumLineSpacing = 10;\n\
                                           collectionView.collectionViewLayout=flow;\n\
                                           \n\
                                           // 设置代理:\n\
                                           self.collectionView.delegate=self;\n\
                                           self.collectionView.dataSource=self;\n\
                                           \n\
                                           collectionView.backgroundColor=[UIColor whiteColor];//背景颜色\n\
                                           \n\
                                           collectionView.contentInset=UIEdgeInsetsMake(10, 10, 10, 10);//内嵌值\n\
                                           }\n"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[@"#pragma mark - collectionView的代理方法:\n\
                                           // 1.返回组数:\n\
                                           - (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView\n\
                                           {\n\
                                           return 1;\n\
                                           }"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[@"// 2.返回每一组item的个数:\n\
                                           - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section\n\
                                           {\n\
                                           return self.dataArr.count;\n\
                                           }"] ToStrM:textStrM];
            
            
            [self insertValueAndNewlines:@[@"// 3.返回每一个item（cell）对象;\n\
                                           - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath\n\
                                           {"] ToStrM:textStrM];
            
            
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"])[self insertValueAndNewlines:@[@"id modelObjct=self.dataArr[indexPath.row];"] ToStrM:textStrM];
            
            if([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n//如果这一行的高度发生变化,就会调用ViewController里面的block来更新\n\
                                                if ((NSInteger)self.dataModel.cellContentSizeHeight!=(NSInteger)self.collectionView.contentSize.height) {\n\
                                                self.dataModel.cellContentSizeHeight=self.collectionView.contentSize.height;\n\
                                                [ZHBlockSingleCategroy runBlockThreeCGFloatIdentity:@\"%@CellHeight\" Float1:self.indexPath.row Float2:self.indexPath.section Float3:self.collectionView.contentSize.height];\n\
                                                }",dic[@"ViewController的名字"]]] ToStrM:textStrM];
            }
            
            
            for (NSString *cellCollectionView in arrCollectionViewCells) {
                NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:cellCollectionView];
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cellCollectionView],[NSString stringWithFormat:@"%@CollectionViewCell *%@Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@\"%@CollectionViewCell\" forIndexPath:indexPath];",cellCollectionView,tempCell,cellCollectionView]] ToStrM:textStrM];
                
                if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@CellModel *model=modelObjct;",cellCollectionView],[NSString stringWithFormat:@"[%@Cell refreshUI:model];",tempCell]] ToStrM:textStrM];
                }
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"return %@Cell;\n}\n",tempCell]] ToStrM:textStrM];
                
            }
            [self insertValueAndNewlines:@[@"//随便给一个cell\nUICollectionViewCell *cell=[UICollectionViewCell new];",@"return cell;",@"}"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[@"//4.每一个item的大小:\n\
                                           - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath\n\
                                           {\n\
                                           return CGSizeMake(100, 140);\n\
                                           }"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[@"// 5.选择某一个cell:\n\
                                           - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath\n\
                                           {\n\
                                           [collectionView deselectItemAtIndexPath:indexPath animated:YES];\n\
                                           }",@"\n"] ToStrM:textStrM];
            
        }
        else{
            
            [self insertValueAndNewlines:@[@"#pragma mark - TableViewDelegate实现的方法:",@"- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{",@"return 1;",@"}"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[@"- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{",@"return self.dataArr.count;",@"}",@"- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{"] ToStrM:textStrM];
            
            if([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n//如果这一行的高度发生变化,就会调用ViewController里面的block来更新\n\
                                                if ((NSInteger)self.dataModel.cellContentSizeHeight!=(NSInteger)self.tableView.contentSize.height) {\n\
                                                self.dataModel.cellContentSizeHeight=self.tableView.contentSize.height;\n\
                                                [ZHBlockSingleCategroy runBlockThreeCGFloatIdentity:@\"%@CellHeight\" Float1:self.indexPath.row Float2:self.indexPath.section Float3:self.tableView.contentSize.height];\n\
                                                }",dic[@"ViewController的名字"]]] ToStrM:textStrM];
            }
            
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"])[self insertValueAndNewlines:@[@"id modelObjct=self.dataArr[indexPath.row];"] ToStrM:textStrM];
            
            for (NSString *cell in arrTableViewCells) {
                NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:cell];
                if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cell],[NSString stringWithFormat:@"%@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];",cell,tempCell,cell],[NSString stringWithFormat:@"%@CellModel *model=modelObjct;",cell],[NSString stringWithFormat:@"[%@Cell refreshUI:model];",tempCell],[NSString stringWithFormat:@"return %@Cell;",tempCell],@"}"] ToStrM:textStrM];
                }else{
                    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@TableViewCell *%@Cell=[tableView dequeueReusableCellWithIdentifier:@\"%@TableViewCell\"];",cell,cell,cell]] ToStrM:textStrM];
                }
            }
            
            [self insertValueAndNewlines:@[@"//随便给一个cell\nUITableViewCell *cell=[UITableViewCell new];",@"return cell;",@"}"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[@"- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{",@"return 80.0f;",@"}",@"- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{",@"[tableView deselectRowAtIndexPath:indexPath animated:YES];",@"}",@"\n"] ToStrM:textStrM];
        }
    }
    
    [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
    
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@TableViewCell.m",cell]]];
    
    
    
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        
        //CellModel.h
        [textStrM setString:@""];
        
        [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>\n",[NSString stringWithFormat:@"@interface %@CellModel : NSObject",cell],@"@property (nonatomic,copy)NSString *iconImageName;\n\
                                       @property (nonatomic,assign)BOOL isSelect;\n\
                                       @property (nonatomic,assign)BOOL shouldShowImage;\n\
                                       @property (nonatomic,copy)NSString *title;\n\
                                       \n\
                                       @property (nonatomic,copy)NSString *content;\n\
                                       @property (nonatomic,assign)CGSize size;\n\
                                       @property (nonatomic,assign)CGFloat width;\n\
                                       @property (nonatomic,strong)NSMutableArray *dataArr;"] ToStrM:textStrM];
        
        if([dic[@"是否需要自动计算cell(嵌套控件)的高度 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
            if (hasContain) {
                [self insertValueAndNewlines:@[@"@property (nonatomic,assign)CGFloat cellContentSizeHeight;"] ToStrM:textStrM];
            }
        }
    
        [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
        
        [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"model",[NSString stringWithFormat:@"%@CellModel.h",cell]]];
        
        
        //CellModel.m
        [textStrM setString:@""];
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell],[NSString stringWithFormat:@"\n@implementation %@CellModel",cell],@"- (NSMutableArray *)dataArr{\n\
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

- (void)createCollectionViewCell:(NSString *)cell withStrM:(NSMutableString *)textStrM withInfoDic:(NSDictionary *)dic withContainArrM:(NSArray *)ContainArrM withhasContain:(BOOL)hasContain{
    
    [textStrM setString:@""];
    [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>"] ToStrM:textStrM];
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell]] ToStrM:textStrM];
    }
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@CollectionViewCell : UICollectionViewCell",cell]] ToStrM:textStrM];
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel;",cell]] ToStrM:textStrM];
    }
    [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@CollectionViewCell.h",cell]]];
    
    [textStrM setString:@""];
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CollectionViewCell.h\"\n",cell]] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@CollectionViewCell ()",cell],@"@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;",@"@property (weak, nonatomic) IBOutlet UILabel *nameLabel;",@"@end\n"] ToStrM:textStrM];
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@implementation %@CollectionViewCell",cell]] ToStrM:textStrM];
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel{",cell],@"self.nameLabel.text=dataModel.title;\n\
                                       self.iconImageView.image=[UIImage imageNamed:dataModel.iconImageName];",@"}\n\n"] ToStrM:textStrM];
    }
    [self insertValueAndNewlines:@[@"- (void)awakeFromNib {",@"[super awakeFromNib];",@"}\n",@"- (void)setSelected:(BOOL)selected{\n\
                                   [super setSelected:selected];\n\
                                   }\n\
                                   - (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView{\n\
                                   [super setSelectedBackgroundView:selectedBackgroundView];\n\
                                   }",@"@end\n"] ToStrM:textStrM];
    
    [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@CollectionViewCell.m",cell]]];
    
    if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
        [textStrM setString:@""];
        [self insertValueAndNewlines:@[@"#import <UIKit/UIKit.h>\n",[NSString stringWithFormat:@"@interface %@CellModel : NSObject",cell],@"@property (nonatomic,copy)NSString *iconImageName;\n\
                                       @property (nonatomic,assign)BOOL isSelect;\n\
                                       @property (nonatomic,assign)BOOL shouldShowImage;\n\
                                       @property (nonatomic,copy)NSString *title;\n\
                                       \n\
                                       @property (nonatomic,copy)NSString *content;\n\
                                       @property (nonatomic,assign)CGSize size;\n\
                                       @property (nonatomic,assign)CGFloat width;\n\
                                       @property (nonatomic,strong)NSMutableArray *dataArr;",@"@end"] ToStrM:textStrM];
        
        [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"model",[NSString stringWithFormat:@"%@CellModel.h",cell]]];
        
        [textStrM setString:@""];
        [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell],[NSString stringWithFormat:@"\n@implementation %@CellModel",cell],@"- (NSMutableArray *)dataArr{\n\
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

- (NSString *)getZHBlockSingleCategroy_H{
    return [[ZHWordWrap new] wordWrapText:@"#import <UIKit/UIKit.h>\n\
            \n\
            //空(NULL)\n\
            typedef void (^MyblockWithNULL)(void);\n\
            \n\
            //字符串(NSString)\n\
            typedef void (^MyblockWithNSString)(NSString *str1);\n\
            typedef void (^MyblockWithTwoNSString)(NSString *str1,NSString *str2);\n\
            typedef void (^MyblockWithThreeNSString)(NSString *str1,NSString *str2,NSString *str3);\n\
            \n\
            //NSInteger\n\
            typedef void (^MyblockWithNSInteger)(NSInteger Integer);\n\
            typedef void (^MyblockWithTwoNSInteger)(NSInteger Integer1,NSInteger Integer2);\n\
            typedef void (^MyblockWithThreeNSInteger)(NSInteger Integer1,NSInteger Integer2,NSInteger Integer3);\n\
            \n\
            //CGFloat\n\
            typedef void (^MyblockWithCGFloat)(CGFloat Float);\n\
            typedef void (^MyblockWithTwoCGFloat)(CGFloat Float1,CGFloat Float2);\n\
            typedef void (^MyblockWithThreeCGFloat)(CGFloat Float1,CGFloat Float2,CGFloat Float3);\n\
            \n\
            //NSArray\n\
            typedef void (^MyblockWithNSArray)(NSArray *Array);\n\
            typedef void (^MyblockWithTwoNSArray)(NSArray *Array1,NSArray *Array2);\n\
            typedef void (^MyblockWithThreeNSArray)(NSArray *Array1,NSArray *Array2,NSArray *Array3);\n\
            \n\
            //NSDictionary\n\
            typedef void (^MyblockWithNSDictionary)(NSDictionary *Dictionary);\n\
            typedef void (^MyblockWithTwoNSDictionary)(NSDictionary *Dictionary1,NSDictionary *Dictionary2);\n\
            typedef void (^MyblockWithThreeNSDictionary)(NSDictionary *Dictionary1,NSDictionary *Dictionary2,NSDictionary *Dictionary3);\n\
            \n\
            @interface ZHBlockSingleCategroy : NSObject\n\
            \n\
            + (NSMutableDictionary *)defaultMyblock;\n\
            \n\
            /**判断是否存在某个Block*/\n\
            + (BOOL)exsitBlockWithIdentity:(NSString *)Identity;\n\
            \n\
            //空(NULL)\n\
            + (void)addBlockWithNULL:(MyblockWithNULL)block WithIdentity:(NSString *)Identity;\n\
            \n\
            //字符串(NSString)\n\
            + (void)addBlockWithNSString:(MyblockWithNSString)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithTwoNSString:(MyblockWithTwoNSString)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithThreeNSString:(MyblockWithThreeNSString)block WithIdentity:(NSString *)Identity;\n\
            \n\
            //NSInteger\n\
            + (void)addBlockWithNSInteger:(MyblockWithNSInteger)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithTwoNSInteger:(MyblockWithTwoNSInteger)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithThreeNSInteger:(MyblockWithThreeNSInteger)block WithIdentity:(NSString *)Identity;\n\
            \n\
            //CGFloat\n\
            + (void)addBlockWithCGFloat:(MyblockWithCGFloat)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithTwoCGFloat:(MyblockWithTwoCGFloat)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithThreeCGFloat:(MyblockWithThreeCGFloat)block WithIdentity:(NSString *)Identity;\n\
            \n\
            //NSArray\n\
            + (void)addBlockWithNSArray:(MyblockWithNSArray)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithTwoNSArray:(MyblockWithTwoNSArray)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithThreeNSArray:(MyblockWithThreeNSArray)block WithIdentity:(NSString *)Identity;\n\
            \n\
            //NSDictionary\n\
            + (void)addBlockWithNSDictionary:(MyblockWithNSDictionary)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithTwoNSDictionary:(MyblockWithTwoNSDictionary)block WithIdentity:(NSString *)Identity;\n\
            + (void)addBlockWithThreeNSDictionary:(MyblockWithThreeNSDictionary)block WithIdentity:(NSString *)Identity;\n\
            \n\
            //执行block 空(NULL)\n\
            + (void)runBlockNULLIdentity:(NSString *)Identity;\n\
            \n\
            //执行block 字符串(NSString)\n\
            + (void)runBlockNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1;\n\
            + (void)runBlockTwoNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2;\n\
            + (void)runBlockThreeNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2 Str3:(NSString *)str3;\n\
            \n\
            //执行block NSInteger\n\
            + (void)runBlockNSIntegerIdentity:(NSString *)Identity Intege1:(NSInteger)Intege1;\n\
            + (void)runBlockTwoNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2;\n\
            + (void)runBlockThreeNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2  Intege3:(NSInteger)Intege3;\n\
            \n\
            //执行block CGFloat\n\
            + (void)runBlockCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1;\n\
            + (void)runBlockTwoCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2;\n\
            + (void)runBlockThreeCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2  Float3:(CGFloat)Float3;\n\
            \n\
            //执行block NSArray\n\
            + (void)runBlockNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1;\n\
            + (void)runBlockTwoNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1 Array2:(NSArray *)Array2;\n\
            + (void)runBlockThreeNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1  Array2:(NSArray *)Array2 Array3:(NSArray *)Array3;\n\
            \n\
            //NSDictionary\n\
            + (void)runBlockNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1;\n\
            + (void)runBlockTwoNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2;\n\
            + (void)runBlockThreeNSDictionaryIdentity:(NSString *)Identity  Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2 Dictionary3:(NSDictionary *)Dictionary3;\n\
            \n\
            \n\
            + (void)removeBlockWithIdentity:(NSString *)Identity;\n\
            \n\
            @end\n\
            "];
}
- (NSString *)getZHBlockSingleCategroy_M{
    return [[ZHWordWrap new] wordWrapText:@"#import \"ZHBlockSingleCategroy.h\"\n\
            \n\
            static NSMutableDictionary *ZHBlocks;\n\
            \n\
            @implementation ZHBlockSingleCategroy\n\
            + (NSMutableDictionary *)defaultMyblock{\n\
            //添加线程锁\n\
            static dispatch_once_t onceToken;\n\
            dispatch_once(&onceToken, ^{\n\
            if(ZHBlocks==nil){\n\
            ZHBlocks=[NSMutableDictionary dictionary];\n\
            }\n\
            });\n\
            return ZHBlocks;\n\
            }\n\
            \n\
            + (BOOL)exsitBlockWithIdentity:(NSString *)Identity{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]==nil)\n\
            return NO;\n\
            else\n\
            return YES;\n\
            }\n\
            \n\
            + (void)addBlock:(id)block withIdentity:(NSString *)identity{\n\
            [self removeBlockWithIdentity:identity];\n\
            [[ZHBlockSingleCategroy defaultMyblock] setValue:block forKey:identity];\n\
            }\n\
            \n\
            //空(NULL)\n\
            + (void)addBlockWithNULL:(MyblockWithNULL)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            \n\
            //添加block 字符串(NSString)\n\
            + (void)addBlockWithNSString:(MyblockWithNSString)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithTwoNSString:(MyblockWithTwoNSString)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithThreeNSString:(MyblockWithThreeNSString)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            \n\
            //添加block NSInteger\n\
            + (void)addBlockWithNSInteger:(MyblockWithNSInteger)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithTwoNSInteger:(MyblockWithTwoNSInteger)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithThreeNSInteger:(MyblockWithThreeNSInteger)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            \n\
            //添加block CGFloat\n\
            + (void)addBlockWithCGFloat:(MyblockWithCGFloat)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithTwoCGFloat:(MyblockWithTwoCGFloat)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            +(void)addBlockWithThreeCGFloat:(MyblockWithThreeCGFloat)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            \n\
            //添加block NSArray\n\
            + (void)addBlockWithNSArray:(MyblockWithNSArray)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithTwoNSArray:(MyblockWithTwoNSArray)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithThreeNSArray:(MyblockWithThreeNSArray)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            \n\
            //添加block NSDictionary\n\
            + (void)addBlockWithNSDictionary:(MyblockWithNSDictionary)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            + (void)addBlockWithTwoNSDictionary:(MyblockWithTwoNSDictionary)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            +(void)addBlockWithThreeNSDictionary:(MyblockWithThreeNSDictionary)block WithIdentity:(NSString *)Identity{\n\
            [self addBlock:block withIdentity:Identity];\n\
            }\n\
            \n\
            //执行block 空(NULL)\n\
            + (void)runBlockNULLIdentity:(NSString *)Identity{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithNULL block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block();\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            \n\
            //执行block 字符串(NSString)\n\
            + (void)runBlockNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithNSString block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(str1);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockTwoNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithTwoNSString block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(str1,str2);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockThreeNSStringIdentity:(NSString *)Identity Str1:(NSString *)str1 Str2:(NSString *)str2 Str3:(NSString *)str3{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithThreeNSString block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(str1,str2,str3);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            \n\
            //执行block NSInteger\n\
            + (void)runBlockNSIntegerIdentity:(NSString *)Identity Intege1:(NSInteger)Intege1{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithNSInteger block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Intege1);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockTwoNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithTwoNSInteger block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Intege1,Intege2);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockThreeNSIntegerIdentity:(NSString *)Identity  Intege1:(NSInteger)Intege1 Intege2:(NSInteger)Intege2  Intege3:(NSInteger)Intege3{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithThreeNSInteger block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Intege1,Intege2,Intege3);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            \n\
            //执行block CGFloat\n\
            + (void)runBlockCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithCGFloat block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Float1);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockTwoCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithTwoCGFloat block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Float1,Float2);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockThreeCGFloatIdentity:(NSString *)Identity Float1:(CGFloat)Float1 Float2:(CGFloat)Float2  Float3:(CGFloat)Float3{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithThreeCGFloat block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Float1,Float2,Float3);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            \n\
            //执行block NSArray\n\
            + (void)runBlockNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithNSArray block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Array1);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockTwoNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1 Array2:(NSArray *)Array2{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithTwoNSArray block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Array1,Array2);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockThreeNSArrayIdentity:(NSString *)Identity Array1:(NSArray *)Array1  Array2:(NSArray *)Array2 Array3:(NSArray *)Array3{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithThreeNSArray block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Array1,Array2,Array3);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            \n\
            //NSDictionary\n\
            + (void)runBlockNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithNSDictionary block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Dictionary1);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockTwoNSDictionaryIdentity:(NSString *)Identity Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithTwoNSDictionary block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Dictionary1,Dictionary2);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            + (void)runBlockThreeNSDictionaryIdentity:(NSString *)Identity  Dictionary1:(NSDictionary *)Dictionary1 Dictionary2:(NSDictionary *)Dictionary2 Dictionary3:(NSDictionary *)Dictionary3{\n\
            if([ZHBlockSingleCategroy defaultMyblock][Identity]!=nil){\n\
            MyblockWithThreeNSDictionary block=[ZHBlockSingleCategroy defaultMyblock][Identity];\n\
            block(Dictionary1,Dictionary2,Dictionary3);\n\
            }else{\n\
            [self AlertMsg:Identity];\n\
            }\n\
            }\n\
            \n\
            \n\
            + (void)removeBlockWithIdentity:(NSString *)Identity{\n\
            [[ZHBlockSingleCategroy defaultMyblock] removeObjectForKey:Identity];\n\
            }\n\
            + (void)AlertMsg:(NSString *)Identity{\n\
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@\"温馨提示\" message:[Identity stringByAppendingString:@\" 的block已经移除或者还未创建!\"]delegate:self cancelButtonTitle:@\"确定\" otherButtonTitles:nil, nil];\n\
            [alert show];\n\
            }\n\
            \n\
            \n\
            @end\n\
            "];
}

@end
