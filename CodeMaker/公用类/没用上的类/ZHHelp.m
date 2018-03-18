#import "ZHHelp.h"

@implementation ZHHelp

+ (NSString *)getHomeDirector{
    if ([NSHomeDirectory() rangeOfString:@"Library/Developer"].location!=NSNotFound) {
        NSString *path=[NSHomeDirectory() substringToIndex:[NSHomeDirectory() rangeOfString:@"Library/Developer"].location];
        return [path substringToIndex:path.length-1];
    }else{
        return @"";
    }
}
+ (UIViewController *)getViewControllerForView:(UIView *)target{
    
    for (UIView *view = target.superview; view; view = view.superview) {
        
        UIResponder *responder = [view nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    
    return nil;
}
+ (void)creatDirectorIfNotExsit:(NSString *)DirectorPath{
    BOOL yes;
    if (![[NSFileManager defaultManager]fileExistsAtPath:DirectorPath isDirectory:&yes]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:DirectorPath withIntermediateDirectories:yes attributes:nil error:nil];
    }
}
+ (BOOL)validateNumber:(NSString*)number{
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
+ (void)saveFileToApp:(NSString *)fileName withRealFilePath:(NSString *)realFilePath{
    [self creatMainPath];
    NSString *filepath=[self FilePath];
    filepath=[filepath stringByAppendingPathComponent:fileName];
    if ([ZHFileManager fileExistsAtPath:filepath]==NO) {
        if ([ZHFileManager fileExistsAtPath:realFilePath]) {
            [ZHFileManager copyItemAtPath:realFilePath toPath:filepath];
        }
    }
}
+ (void)deleteFileFromApp:(NSString *)fileName{
    if ([self getFilePathFromApp:fileName].length>0) {
        [ZHFileManager removeItemAtPath:fileName];
    }
}
+ (NSString *)getFilePathFromApp:(NSString *)fileName{
    if (fileName.length>0) {
        [self creatMainPath];
        NSString *filePath=[self FilePath];
        filePath=[filePath stringByAppendingPathComponent:fileName];
        if ([ZHFileManager fileExistsAtPath:filePath]) {
            return filePath;
        }
    }
    return @"";
}
+ (NSString *)getCurFilePathFromApp:(NSString *)filePath{
    [self creatMainPath];
    NSString *filePathTemp=[self FilePath];
    filePathTemp=[filePathTemp stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]];
    return filePathTemp;
}
/**获取一个独一无二的文件名*/
+ (NSString *)getOlnyOneFilePathToAppWithPathExtension:(NSString *)pathExtension{
    NSString *fileName=[self getStringWithCount:20];
    fileName=[fileName stringByAppendingString:[NSString stringWithFormat:@".%@",pathExtension]];
    while ([self getFilePathFromApp:fileName].length>0) {
        fileName=[self getStringWithCount:20];
        fileName=[fileName stringByAppendingString:[NSString stringWithFormat:@".%@",pathExtension]];
    }
    [self creatMainPath];
    NSString *filePath=[self FilePath];
    return [filePath stringByAppendingPathComponent:fileName];
}
+ (NSString *)getStringWithCount:(NSInteger)count{
    NSMutableString *strM=[NSMutableString string];
    while (count>0) {
        unichar ch;
        NSInteger sj=arc4random()%3;
        if (sj==0) {
            ch=arc4random()%10+'0';
        }else if (sj==1){
            ch=arc4random()%26+'A';
        }else if (sj==2){
            ch=arc4random()%26+'a';
        }
        [strM appendFormat:@"%C",ch];
        count--;
    }
    return strM;
}
+ (NSString *)FilePath{
    NSString *saveSslectImagePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    saveSslectImagePath=[saveSslectImagePath stringByAppendingPathComponent:@"file"];
    return saveSslectImagePath;
}
//如果主目录不存在,就创建主目录
+ (void)creatMainPath{
    BOOL temp;
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self FilePath] isDirectory:&temp])
        [[NSFileManager defaultManager] createDirectoryAtPath:[self FilePath]withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString *)getTableView{
    return @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
    <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB\" version=\"3.0\" toolsVersion=\"10117\" systemVersion=\"15F34\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\">\n\
    <dependencies>\n\
    <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"10085\"/>\n\
    </dependencies>\n\
    <scenes>\n\
    <!--View Controller-->\n\
    <scene sceneID=\"ln6-he-TvZ\">\n\
    <objects>\n\
    <viewController storyboardIdentifier=\"LLLViewController\" useStoryboardIdentifierAsRestorationIdentifier=\"YES\" id=\"VQU-UQ-5rH\" customClass=\"LLLViewController\" sceneMemberID=\"viewController\">\n\
    <layoutGuides>\n\
    <viewControllerLayoutGuide type=\"top\" id=\"Fs0-p9-OwV\"/>\n\
    <viewControllerLayoutGuide type=\"bottom\" id=\"JON-mD-ZcH\"/>\n\
    </layoutGuides>\n\
    <view key=\"view\" contentMode=\"scaleToFill\" id=\"1m3-F1-jrf\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"600\" height=\"600\"/>\n\
    <autoresizingMask key=\"autoresizingMask\" widthSizable=\"YES\" heightSizable=\"YES\"/>\n\
    <subviews>\n\
    <tableView clipsSubviews=\"YES\" contentMode=\"scaleToFill\" alwaysBounceVertical=\"YES\" dataMode=\"prototypes\" style=\"plain\" separatorStyle=\"default\" rowHeight=\"124\" sectionHeaderHeight=\"28\" sectionFooterHeight=\"28\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"AUd-uD-BAZ\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"20\" width=\"600\" height=\"580\"/>\n\
    <color key=\"backgroundColor\" white=\"1\" alpha=\"1\" colorSpace=\"calibratedWhite\"/>\n\
    </tableView>\n\
    </subviews>\n\
    <color key=\"backgroundColor\" white=\"1\" alpha=\"1\" colorSpace=\"calibratedWhite\"/>\n\
    <constraints>\n\
    <constraint firstItem=\"AUd-uD-BAZ\" firstAttribute=\"leading\" secondItem=\"1m3-F1-jrf\" secondAttribute=\"leading\" id=\"IFI-ix-5mE\"/>\n\
    <constraint firstItem=\"AUd-uD-BAZ\" firstAttribute=\"top\" secondItem=\"Fs0-p9-OwV\" secondAttribute=\"bottom\" id=\"ZBG-g6-JnN\"/>\n\
    <constraint firstItem=\"JON-mD-ZcH\" firstAttribute=\"top\" secondItem=\"AUd-uD-BAZ\" secondAttribute=\"bottom\" id=\"gtw-gO-Drr\"/>\n\
    <constraint firstAttribute=\"trailing\" secondItem=\"AUd-uD-BAZ\" secondAttribute=\"trailing\" id=\"rHu-tH-pGX\"/>\n\
    </constraints>\n\
    </view>\n\
    <connections>\n\
    <outlet property=\"tableView\" destination=\"AUd-uD-BAZ\" id=\"rF3-tR-YSg\"/>\n\
    </connections>\n\
    </viewController>\n\
    <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"J53-ai-Zgt\" userLabel=\"First Responder\" sceneMemberID=\"firstResponder\"/>\n\
    </objects>\n\
    <point key=\"canvasLocation\" x=\"413\" y=\"554\"/>\n\
    </scene>\n\
    </scenes>\n\
    </document>\n";
}
+ (NSString *)getCollectionView{
    return @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
    <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB\" version=\"3.0\" toolsVersion=\"10117\" systemVersion=\"15F34\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\">\n\
    <dependencies>\n\
    <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"10085\"/>\n\
    </dependencies>\n\
    <scenes>\n\
    <!--View Controller-->\n\
    <scene sceneID=\"tne-QT-ifu\">\n\
    <objects>\n\
    <viewController storyboardIdentifier=\"IIIViewController\" useStoryboardIdentifierAsRestorationIdentifier=\"YES\" id=\"mVP-Cm-krS\" customClass=\"IIIViewController\" sceneMemberID=\"viewController\">\n\
    <layoutGuides>\n\
    <viewControllerLayoutGuide type=\"top\" id=\"7cz-NE-Ze6\"/>\n\
    <viewControllerLayoutGuide type=\"bottom\" id=\"4Vf-XF-v7h\"/>\n\
    </layoutGuides>\n\
    <view key=\"view\" contentMode=\"scaleToFill\" id=\"D83-1j-lmx\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"600\" height=\"600\"/>\n\
    <autoresizingMask key=\"autoresizingMask\" widthSizable=\"YES\" heightSizable=\"YES\"/>\n\
    <subviews>\n\
    <collectionView clipsSubviews=\"YES\" multipleTouchEnabled=\"YES\" contentMode=\"scaleToFill\" dataMode=\"prototypes\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"hB6-Qs-mJM\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"20\" width=\"600\" height=\"580\"/>\n\
    <collectionViewFlowLayout key=\"collectionViewLayout\" minimumLineSpacing=\"10\" minimumInteritemSpacing=\"10\" id=\"I30-Un-Hin\">\n\
    <size key=\"itemSize\" width=\"179\" height=\"225\"/>\n\
    <size key=\"headerReferenceSize\" width=\"0.0\" height=\"0.0\"/>\n\
    <size key=\"footerReferenceSize\" width=\"0.0\" height=\"0.0\"/>\n\
    <inset key=\"sectionInset\" minX=\"0.0\" minY=\"0.0\" maxX=\"0.0\" maxY=\"0.0\"/>\n\
    </collectionViewFlowLayout>\n\
    <cells/>\n\
    </collectionView>\n\
    </subviews>\n\
    <color key=\"backgroundColor\" white=\"1\" alpha=\"1\" colorSpace=\"custom\" customColorSpace=\"calibratedWhite\"/>\n\
    <constraints>\n\
    <constraint firstItem=\"hB6-Qs-mJM\" firstAttribute=\"leading\" secondItem=\"D83-1j-lmx\" secondAttribute=\"leading\" id=\"2yv-3E-Rez\"/>\n\
    <constraint firstAttribute=\"trailing\" secondItem=\"hB6-Qs-mJM\" secondAttribute=\"trailing\" id=\"96b-4d-LF1\"/>\n\
    <constraint firstItem=\"4Vf-XF-v7h\" firstAttribute=\"top\" secondItem=\"hB6-Qs-mJM\" secondAttribute=\"bottom\" id=\"I41-ln-kzl\"/>\n\
    <constraint firstItem=\"hB6-Qs-mJM\" firstAttribute=\"top\" secondItem=\"7cz-NE-Ze6\" secondAttribute=\"bottom\" id=\"wPv-0k-7E7\"/>\n\
    </constraints>\n\
    </view>\n\
    <connections>\n\
    <outlet property=\"collectionView\" destination=\"hB6-Qs-mJM\" id=\"lGb-dL-7ux\"/>\n\
    </connections>\n\
    </viewController>\n\
    <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"dZO-Le-KF4\" sceneMemberID=\"firstResponder\"/>\n\
    </objects>\n\
    <point key=\"canvasLocation\" x=\"416\" y=\"662\"/>\n\
    </scene>\n\
    </scenes>\n\
    </document>\n";
}

+ (NSString *)creatCurDataDirectorToMacDestop{
    NSString *filePath=[ZHFileManager getMacDesktop];
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒代码生成"];
    NSString *dateString=[formatter stringFromDate:[NSDate date]];
    filePath=[filePath stringByAppendingPathComponent:dateString];
    [ZHFileManager creatDirectorIfNotExsit:filePath];
    return filePath;
}

+ (NSString *)creatCurDataDirectorToMacDocuments{
    NSString *filePath=[ZHFileManager getMacDocuments];
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒代码生成"];
    NSString *dateString=[formatter stringFromDate:[NSDate date]];
    filePath=[filePath stringByAppendingPathComponent:dateString];
    [ZHFileManager creatDirectorIfNotExsit:filePath];
    return filePath;
}

+ (NSString *)getTableCellsInsertCells:(NSArray *)textCell{
    NSString *start=@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
    <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB\" version=\"3.0\" toolsVersion=\"11762\" systemVersion=\"15G1217\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\" colorMatched=\"YES\" initialViewController=\"BYZ-38-t0r\">\n\
    <device id=\"retina4_7\" orientation=\"portrait\">\n\
    <adaptation id=\"fullscreen\"/>\n\
    </device>\n\
    <dependencies>\n\
    <deployment identifier=\"iOS\"/>\n\
    <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"11757\"/>\n\
    <capability name=\"documents saved in the Xcode 8 format\" minToolsVersion=\"8.0\"/>\n\
    </dependencies>\n\
    <scenes>\n\
    <!--View Controller-->\n\
    <scene sceneID=\"tne-QT-ifu\">\n\
    <objects>\n\
    <viewController storyboardIdentifier=\"viewController\" useStoryboardIdentifierAsRestorationIdentifier=\"YES\" id=\"BYZ-38-t0r\" customClass=\"ViewController\" sceneMemberID=\"viewController\">\n\
    <layoutGuides>\n\
    <viewControllerLayoutGuide type=\"top\" id=\"y3c-jy-aDJ\"/>\n\
    <viewControllerLayoutGuide type=\"bottom\" id=\"wfy-db-euE\"/>\n\
    </layoutGuides>\n\
    <view key=\"view\" contentMode=\"scaleToFill\" id=\"8bC-Xf-vdC\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"375\" height=\"667\"/>\n\
    <autoresizingMask key=\"autoresizingMask\" widthSizable=\"YES\" heightSizable=\"YES\"/>\n\
    <subviews>\n\
    <tableView clipsSubviews=\"YES\" contentMode=\"scaleToFill\" alwaysBounceVertical=\"YES\" dataMode=\"prototypes\" style=\"plain\" separatorStyle=\"default\" rowHeight=\"$$###$$\" sectionHeaderHeight=\"28\" sectionFooterHeight=\"28\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"UEU-h8-axn\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"20\" width=\"375\" height=\"647\"/>\n\
    <color key=\"backgroundColor\" white=\"1\" alpha=\"1\" colorSpace=\"calibratedWhite\"/>\n\
    <prototypes>\n";
    NSString *end=@"</prototypes>\n\
    </tableView>\n\
    </subviews>\n\
    <color key=\"backgroundColor\" red=\"1\" green=\"1\" blue=\"1\" alpha=\"1\" colorSpace=\"custom\" customColorSpace=\"sRGB\"/>\n\
    <constraints>\n\
    <constraint firstAttribute=\"trailing\" secondItem=\"UEU-h8-axn\" secondAttribute=\"trailing\" id=\"5xv-xd-e4t\"/>\n\
    <constraint firstItem=\"UEU-h8-axn\" firstAttribute=\"top\" secondItem=\"y3c-jy-aDJ\" secondAttribute=\"bottom\" id=\"gMh-YW-8Du\"/>\n\
    <constraint firstItem=\"UEU-h8-axn\" firstAttribute=\"leading\" secondItem=\"8bC-Xf-vdC\" secondAttribute=\"leading\" id=\"vB3-aw-yC4\"/>\n\
    <constraint firstItem=\"wfy-db-euE\" firstAttribute=\"top\" secondItem=\"UEU-h8-axn\" secondAttribute=\"bottom\" id=\"wAA-jL-k9b\"/>\n\
    </constraints>\n\
    </view>\n\
    <connections>\n\
    <outlet property=\"tableView\" destination=\"UEU-h8-axn\" id=\"2aw-ko-uSA\"/>\n\
    </connections>\n\
    </viewController>\n\
    <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"dkx-z0-nzr\" sceneMemberID=\"firstResponder\"/>\n\
    </objects>\n\
    <point key=\"canvasLocation\" x=\"-42.399999999999999\" y=\"88.605697151424295\"/>\n\
    </scene>\n\
    </scenes>\n\
    </document>";
    
    NSMutableString *strM=[NSMutableString string];
    [strM appendString:start];
    for (NSString *str in textCell) {
        [strM appendString:str];
    }
    [strM appendString:end];
    return strM;
}

+ (NSString *)getCollectionCellsInsertCells:(NSArray *)textCell{
    NSString *start=@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
    <document type=\"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB\" version=\"3.0\" toolsVersion=\"11762\" systemVersion=\"15G1217\" targetRuntime=\"iOS.CocoaTouch\" propertyAccessControl=\"none\" useAutolayout=\"YES\" useTraitCollections=\"YES\" colorMatched=\"YES\" initialViewController=\"BYZ-38-t0r\">\n\
    <device id=\"retina4_7\" orientation=\"portrait\">\n\
    <adaptation id=\"fullscreen\"/>\n\
    </device>\n\
    <dependencies>\n\
    <deployment identifier=\"iOS\"/>\n\
    <plugIn identifier=\"com.apple.InterfaceBuilder.IBCocoaTouchPlugin\" version=\"11757\"/>\n\
    <capability name=\"documents saved in the Xcode 8 format\" minToolsVersion=\"8.0\"/>\n\
    </dependencies>\n\
    <scenes>\n\
    <!--View Controller-->\n\
    <scene sceneID=\"tne-QT-ifu\">\n\
    <objects>\n\
    <viewController storyboardIdentifier=\"viewController\" useStoryboardIdentifierAsRestorationIdentifier=\"YES\" id=\"BYZ-38-t0r\" customClass=\"ViewController\" sceneMemberID=\"viewController\">\n\
    <layoutGuides>\n\
    <viewControllerLayoutGuide type=\"top\" id=\"y3c-jy-aDJ\"/>\n\
    <viewControllerLayoutGuide type=\"bottom\" id=\"wfy-db-euE\"/>\n\
    </layoutGuides>\n\
    <view key=\"view\" contentMode=\"scaleToFill\" id=\"8bC-Xf-vdC\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"375\" height=\"667\"/>\n\
    <autoresizingMask key=\"autoresizingMask\" widthSizable=\"YES\" heightSizable=\"YES\"/>\n\
    <subviews>\n\
    <collectionView clipsSubviews=\"YES\" multipleTouchEnabled=\"YES\" contentMode=\"scaleToFill\" dataMode=\"prototypes\" translatesAutoresizingMaskIntoConstraints=\"NO\" id=\"UFq-co-Ms5\">\n\
    <rect key=\"frame\" x=\"0.0\" y=\"20\" width=\"375\" height=\"647\"/>\n\
    <color key=\"backgroundColor\" white=\"1\" alpha=\"1\" colorSpace=\"calibratedWhite\"/>\n\
    <collectionViewFlowLayout key=\"collectionViewLayout\" minimumLineSpacing=\"10\" minimumInteritemSpacing=\"10\" id=\"b5m-Lg-SMx\">\n\
    <size key=\"itemSize\" width=\"$$$###$$$\" height=\"###$$$###\"/>\n\
    <size key=\"headerReferenceSize\" width=\"0.0\" height=\"0.0\"/>\n\
    <size key=\"footerReferenceSize\" width=\"0.0\" height=\"0.0\"/>\n\
    <inset key=\"sectionInset\" minX=\"0.0\" minY=\"0.0\" maxX=\"0.0\" maxY=\"0.0\"/>\n\
    </collectionViewFlowLayout>\n\
    <cells>\n";
    NSString *end=@"</cells>\n\
    </collectionView>\n\
    </subviews>\n\
    <color key=\"backgroundColor\" red=\"1\" green=\"1\" blue=\"1\" alpha=\"1\" colorSpace=\"custom\" customColorSpace=\"sRGB\"/>\n\
    <constraints>\n\
    <constraint firstItem=\"wfy-db-euE\" firstAttribute=\"top\" secondItem=\"UFq-co-Ms5\" secondAttribute=\"bottom\" id=\"06N-Pc-f6a\"/>\n\
    <constraint firstItem=\"UFq-co-Ms5\" firstAttribute=\"leading\" secondItem=\"8bC-Xf-vdC\" secondAttribute=\"leading\" id=\"58r-ab-JaX\"/>\n\
    <constraint firstAttribute=\"trailing\" secondItem=\"UFq-co-Ms5\" secondAttribute=\"trailing\" id=\"9Op-YZ-HSY\"/>\n\
    <constraint firstItem=\"UFq-co-Ms5\" firstAttribute=\"top\" secondItem=\"y3c-jy-aDJ\" secondAttribute=\"bottom\" id=\"sQU-0K-dVQ\"/>\n\
    </constraints>\n\
    </view>\n\
    <connections>\n\
    <outlet property=\"collectionView\" destination=\"UFq-co-Ms5\" id=\"lGb-dL-7ux\"/>\n\
    </connections>\n\
    </viewController>\n\
    <placeholder placeholderIdentifier=\"IBFirstResponder\" id=\"dkx-z0-nzr\" sceneMemberID=\"firstResponder\"/>\n\
    </objects>\n\
    <point key=\"canvasLocation\" x=\"-42.399999999999999\" y=\"88.605697151424295\"/>\n\
    </scene>\n\
    </scenes>\n\
    </document>";
    NSMutableString *strM=[NSMutableString string];
    [strM appendString:start];
    for (NSString *str in textCell) {
        [strM appendString:str];
    }
    [strM appendString:end];
    return strM;
}

+ (CGFloat)getCellHeight:(NSString *)CellText{
    NSArray *arr=[CellText componentsSeparatedByString:@"\n"];
    NSString *tempStr=@"";
    for (NSString *str in arr) {
        tempStr=[ZHNSString removeSpacePrefix:str];
        if ([tempStr hasPrefix:@"<rect key=\"frame\""]) {
            if ([tempStr rangeOfString:@"height=\""].location!=NSNotFound) {
                NSString *heightStr=[tempStr substringFromIndex:[tempStr rangeOfString:@"height=\""].location+8];
                heightStr=[heightStr substringToIndex:[heightStr rangeOfString:@"\""].location];
                return [heightStr floatValue];
            }
        }
    }
    return 0;
}
+ (CGFloat)getCellWidth:(NSString *)CellText{
    NSArray *arr=[CellText componentsSeparatedByString:@"\n"];
    NSString *tempStr=@"";
    for (NSString *str in arr) {
        tempStr=[ZHNSString removeSpacePrefix:str];
        if ([tempStr hasPrefix:@"<rect key=\"frame\""]) {
            if ([tempStr rangeOfString:@"width=\""].location!=NSNotFound) {
                NSString *widthStr=[tempStr substringFromIndex:[tempStr rangeOfString:@"width=\""].location+7];
                widthStr=[widthStr substringToIndex:[widthStr rangeOfString:@"\""].location];
                return [widthStr floatValue];
            }
        }
    }
    return 0;
}
@end
