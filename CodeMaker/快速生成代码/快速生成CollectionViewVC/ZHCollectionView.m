#import "ZHCollectionView.h"

@implementation ZHCollectionView
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
    
    //2.创建ViewController.m
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@ViewController.h\"",dic[@"ViewController的名字"]],@""] ToStrM:textStrM];
    
    NSString *cells=dic[@"自定义Cell,以逗号隔开"];
    NSArray *arrCells=[cells componentsSeparatedByString:@","];
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CollectionViewCell.h\"",cell]] ToStrM:textStrM];
        }
    }
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"\n@interface %@ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>\n",dic[@"ViewController的名字"]],@"@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;\n"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"@property (nonatomic,strong)NSMutableArray *dataArr;",@""] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"@end",[NSString stringWithFormat:@"@implementation %@ViewController",dic[@"ViewController的名字"]]] ToStrM:textStrM];
    
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
    [self insertValueAndNewlines:@[@"- (NSMutableArray *)dataArr{",@"if (!_dataArr) {",@"_dataArr=[NSMutableArray array];",fakeDataStrM,@"}",@"return _dataArr;",@"}"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"\n- (void)viewDidLoad{",@"[super viewDidLoad];",@"[self addFlowLayoutToCollectionView:self.collectionView];",@"//self.edgesForExtendedLayout=UIRectEdgeNone;"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"}\n"] ToStrM:textStrM];
    
    [self insertValueAndNewlines:@[@"/**为collectionView添加布局*/\n\
                                   - (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView{\n\
                                   UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];\n\
                                   \n\
                                   flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平\n\
                                   //    flow.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直\n\
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
    
    if ([self judge:cells]) {
        for (NSString *cell in arrCells) {
            NSString *tempCell=[ZHStoryboardTextManager lowerFirstCharacter:cell];
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"if ([modelObjct isKindOfClass:[%@CellModel class]]){",cell],[NSString stringWithFormat:@"%@CollectionViewCell *%@Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@\"%@CollectionViewCell\" forIndexPath:indexPath];",cell,tempCell,cell]] ToStrM:textStrM];
            
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"%@CellModel *model=modelObjct;",cell],[NSString stringWithFormat:@"[%@Cell refreshUI:model];",tempCell]] ToStrM:textStrM];
            }
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"return %@Cell;\n}\n",tempCell]] ToStrM:textStrM];
        }
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
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@CollectionViewCell : UICollectionViewCell",cell]] ToStrM:textStrM];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel;",cell]] ToStrM:textStrM];
            }
            [self insertValueAndNewlines:@[@"@end"] ToStrM:textStrM];
            [self saveText:textStrM toFileName:@[dic[@"最大文件夹名字"],@"view",[NSString stringWithFormat:@"%@CollectionViewCell.h",cell]]];
            
            [textStrM setString:@""];
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CollectionViewCell.h\"\n",cell]] ToStrM:textStrM];
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@interface %@CollectionViewCell ()",cell],@"@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;",@"@property (weak, nonatomic) IBOutlet UILabel *nameLabel;",@"",[NSString stringWithFormat:@"@property (nonatomic,weak)%@CellModel *dataModel;",cell],@"@end\n"] ToStrM:textStrM];
            
            [self insertValueAndNewlines:@[[NSString stringWithFormat:@"@implementation %@CollectionViewCell",cell],@"\n"] ToStrM:textStrM];
            if([dic[@"是否需要对应的Model 1:0 (不填写么默认为否)"] isEqualToString:@"1"]){
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"- (void)refreshUI:(%@CellModel *)dataModel{",cell],@"_dataModel=dataModel;",@"self.nameLabel.text=dataModel.title;\n\
                                               self.iconImageView.image=[UIImage imageNamed:dataModel.iconImageName];",@"}\n"] ToStrM:textStrM];
            }
            [self insertValueAndNewlines:@[@"- (void)awakeFromNib {",@"[super awakeFromNib];",@"}\n",@"- (void)setSelected:(BOOL)selected{\n\
                                           [super setSelected:selected];\n\
                                           }\n\
                                           - (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView{\n\
                                           [super setSelectedBackgroundView:selectedBackgroundView];\n\
                                           }",@"\n@end\n"] ToStrM:textStrM];
            
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
                [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@CellModel.h\"",cell],[NSString stringWithFormat:@"@implementation %@CellModel",cell],@"\n- (NSMutableArray *)dataArr{\n\
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
        if (![self judge:dic[@"ViewController的名字"]]) {
            [self saveStoryBoardCollectionViewToViewController:@"" collectionviewCells:nil toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
        }else{
            //没有cells
            if (![self judge:dic[@"自定义Cell,以逗号隔开"]]) {
                [self saveStoryBoardCollectionViewToViewController:dic[@"ViewController的名字"] collectionviewCells:nil toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
            }else{//有cells
                NSArray *arr=[dic[@"自定义Cell,以逗号隔开"] componentsSeparatedByString:@","];
                NSMutableArray *arrM=[NSMutableArray array];
                for (NSString *str in arr) {
                    [arrM addObject:[str stringByAppendingString:@"CollectionViewCell"]];
                }
                [self saveStoryBoardCollectionViewToViewController:dic[@"ViewController的名字"] collectionviewCells:arrM toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"MainStroyBoard.storyboard"]]];
            }
        }
    }
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
    
    [MBProgressHUD showHUDAddedToView:view withText:@"生成成功!" withDuration:1 animated:NO];
}
@end
