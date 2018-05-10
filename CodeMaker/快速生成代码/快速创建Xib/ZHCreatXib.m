#import "ZHCreatXib.h"

@implementation ZHCreatXib
- (void)Begin:(NSString *)str toView:(UIView *)view{
    [self backUp:str];
    NSDictionary *dic=[self getDicFromFileName:str];
    
    if(![self judge:dic[@"最大文件夹名字"]]){
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写文件夹名字,创建Xib失败!" withDuration:1 animated:NO];
        return;
    }
    
//    [zhCreatXib creatFatherFile:@"代码助手" andData:@[@"最大文件夹名字",@"xib名字",@"xib类型 1:view-xib 2:tableViewCell-xib 3:collectionViewCell-xib"]];
    
    [self creatFatherFileDirector:dic[@"最大文件夹名字"] toFatherDirector:nil];
    
    if (![self judge:dic[@"xib名字"]]) {
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写 xib名字!" withDuration:1 animated:NO];
        return;
    }
    
    NSString *type=dic[@"xib类型 1:view-xib 2:tableViewCell-xib 3:collectionViewCell-xib"];
    if (![self judge:type]) {
        [MBProgressHUD showHUDAddedToView:view withText:@"没有填写 xib类型!" withDuration:1 animated:NO];
        return;
    }
    
    if ([type isEqualToString:@"1"]) {
        [self createXib_View:dic];
        [self createXib_View_XibFile:dic];
    }else if ([type isEqualToString:@"2"]) {
        [self createXib_TableViewCell:dic];
        [self createXib_TableViewCell_XibFile:dic];
    }else if ([type isEqualToString:@"3"]) {
        [self createXib_CollectionViewCell:dic];
        [self createXib_CollectionViewCell_XibFile:dic];
    }else{
        [MBProgressHUD showHUDAddedToView:view withText:@"填写的 xib类型 不对!" withDuration:1 animated:NO];
        return;
    }
    [MBProgressHUD showHUDAddedToView:view withText:@"生成成功!" withDuration:1 animated:NO];
}

- (NSString *)createXibCode_View_h:(NSString *)xibName{
    
    //1.创建.h
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import <UIKit/UIKit.h>\n\
                                    \n\
                                    @interface %@ : UIView\n\
                                    \n\
                                    + (instancetype)loadXibWithFrame:(CGRect)frame;\n\
                                    + (instancetype)loadXibWithFrame:(CGRect)frame index:(NSInteger)index;\n\
                                    \n\
                                    @end\n\
                                    ",xibName]] ToStrM:textStrM];
    
    return textStrM;
}
- (NSString *)createXibCode_View_m:(NSString *)xibName{
    
    //2.创建.m
    NSMutableString *textStrM=[NSMutableString string];
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@.h\"\n\
                                    \n\
                                    @interface %@ ()\n\
                                    \n\
                                    @end\n\
                                    \n\
                                    @implementation %@\n\
                                    \n\
                                    + (instancetype)loadXibWithFrame:(CGRect)frame{\n\
                                    %@ *xibView=[[[NSBundle mainBundle]loadNibNamed:@\"%@\" owner:nil options:nil] firstObject];\n\
                                    xibView.frame=frame;\n\
                                    return xibView;\n\
                                    }\n\n\
                                    + (instancetype)loadXibWithFrame:(CGRect)frame index:(NSInteger)index{\n\
                                    NSArray *views = [[NSBundle mainBundle]loadNibNamed:@\"%@\" owner:nil options:nil];\n\
                                    if (views.count>index) {\n\
                                    %@ *xibView=views[index];\n\
                                    xibView.frame=frame;\n\
                                    return xibView;\n\
                                    }\n\
                                    return nil;\n\
                                    }\
                                    \n\
                                    @end\n\
                                    ",xibName,xibName,xibName,xibName,xibName,xibName,xibName]] ToStrM:textStrM];
    
    
    return textStrM;
}
- (NSString *)createXibCode_TableViewCell_h:(NSString *)xibName{
    
    //1.创建.h
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import <UIKit/UIKit.h>\n\
                                    \n\
                                    @interface %@ : UITableViewCell\n\
                                    + (%@ *)loadReusableCellWithIdentifier:(NSString *)identifier tableView:(UITableView *)tableView;\n\
                                    \n\
                                    @end\n\
                                    ",xibName,xibName]] ToStrM:textStrM];
    
    return textStrM;
}
- (NSString *)createXibCode_TableViewCell_m:(NSString *)xibName{
    
    //2.创建.m
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@.h\"\n\
                                    \n\
                                    @interface %@ ()\n\
                                    \n\
                                    @end\n\
                                    \n\
                                    @implementation %@\n\
                                    \n\
                                    + (%@ *)loadReusableCellWithIdentifier:(NSString *)identifier tableView:(UITableView *)tableView{\n\
                                    %@ *xibTableViewCell=[tableView dequeueReusableCellWithIdentifier:identifier];\n\
                                    if (!xibTableViewCell) {\n\
                                    xibTableViewCell=[[[NSBundle mainBundle]loadNibNamed:@\"%@\" owner:self options:nil] firstObject];\n\
                                    }\n\
                                    return xibTableViewCell;\n\
                                    }\n\
                                    \n\
                                    - (void)awakeFromNib {\n\
                                    [super awakeFromNib];\n\
                                    }\n\
                                    \n\
                                    - (void)setSelected:(BOOL)selected animated:(BOOL)animated {\n\
                                    [super setSelected:selected animated:animated];\n\
                                    }\n\
                                    \n\
                                    @end",xibName,xibName,xibName,xibName,xibName,xibName]] ToStrM:textStrM];
    
    return textStrM;
}
- (NSString *)createXibCode_CollectionViewCell_h:(NSString *)xibName{
    
    //1.创建.h
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import <UIKit/UIKit.h>\n\
                                    \n\
                                    @interface %@ : UICollectionViewCell\n\
                                    \n\
                                    + (%@ *)loadReusableCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;\n\
                                    + (void)registerXibFor:(UICollectionView *)collectionView;\n\
                                    /**为collectionView添加布局*/\n\
                                    + (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView;\n\
                                    @end\n\
                                    ",xibName,xibName]] ToStrM:textStrM];
    
    return textStrM;
}
- (NSString *)createXibCode_CollectionViewCell_m:(NSString *)xibName{
    
    
    //2.创建.m
    NSMutableString *textStrM=[NSMutableString string];
    
    [self insertValueAndNewlines:@[[NSString stringWithFormat:@"#import \"%@.h\"\n\
                                    \n\
                                    @interface %@ ()\n\
                                    \n\
                                    @end\n\
                                    \n\
                                    @implementation %@\n\
                                    \n\
                                    + (%@ *)loadReusableCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath{\n\
                                    %@ *xibCollectionViewCell=[collectionView dequeueReusableCellWithReuseIdentifier:@\"%@\" forIndexPath:indexPath];\n\
                                    if (!xibCollectionViewCell) {\n\
                                    xibCollectionViewCell=[[[NSBundle mainBundle]loadNibNamed:@\"%@\" owner:self options:nil] firstObject];\n\
                                    }\n\
                                    return xibCollectionViewCell;\n\
                                    }\n\
                                    \n\
                                    + (void)registerXibFor:(UICollectionView *)collectionView{\n\
                                    [collectionView registerNib:[UINib nibWithNibName:@\"%@\" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@\"%@\"];\n\
                                    }\n\
                                    \n\
                                    /**为collectionView添加布局*/\n\
                                    + (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView{\n\
                                    UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];\n\
                                    flow.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直\n\
                                    flow.minimumInteritemSpacing = 10;\n\
                                    flow.minimumLineSpacing = 10;\n\
                                    collectionView.collectionViewLayout=flow;\n\
                                    collectionView.backgroundColor=[UIColor whiteColor];//背景颜色\n\
                                    collectionView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);//内嵌值\n\
                                    \n\
                                    [self registerXibFor:collectionView];\n\
                                    }\n\
                                    \n\
                                    - (void)awakeFromNib {\n\
                                    [super awakeFromNib];\n\
                                    }\n\
                                    \n\
                                    @end\n\
                                    ",xibName,xibName,xibName,xibName,xibName,xibName,xibName,xibName,xibName]] ToStrM:textStrM];
    
    return textStrM;
}

- (void)createXib_View:(NSDictionary *)dic{
    
    NSString *xibName=dic[@"xib名字"];
    
    //1.创建.h
    NSString *textStr=[self createXibCode_View_h:xibName];
    [self saveText:textStr toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.h",xibName]]];
    
    //2.创建.m
    textStr=[self createXibCode_View_m:xibName];
    [self saveText:textStr toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.m",xibName]]];
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
}
- (void)createXib_TableViewCell:(NSDictionary *)dic{
    NSString *xibName=dic[@"xib名字"];
    
    //1.创建.h
    NSString *textStr=[self createXibCode_TableViewCell_h:xibName];
    [self saveText:textStr toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.h",xibName]]];
    
    
    //2.创建.m
    textStr=[self createXibCode_TableViewCell_m:xibName];
    [self saveText:textStr toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.m",xibName]]];
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
}
- (void)createXib_CollectionViewCell:(NSDictionary *)dic{
    NSString *xibName=dic[@"xib名字"];
    
    //1.创建.h
    NSString *textStr=[self createXibCode_CollectionViewCell_h:xibName];
    [self saveText:textStr toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.h",xibName]]];
    
    
    //2.创建.m
    textStr=[self createXibCode_CollectionViewCell_m:xibName];
    [self saveText:textStr toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.m",xibName]]];
    
    [[ZHWordWrap new]wordWrap:[self getDirectoryPath:dic[@"最大文件夹名字"]]];
}

- (void)createXib_View_XibFile:(NSDictionary *)dic{
    NSString *xibName=dic[@"xib名字"];
    
    NSString *xibXml=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
                      <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.XIB\" version=\"3.0\" toolsVersion=\"11762\" systemVersion=\"15G1217\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\" colorMatched=\"YES\">\n\
                      <device id=\"retina4_7\" orientation=\"portrait\">\n\
                      <adaptation id=\"fullscreen\"/>\n\
                      </device>\n\
                      <dependencies>\n\
                      <deployment identifier=\"iOS\"/>\n\
                      <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"11757\"/>\n\
                      <capability name=\"documents saved in the Xcode 8 format\" minToolsVersion=\"8.0\"/>\n\
                      </dependencies>\n\
                      <objects>\n\
                      <placeholder placeholderIdentifier=\"IBFilesOwner\" id=\"-1\" userLabel=\"File's Owner\"/>\n\
                      <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"-2\" customClass=\"UIResponder\"/>\n\
                      <view contentMode=\"scaleToFill\" id=\"iN0-l3-epB\" customClass=\"%@\">\n\
                      <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"246\" height=\"282\"/>\n\
                      <autoresizingMask key=\"autoresizingMask\" widthSizable=\"YES\" heightSizable=\"YES\"/>\n\
                      <color key=\"backgroundColor\" red=\"1\" green=\"1\" blue=\"1\" alpha=\"1\" colorSpace=\"custom\" customColorSpace=\"sRGB\"/>\n\
                      <freeformSimulatedSizeMetrics key=\"simulatedDestinationMetrics\"/>\n\
                      <point key=\"canvasLocation\" x=\"-39\" y=\"-141\"/>\n\
                      </view>\n\
                      </objects>\n\
                      </document>\n\
                      ",xibName];
    [self saveText:xibXml toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.xib",xibName]]];
}
- (void)createXib_TableViewCell_XibFile:(NSDictionary *)dic{
    NSString *xibName=dic[@"xib名字"];
    
    NSString *xibXml=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
                      <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.XIB\" version=\"3.0\" toolsVersion=\"11762\" systemVersion=\"15G1217\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\" colorMatched=\"YES\">\n\
                      <device id=\"retina4_7\" orientation=\"portrait\">\n\
                      <adaptation id=\"fullscreen\"/>\n\
                      </device>\n\
                      <dependencies>\n\
                      <deployment identifier=\"iOS\"/>\n\
                      <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"11757\"/>\n\
                      <capability name=\"documents saved in the Xcode 8 format\" minToolsVersion=\"8.0\"/>\n\
                      </dependencies>\n\
                      <objects>\n\
                      <placeholder placeholderIdentifier=\"IBFilesOwner\" id=\"-1\" userLabel=\"File's Owner\"/>\n\
                      <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"-2\" customClass=\"UIResponder\"/>\n\
                      <tableViewCell clipsSubviews=\"YES\" contentMode=\"scaleToFill\" selectionStyle=\"default\" indentationWidth=\"10\" reuseIdentifier=\"%@\" rowHeight=\"96\" id=\"FW9-wh-XM7\" customClass=\"%@\">\n\
                      <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"375\" height=\"96\"/>\n\
                      <autoresizingMask key=\"autoresizingMask\"/>\n\
                      <tableViewCellContentView key=\"contentView\" opaque=\"NO\" clipsSubviews=\"YES\" multipleTouchEnabled=\"YES\" contentMode=\"center\" tableViewCell=\"FW9-wh-XM7\" id=\"0Ua-yd-ngn\">\n\
                      <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"375\" height=\"95\"/>\n\
                      <autoresizingMask key=\"autoresizingMask\"/>\n\
                      </tableViewCellContentView>\n\
                      <point key=\"canvasLocation\" x=\"34.5\" y=\"-10\"/>\n\
                      </tableViewCell>\n\
                      </objects>\n\
                      </document>\n\
                      ",xibName,xibName];
    [self saveText:xibXml toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.xib",xibName]]];
}
- (void)createXib_CollectionViewCell_XibFile:(NSDictionary *)dic{
    NSString *xibName=dic[@"xib名字"];
    
    NSString *xibXml=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
                      <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.XIB\" version=\"3.0\" toolsVersion=\"11762\" systemVersion=\"15G1217\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\" colorMatched=\"YES\">\n\
                      <device id=\"retina4_7\" orientation=\"portrait\">\n\
                      <adaptation id=\"fullscreen\"/>\n\
                      </device>\n\
                      <dependencies>\n\
                      <deployment identifier=\"iOS\"/>\n\
                      <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"11757\"/>\n\
                      <capability name=\"documents saved in the Xcode 8 format\" minToolsVersion=\"8.0\"/>\n\
                      </dependencies>\n\
                      <objects>\n\
                      <placeholder placeholderIdentifier=\"IBFilesOwner\" id=\"-1\" userLabel=\"File's Owner\"/>\n\
                      <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"-2\" customClass=\"UIResponder\"/>\n\
                      <collectionViewCell opaque=\"NO\" clipsSubviews=\"YES\" multipleTouchEnabled=\"YES\" contentMode=\"center\" reuseIdentifier=\"%@\" id=\"gTV-IL-0wX\" customClass=\"%@\">\n\
                      <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"126\" height=\"126\"/>\n\
                      <autoresizingMask key=\"autoresizingMask\"/>\n\
                      <view key=\"contentView\" opaque=\"NO\" clipsSubviews=\"YES\" multipleTouchEnabled=\"YES\" contentMode=\"center\">\n\
                      <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"126\" height=\"126\"/>\n\
                      <autoresizingMask key=\"autoresizingMask\" flexibleMaxX=\"YES\" flexibleMaxY=\"YES\"/>\n\
                      </view>\n\
                      <size key=\"customSize\" width=\"126\" height=\"126\"/>\n\
                      <point key=\"canvasLocation\" x=\"63\" y=\"90\"/>\n\
                      </collectionViewCell>\n\
                      </objects>\n\
                      </document>\n\
                      ",xibName,xibName];
    [self saveText:xibXml toFileName:@[dic[@"最大文件夹名字"],[NSString stringWithFormat:@"%@.xib",xibName]]];
}

@end
