#import "ZHCreatXibHelp.h"

@implementation ZHCreatXibHelp

+ (NSString *)creatXibForTableViewCellInsertXmlCode:(NSString *)xmlCode{
    NSString *xmlBegin=@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
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
    <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"-2\" customClass=\"UIResponder\"/>\n";
    NSString *xmlEnd=@"\n    </objects>\n\
    </document>";
    return [NSString stringWithFormat:@"%@%@%@",xmlBegin,xmlCode,xmlEnd];
}

+ (NSString *)creatXibForCollectionViewCellInsertXmlCode:(NSString *)xmlCode{
    NSString *xmlBegin=@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
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
    <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"-2\" customClass=\"UIResponder\"/>\n";
    NSString *xmlEnd=@"\n    </objects>\n\
    </document>";
    return [NSString stringWithFormat:@"%@%@%@",xmlBegin,xmlCode,xmlEnd];
}

+ (void)saveXibForTableViewCellInsertXmlCode:(NSString *)xmlCode withXibName:(NSString *)xibName filePath:(NSString *)filePath{
    NSString *xibXml=[self creatXibForTableViewCellInsertXmlCode:xmlCode];
    filePath=[filePath stringByAppendingPathComponent:[xibName stringByAppendingString:@".xib"]];
    [xibXml writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)saveXibForCollectionViewCellInsertXmlCode:(NSString *)xmlCode withXibName:(NSString *)xibName filePath:(NSString *)filePath{
    NSString *xibXml=[self creatXibForCollectionViewCellInsertXmlCode:xmlCode];
    filePath=[filePath stringByAppendingPathComponent:[xibName stringByAppendingString:@".xib"]];
    [xibXml writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)saveXibCodeFileForTableViewCellSavePath:(NSString *)savePath withXibName:(NSString *)xibName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    //保存cell的代码
    NSArray *arr=[NSArray arrayWithJsonString:fileAddress];
    for (NSString *filePath in arr) {
        NSMutableString *text=[NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSString * savePathNew = [savePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]];
        if([filePath hasSuffix:@".h"]){
            [self insertXibCode_TableViewCell_h_ToText:text withXibName:xibName];
        }else if([filePath hasSuffix:@".m"]){
            [self insertXibCode_TableViewCell_m_ToText:text withXibName:xibName];
        }
        [text writeToFile:savePathNew atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    //保存model的代码
    arr=[NSArray arrayWithJsonString:modelAddress];
    for (NSString *filePath in arr) {
        NSString * savePathNew = [savePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]];
        [ZHFileManager copyItemAtPath:filePath toPath:savePathNew];
    }
    
}

+ (void)saveXibCodeFileForCollectionViewCellSavePath:(NSString *)savePath withXibName:(NSString *)xibName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    //保存cell的代码
    NSArray *arr=[NSArray arrayWithJsonString:fileAddress];
    for (NSString *filePath in arr) {
        NSMutableString *text=[NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSString * savePathNew = [savePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]];
        if([filePath hasSuffix:@".h"]){
            [self insertXibCode_CollectionViewCell_h_ToText:text withXibName:xibName];
        }else if([filePath hasSuffix:@".m"]){
            [self insertXibCode_CollectionViewCell_m_ToText:text withXibName:xibName];
        }
        [text writeToFile:savePathNew atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    //保存model的代码
    arr=[NSArray arrayWithJsonString:modelAddress];
    for (NSString *filePath in arr) {
        NSString * savePathNew = [savePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]];
        [ZHFileManager copyItemAtPath:filePath toPath:savePathNew];
    }
}

+ (void)saveTableViewCellXmlCodePath:(NSString *)xmlCodePath withXibName:(NSString *)xibName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filePath=[ZHHelp creatCurDataDirectorToMacDestop];
    
    NSString *xmlCode=[NSString stringWithContentsOfFile:xmlCodePath encoding:NSUTF8StringEncoding error:nil];
    [self saveXibForTableViewCellInsertXmlCode:xmlCode withXibName:xibName filePath:filePath];
    [self saveXibCodeFileForTableViewCellSavePath:filePath withXibName:xibName fileAddress:fileAddress modelAddress:modelAddress];
    
    [[ZHWordWrap new]wordWrap:filePath];
}

+ (void)saveCollectionViewCellXmlCodePath:(NSString *)xmlCodePath withXibName:(NSString *)xibName fileAddress:(NSString *)fileAddress modelAddress:(NSString *)modelAddress{
    
    NSString *filePath=[ZHHelp creatCurDataDirectorToMacDestop];
    
    NSString *xmlCode=[NSString stringWithContentsOfFile:xmlCodePath encoding:NSUTF8StringEncoding error:nil];
    [self saveXibForCollectionViewCellInsertXmlCode:xmlCode withXibName:xibName filePath:filePath];
    [self saveXibCodeFileForCollectionViewCellSavePath:filePath withXibName:xibName fileAddress:fileAddress modelAddress:modelAddress];
    
    [[ZHWordWrap new]wordWrap:filePath];
}

+ (void)insertXibCode_TableViewCell_h_ToText:(NSMutableString *)text withXibName:(NSString *)xibName{
    
    NSString *insertCode=[NSString stringWithFormat:@"+ (%@ *)loadReusableCellWithIdentifier:(NSString *)identifier tableView:(UITableView *)tableView;",xibName];
    [ZHStoryboardTextManager addCodeText:insertCode andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
}
+ (void)insertXibCode_TableViewCell_m_ToText:(NSMutableString *)text withXibName:(NSString *)xibName{
    
    NSString *insertCode=[NSString stringWithFormat:@"+ (%@ *)loadReusableCellWithIdentifier:(NSString *)identifier tableView:(UITableView *)tableView{\n\
        %@ *xibTableViewCell=[tableView dequeueReusableCellWithIdentifier:identifier];\n\
        if (!xibTableViewCell) {\n\
        xibTableViewCell=[[[NSBundle mainBundle]loadNibNamed:@\"%@\" owner:self options:nil] firstObject];\n\
        }\n\
        return xibTableViewCell;\n\
        }",xibName,xibName,xibName];
    
    [ZHStoryboardTextManager addCodeText:insertCode andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
}
+ (void)insertXibCode_CollectionViewCell_h_ToText:(NSMutableString *)text withXibName:(NSString *)xibName{
    
    NSString *insertCode=[NSString stringWithFormat:@"+ (%@ *)loadReusableCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;\n\
        + (void)registerXibFor:(UICollectionView *)collectionView;\n\
        /**为collectionView添加布局*/\n\
        + (void)addFlowLayoutToCollectionView:(UICollectionView *)collectionView;",xibName];
    
    [ZHStoryboardTextManager addCodeText:insertCode andInsertType:ZHAddCodeType_Interface toStrM:text insertFunction:nil];
}
+ (void)insertXibCode_CollectionViewCell_m_ToText:(NSMutableString *)text withXibName:(NSString *)xibName{
    
    NSString *insertCode=[NSString stringWithFormat:@"+ (%@ *)loadReusableCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath{\n\
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
        }",xibName,xibName,xibName,xibName,xibName,xibName];
    
    [ZHStoryboardTextManager addCodeText:insertCode andInsertType:ZHAddCodeType_Implementation toStrM:text insertFunction:nil];
}

@end
