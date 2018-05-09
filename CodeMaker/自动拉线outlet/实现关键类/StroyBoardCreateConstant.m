#import "StroyBoardCreateConstant.h"
#import "ZHStoryboardTextManagerConstant.h"

@interface StroyBoardCreateConstant ()

@property (nonatomic,strong)NSDictionary *customAndId;
@property (nonatomic,strong)NSDictionary *customAndName;
@property (nonatomic,strong)NSDictionary *idAndViewPropertys;
@property (nonatomic,strong)NSDictionary *idAndOutletViews;
@property (nonatomic,strong)NSDictionary *idAndViews;
@property (nonatomic,strong)NSMutableDictionary *IdsCustomDicM;

@property (nonatomic,strong)NSMutableArray *ConstantArrM;

@end
@implementation StroyBoardCreateConstant
- (void)getConstant:(NSString *)stroyBoard toConstantDicM:(NSMutableDictionary *)ConstantDicM{
    NSString *filePath=stroyBoard;
    
    self.ConstantArrM=[NSMutableArray array];
    if ([ZHFileManager fileExistsAtPath:filePath]==NO) {
        return;
    }
    
    NSString *context=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    self.IdsCustomDicM=[NSMutableDictionary dictionary];
    
    context=[ZHStoryboardTextManagerConstant addCustomClassToAllViews:context withIdsCustomDicM:self.IdsCustomDicM];
    
    ReadXML *xml=[ReadXML new];
    [xml initWithXMLString:context];
    
    NSDictionary *MyDic=[xml TreeToDict:xml.rootElement];
    
    NSArray *allViewControllers=[ZHStoryboardXMLManager getAllViewControllerWithDic:MyDic andXMLHandel:xml];
    
    //获取所有View的CustomClass与对应的id
    NSDictionary *customAndId=[ZHStoryboardXMLManager getAllViewCustomAndIdWithAllViewControllerArrM:allViewControllers andXMLHandel:xml];
    self.customAndId=customAndId;
    //获取所有View的CustomClass与对应的真实控件类型名字
    NSDictionary *customAndName=[ZHStoryboardXMLManager getAllViewCustomAndNameWithAllViewControllerArrM:allViewControllers andXMLHandel:xml];
    self.customAndName=customAndName;
    
    NSDictionary *idAndViews=[ZHStoryboardXMLManager getAllViewWithAllViewControllerArrM:allViewControllers andXMLHandel:xml];
    self.idAndViews=idAndViews;
    
    NSDictionary *idAndViewPropertys=[ZHStoryboardPropertyManager getPropertysForView:idAndViews withCustomAndName:customAndName andXMLHandel:xml];
    self.idAndViewPropertys=idAndViewPropertys;
    
    NSDictionary *idAndOutletViews=[ZHStoryboardXMLManager getAllOutletViewWithAllViewControllerArrM:allViewControllers andXMLHandel:xml];
    self.idAndOutletViews=idAndOutletViews;
    
    //开始操作所有ViewController
    for (NSDictionary *dic in allViewControllers) {
        
        NSString *viewController;
        if(dic[@"customClass"]!=nil){
            viewController=dic[@"customClass"];
            {
                NSArray *views=[ZHStoryboardXMLManager getAllViewControllerSubViewsWithViewControllerDic:dic andXMLHandel:xml];
                
                //在这里,定义存储控件自身的所有约束 比如宽度和高度之类 和关联对象的所有约束的字典
                NSMutableDictionary *viewConstraintDicM_Self=[NSMutableDictionary dictionary];
                NSMutableDictionary *viewConstraintDicM_Other=[NSMutableDictionary dictionary];
                
                //获取特殊的View --- >self.view
                [ZHStoryboardXMLManager getViewAllConstraintWithControllerDic:dic andXMLHandel:xml withViewIdStr:@"self.view" withSelfConstraintDicM:viewConstraintDicM_Self withOtherConstraintDicM:viewConstraintDicM_Other];
                
                for (NSString *idStr in views) {
                    
                    //在这里,获取控件自身的所有约束 比如宽度和高度之类 和关联对象的所有约束
                    [ZHStoryboardXMLManager getViewAllConstraintWithControllerDic:dic andXMLHandel:xml withViewIdStr:idStr withSelfConstraintDicM:viewConstraintDicM_Self withOtherConstraintDicM:viewConstraintDicM_Other];
                }
                
                NSMutableDictionary *viewConstraintDicM_Self_NEW=[viewConstraintDicM_Self mutableCopy];
                NSMutableDictionary *viewConstraintDicM_Other_NEW=[viewConstraintDicM_Other mutableCopy];
                
                [ZHStoryboardXMLManager reAdjustViewAllConstraintWithNewSelfConstraintDicM:viewConstraintDicM_Self_NEW withNewOtherConstraintDicM:viewConstraintDicM_Other_NEW withXMLHandel:xml];
                [ZHStoryboardXMLManager reAdjustViewAllConstraintWithNewSelfConstraintDicM_Second:viewConstraintDicM_Self_NEW withNewOtherConstraintDicM:viewConstraintDicM_Other_NEW withXMLHandel:xml];
                [ZHStoryboardXMLManager reAdjustViewAllConstraintWithNewSelfConstraintDicM_Three:viewConstraintDicM_Self_NEW withNewOtherConstraintDicM:viewConstraintDicM_Other_NEW withXMLHandel:xml];
                
                //在这里插入所有view的创建和约束
                [self.ConstantArrM addObject:viewConstraintDicM_Self_NEW];
            }
            
            NSArray *tableViewCellDic=[ZHStoryboardXMLManager getTableViewCellNamesWithViewControllerDic:dic andXMLHandel:xml];
            NSArray *collectionViewCellDic=[ZHStoryboardXMLManager getCollectionViewCellNamesWithViewControllerDic:dic andXMLHandel:xml];
            
            [self detailSubCells:tableViewCellDic andXMLHandel:xml withFatherViewController:viewController];
            [self detailSubCells:collectionViewCellDic andXMLHandel:xml withFatherViewController:viewController];
        }
    }
    
    //这句话一定要加
    [ZHStroyBoardFileManager done];
    [ZHStoryboardTextManagerConstant done];
    
    customAndId=nil;
    customAndName=nil;
    xml=nil;
    
    //开始替换
    NSMutableDictionary *resultConstantDicM=[NSMutableDictionary dictionary];
    for (NSInteger j=0; j<self.ConstantArrM.count; j++) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:self.ConstantArrM[j]];
        NSArray *dicKeys=[dic allKeys];
        for (NSInteger k=0; k<dicKeys.count; k++) {
            NSString *dicKey=dicKeys[k];
            NSMutableArray *arrTemp=[NSMutableArray arrayWithArray:dic[dicKey]];
            if (arrTemp!=nil) {
                if (arrTemp.count>0) {
                    if(self.IdsCustomDicM[dicKey]!=nil){
                        for (NSInteger i=0; i<arrTemp.count; i++) {
                            NSMutableDictionary *subDic=[NSMutableDictionary dictionaryWithDictionary:arrTemp[i]];
                            if (subDic[@"firstItem"]==nil||([subDic[@"firstItem"] isKindOfClass:[NSString class]]&&[subDic[@"firstItem"] length]<=0)) {
                                subDic[@"firstItem"]=self.IdsCustomDicM[dicKey];
                            }else{
                                if ([subDic[@"firstItem"] isEqualToString:dicKey]) {
                                    subDic[@"firstItem"]=self.IdsCustomDicM[dicKey];
                                }else if ([subDic[@"secondItem"] isEqualToString:dicKey]){
                                    subDic[@"firstItem"]=self.IdsCustomDicM[dicKey];
                                    subDic[@"firstAttribute"]=subDic[@"secondAttribute"];
                                }
                            }
                            arrTemp[i]=subDic;
                        }
                        
                        if (resultConstantDicM[self.IdsCustomDicM[dicKey]]!=nil) {
                            [resultConstantDicM[self.IdsCustomDicM[dicKey]] addObjectsFromArray:arrTemp];
                        }else{
                            [resultConstantDicM setValue:arrTemp forKey:self.IdsCustomDicM[dicKey]];
                        }
                    }
                }
                dic[dicKey]=arrTemp;
            }
        }
        self.ConstantArrM[j]=dic;
    }
    
    for (NSString *key in resultConstantDicM) {
        [ConstantDicM setValue:resultConstantDicM[key] forKey:key];
    }
}


/**递归继续子cell的代码生成*/
- (void)detailSubCells:(NSArray *)subCells andXMLHandel:(ReadXML *)xml withFatherViewController:(NSString *)viewController{
    for (NSDictionary *subDic in subCells) {
        
        NSString *fatherCellName=[xml dicNodeValueWithKey:@"customClass" ForDic:subDic];
        
        NSArray *views=[ZHStoryboardXMLManager getAllCellSubViewsWithViewControllerDic:subDic andXMLHandel:xml];
        
        //在这里,定义存储控件自身的所有约束 比如宽度和高度之类 和关联对象的所有约束的字典
        NSMutableDictionary *viewConstraintDicM_Self=[NSMutableDictionary dictionary];
        NSMutableDictionary *viewConstraintDicM_Other=[NSMutableDictionary dictionary];
        
        //获取特殊的View --- >self.view
        [ZHStoryboardXMLManager getViewAllConstraintWithControllerDic:subDic andXMLHandel:xml withViewIdStr:fatherCellName withSelfConstraintDicM:viewConstraintDicM_Self withOtherConstraintDicM:viewConstraintDicM_Other];
        
        
        for (NSString *idStr in views) {
            //在这里,获取控件自身的所有约束 比如宽度和高度之类 和关联对象的所有约束
            [ZHStoryboardXMLManager getViewAllConstraintWithControllerDic:subDic andXMLHandel:xml withViewIdStr:idStr withSelfConstraintDicM:viewConstraintDicM_Self withOtherConstraintDicM:viewConstraintDicM_Other];
        }
        
        NSMutableDictionary *viewConstraintDicM_Self_NEW=[viewConstraintDicM_Self mutableCopy];
        NSMutableDictionary *viewConstraintDicM_Other_NEW=[viewConstraintDicM_Other mutableCopy];
        
        [ZHStoryboardXMLManager reAdjustViewAllConstraintWithNewSelfConstraintDicM:viewConstraintDicM_Self_NEW withNewOtherConstraintDicM:viewConstraintDicM_Other_NEW withXMLHandel:xml];
        [ZHStoryboardXMLManager reAdjustViewAllConstraintWithNewSelfConstraintDicM_Second:viewConstraintDicM_Self_NEW withNewOtherConstraintDicM:viewConstraintDicM_Other_NEW withXMLHandel:xml];
        [ZHStoryboardXMLManager reAdjustViewAllConstraintWithNewSelfConstraintDicM_Three:viewConstraintDicM_Self_NEW withNewOtherConstraintDicM:viewConstraintDicM_Other_NEW withXMLHandel:xml];
        
        //在这里插入所有view的创建和约束
        [self.ConstantArrM addObject:viewConstraintDicM_Self_NEW];
        
        NSArray *tableViewCellDic=[ZHStoryboardXMLManager getTableViewCellNamesWithViewControllerDic:subDic andXMLHandel:xml];
        NSArray *collectionViewCellDic=[ZHStoryboardXMLManager getCollectionViewCellNamesWithViewControllerDic:subDic andXMLHandel:xml];
        
        [self detailSubCells:tableViewCellDic andXMLHandel:xml withFatherViewController:viewController];
        [self detailSubCells:collectionViewCellDic andXMLHandel:xml withFatherViewController:viewController];
    }
}

@end
