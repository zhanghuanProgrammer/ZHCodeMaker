#import "ZHAddCollectionViewCellLayoutLibriary.h"
#import "ZHAddLayoutRelatedView.h"
#import "ZHAddLayoutViewRectModel.h"
#import "ZHDrawModel.h"
#import "ZHDraw.h"
#import "ZHLayoutLibriaryCollectionViewCellModel.h"
#import "ZHBinarySearch.h"
#import "ZHAddLayoutLibriaryHelp.h"

@interface ZHAddCollectionViewCellLayoutLibriary ()
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)NSMutableArray *newModelArr;
@property (nonatomic,strong)ZHBinarySearch *binarySearch;
@property (nonatomic,strong)ZHAddLayoutLibriaryHelp *help;
@end

@implementation ZHAddCollectionViewCellLayoutLibriary

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr=[NSMutableArray array];
        [_dataArr addObjectsFromArray:[ZHLayoutLibriaryCollectionViewCellModel findAll]];
    }
    return _dataArr;
}

- (ZHAddLayoutLibriaryHelp *)help{
    if (!_help) {
        _help=[ZHAddLayoutLibriaryHelp new];
    }
    return _help;
}

- (ZHBinarySearch *)binarySearch{
    if (!_binarySearch) {
        _binarySearch=[ZHBinarySearch new];
    }
    return _binarySearch;
}

- (NSMutableArray *)newModelArr{
    if (!_newModelArr) {
        _newModelArr=[NSMutableArray array];
    }
    return _newModelArr;
}

/**获取CollectionViewCell*/
- (NSArray *)saveCollectionViewCellSubViewDraw{
    
    //加载二分查找数据源
    NSMutableArray *binarySearchData=[NSMutableArray array];
    for (ZHLayoutLibriaryCollectionViewCellModel *model in self.dataArr) {
        [binarySearchData addObjectsFromArray:[NSArray arrayWithJsonString:model.identityJosn]];
    }
    [self.binarySearch setOriginalData:binarySearchData];
    
    //1.需要拿到cell的rect
    //2.需要拿到cell里面所有子控件的rect
    //3.调用ZHDraw进行绘制,并且保存
    
    if ([ZHFileManager fileExistsAtPath:_filePath]==NO) return nil;
    
    //读取StoryBoard文件
    NSString *context=[NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *rootDic=[NSDictionary dictionaryWithXML:context needRecoderOrder:YES];
    
//    获取所有viewController
    ZHJsonPath *jsonPath=[[ZHJsonPath alloc]initWithJsonDic:rootDic];
    NSArray *allViewController=[jsonPath getTargetsForPath:@[@"scenes",@"scene",@"objects",@"viewController"]];
    
    //获取所有collectionViewCell
    NSMutableArray *allCollectionViewCells=[NSMutableArray array];
    for (NSDictionary *dic in allViewController) {
        ZHJsonPath *subJsonPath=[[ZHJsonPath alloc]initWithJsonDic:dic];
        NSArray *mytargets=[subJsonPath getTargetsForPath:@[@"view",@"subviews",@"collectionViewCell"]];
        [allCollectionViewCells addObjectsFromArray:[ZHJsonPath getDictionarysFromTargrtArr:mytargets]];
    }
    NSInteger allCollectionViewCellCount=allCollectionViewCells.count;
    //如果cell里面还嵌套collectionView,添加进来,再还嵌套就不加了,因为基本上没有这种情况
    NSArray *allSubCollectionViewCells;
    for (NSDictionary *dic in allCollectionViewCells) {
        ZHJsonPath *subJsonPath=[[ZHJsonPath alloc]initWithJsonDic:dic];
        allSubCollectionViewCells=[subJsonPath getTargetsForPath:@[@"subviews",@"collectionViewCell"]];
    }
    
    if (allSubCollectionViewCells.count>0) {
        [allCollectionViewCells addObjectsFromArray:[ZHJsonPath getDictionarysFromTargrtArr:allSubCollectionViewCells]];
    }
    
    NSInteger addCount=0;
    for (NSDictionary *dic in allCollectionViewCells) {
        //获取CollectionViewCell里面的所有控件
        NSMutableArray *allCollectionViewCellSubViews=[NSMutableArray array];
        
        ZHJsonPath *subJsonPath=[[ZHJsonPath alloc]initWithJsonDic:dic];
        NSArray *mytargets=[subJsonPath getTargetsForPath:@[@"view",@"subviews"]];
        [allCollectionViewCellSubViews addObjectsFromArray:[ZHJsonPath getDictionarysFromTargrtArr:mytargets]];
        
        ZHRepearDictionary *allViews=[ZHRepearDictionary new];
        
        //计算控件种类对应的个数
        NSMutableDictionary *allViewTypeAndCount=[NSMutableDictionary dictionary];
        NSMutableArray *allIdentity=[NSMutableArray array];
        [subJsonPath getAllStringValue:allIdentity forKey:@"customClass" withJsonDic:dic noContainKeys:@[@"outlet",@"constraint"]];
        [subJsonPath getAllStringValue:allIdentity forKey:@"id" withJsonDic:dic noContainKeys:@[@"outlet",@"constraint"]];
        
        for (NSDictionary *dic in allCollectionViewCellSubViews) {
            
            for (NSString *key in dic) {
                id value=dic[key];
                NSInteger count=0;
                if ([value isKindOfClass:[NSArray class]]) {//说明这个类型的控件很多个(跟字典转XML有关)
                    count=[value count];
                    NSInteger index=0;
                    for (id subValue in value) {
                        ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                        relatedView.selfView=subValue;
                        relatedView.layerCount=0;
                        if ([subValue isKindOfClass:[NSDictionary class]]&&subValue[@"ZH_Recoder_Order"]) {
                            NSInteger sameLayerCountIndex=[subValue[@"ZH_Recoder_Order"] integerValue];
                            relatedView.SameLayerCountIndex=sameLayerCountIndex;
                        }else{
                            relatedView.SameLayerCountIndex=index++;
                        }
                        
                        relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                        [allViews setValue:relatedView forKey:key];
                    }
                }else if ([value isKindOfClass:[NSDictionary class]]) {//说明这个类型的控件只有一个(跟字典转XML有关)
                    count=1;
                    ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                    relatedView.selfView=value;
                    relatedView.layerCount=0;
                    if (value[@"ZH_Recoder_Order"]) {
                        NSInteger sameLayerCountIndex=[value[@"ZH_Recoder_Order"] integerValue];
                        relatedView.SameLayerCountIndex=sameLayerCountIndex;
                    }else{
                        relatedView.SameLayerCountIndex=0;
                    }
                    relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                    [allViews setValue:relatedView forKey:key];
                }
                if (allViewTypeAndCount[key]==nil) {
                    [allViewTypeAndCount setValue:[NSString stringWithFormat:@"%zd",count] forKey:key];
                }else{
                    NSInteger oldCount=[allViewTypeAndCount[key] integerValue];
                    NSInteger newCount=oldCount+=count;
                    [allViewTypeAndCount setValue:[NSString stringWithFormat:@"%zd",newCount] forKey:key];
                }
                
                if ([key isEqualToString:@"view"]) {//view 要加上subViews
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                        relatedView.selfView=value;
                        relatedView.layerCount=0;
                        relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                        [self getViewKindAndCount:allViewTypeAndCount forViews:relatedView saveAllViews:allViews];
                    }else if ([value isKindOfClass:[NSArray class]]) {
                        for (id view in value) {
                            ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                            relatedView.selfView=view;
                            relatedView.layerCount=0;
                            relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                            [self getViewKindAndCount:allViewTypeAndCount forViews:relatedView saveAllViews:allViews];
                        }
                    }
                }
            }
        }
        
        //开始保存
        if (dic[@"view"]&&dic[@"view"][@"rect"]) {
            NSDictionary *rectDic=dic[@"view"][@"rect"];
            
            CGRect cellRect;
            cellRect=CGRectMake([rectDic[@"x"] floatValue], [rectDic[@"y"] floatValue], [rectDic[@"width"] floatValue], [rectDic[@"height"] floatValue]);
            
            NSMutableArray *allFrames=[NSMutableArray array];
            [self getAllViewsFrame:allFrames forViews:[allViews.dicM allValues]];
            
            NSMutableArray *arrM=[NSMutableArray array];
            for (ZHAddLayoutViewRectModel *model in allFrames) {
                ZHDrawModel *drawRectModel=[ZHDrawModel new];
                ZHDrawModel *drawStringModel=[ZHDrawModel new];
                drawRectModel.type=ZHDrawModelTypeRect;
                drawStringModel.type=ZHDrawModelTypeString;
                drawRectModel.fatherRect=cellRect;
                drawStringModel.fatherRect=cellRect;
                drawRectModel.layerCount=model.layerCount;
                drawStringModel.layerCount=model.layerCount;
                drawRectModel.SameLayerCountIndex=model.SameLayerCountIndex;
                drawStringModel.SameLayerCountIndex=model.SameLayerCountIndex;
                drawRectModel.rect=CGRectMake(model.x_value, model.y_value, model.width_value, model.height_value);
                drawStringModel.rect=CGRectMake(model.x_value, model.y_value, model.width_value, model.height_value);
                drawStringModel.string=drawStringModel.categoryView=model.categoryView;
                drawRectModel.categoryView=model.categoryView;
                [arrM addObject:drawRectModel];
                [arrM addObject:drawStringModel];
            }
            
            
            
            //开始分析Cell的属性
            ZHLayoutLibriaryCollectionViewCellModel *model=[ZHLayoutLibriaryCollectionViewCellModel new];
            model.identityJosn=[allIdentity jsonStringEncoded];
            
            //检测是否存在标识符超过三个相同,如果是,说明这个cell已经保存过了,就不要再保存了
            BOOL needSave=YES;
            NSInteger count=0;
            NSArray *tempArr=[NSArray arrayWithJsonString:model.identityJosn];
            for (NSString *identity in tempArr) {
                if ([self.binarySearch binarySearch:identity]) {
                    count++;
                }
                if(count>=3){
                    needSave=NO;
                    break;
                }
            }
            
            if(needSave){
                addCount++;
                NSDictionary *allViewTypeAndCountTemp=[[ZHJson new] removeValueForKeys:@[@"ZH_Recoder_Order"] FromDictionary:allViewTypeAndCount];
                model.viewTypeAndCountJosn=[allViewTypeAndCountTemp jsonStringEncoded];
                //对应描绘矩形图片的地址
                NSString *drawRectAddress=[self saveCollectionViewCell_DrawRect:cellRect dataArr:arrM cellIdentity:dic[@"customClass"]];
                model.drawRectAddress=drawRectAddress;
                //对应模拟控件还原的图片的地址
                NSString *drawViewAddress=[self saveCollectionViewCell_DrawView:cellRect dataArr:arrM cellIdentity:dic[@"customClass"]];
                model.drawViewAddress=drawViewAddress;
                model.useCount=0;
                NSArray *fileAddress=[self getCellsCodeFiles:dic[@"customClass"]];
                if(fileAddress.count>0)model.fileAddress=[fileAddress jsonStringEncoded];
                else model.fileAddress=@"";
                NSArray *modelAddress=[self getModelsCodeFiles:dic[@"customClass"]];
                if(modelAddress.count>0)model.modelAddress=[modelAddress jsonStringEncoded];
                else model.modelAddress=@"";
                NSString *customClass=dic[@"customClass"];
                if(customClass.length<=0)customClass=[[ZHNSString getRandomStringWithLenth:10] stringByAppendingString:@"CollectionViewCell"];
                model.cellFileAddress=[self saveCellXmlCodeWithFileName:customClass cellCode:dic];
                model.customClassName=customClass;
                model.isDelete=0;
                [self.newModelArr addObject:model];
            }
        }
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(self.newModelArr.count>0){
            [ZHLayoutLibriaryCollectionViewCellModel saveObjects:self.newModelArr directoryName:@"LayoutLibriary"];
            
            //保存数据库
            NSString *dataBasePath=[ZHLayoutLibriaryCollectionViewCellModel dbPath:nil];
            NSString *toPath=[self.help.backUpDataBasePath stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:dataBasePath]];
            if ([ZHFileManager fileExistsAtPath:toPath]) {
                [ZHFileManager removeItemAtPath:toPath];
                [ZHFileManager copyItemAtPath:dataBasePath toPath:toPath];
            }
        }
        
    });
    
    return @[@(allCollectionViewCellCount),@(addCount)];
}

- (NSString *)saveCellXmlCodeWithFileName:(NSString *)fileName cellCode:(NSDictionary *)cellCode{
    NSString *savePath=[self.help.saveCellFileDirector stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",fileName]];
    NSString *xml=[[ZHJsonToXMLOrder new] jsonDicToXMLNoNeedHead:cellCode withRootName:@"collectionViewCell"];
    [xml writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return savePath;
}

- (NSArray *)getCellsCodeFiles:(NSString *)fileName{
    if(fileName.length<=0)return nil;
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *codeFilePath in self.codeFilePath) {
        NSString *name=[ZHFileManager getFileNameNoPathComponentFromFilePath:codeFilePath];
        if([name isEqualToString:fileName]){
            //先复制一份
            NSString *toPath=[self.help.saveCodeFileDirector stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:codeFilePath]];
            [ZHFileManager copyItemAtPath:codeFilePath toPath:toPath];
            [arrM addObject:toPath];
        }
    }
    return arrM;
}

- (NSArray *)getModelsCodeFiles:(NSString *)fileName{
    if(fileName.length<=0)return nil;
    //如果Cell文件名后面是以TableViewCell结尾
    NSArray *modelName=@[];
    if([fileName hasSuffix:@"CollectionViewCell"]){
        NSString *tempStr=[fileName substringToIndex:fileName.length-@"CollectionViewCell".length];
        modelName=@[[tempStr stringByAppendingString:@"CellModel"],[fileName stringByAppendingString:@"Model"]];
    }
    if (modelName.count<=0) {
        return @[];
    }
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *codeFilePath in self.codeFilePath) {
        
        NSString *name=[ZHFileManager getFileNameNoPathComponentFromFilePath:codeFilePath];
        if ([modelName containsObject:name]) {
            //先复制一份
            NSString *toPath=[self.help.saveCodeFileDirector stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:codeFilePath]];
            [ZHFileManager copyItemAtPath:codeFilePath toPath:toPath];
            [arrM addObject:toPath];
        }
    }
    return arrM;
}

/**这个函数是为了计算view里面还有其它控件,也需要把其它类型控件读取出来*/
- (void)getViewKindAndCount:(NSMutableDictionary *)allViewTypeAndCount forViews:(ZHAddLayoutRelatedView *)views saveAllViews:(ZHRepearDictionary *)allViewDicM{
    
    //获取里面的所有控件
    NSMutableArray *allSubViews=[NSMutableArray array];
    ZHJsonPath *subJsonPath=[[ZHJsonPath alloc]initWithJsonDic:views.selfView];
    NSArray *mytargets=[subJsonPath getTargetsForPath:@[@"subviews"]];
    [allSubViews addObjectsFromArray:[ZHJsonPath getDictionarysFromTargrtArr:mytargets]];
    
    //计算控件种类对应的个数
    for (NSDictionary *dic in allSubViews) {
        
        for (NSString *key in dic) {
            id value=dic[key];
            NSInteger count=0;
            
            if ([value isKindOfClass:[NSArray class]]) {//说明这个类型的控件很多个(跟字典转XML有关)
                count=[value count];
                NSInteger index=0;
                for (id subValue in value) {
                    ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                    relatedView.selfView=subValue;
                    relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                    relatedView.fatherRelatedView=views;
                    relatedView.layerCount=views.layerCount+1;
                    if ([subValue isKindOfClass:[NSDictionary class]]&&subValue[@"ZH_Recoder_Order"]) {
                        NSInteger sameLayerCountIndex=[subValue[@"ZH_Recoder_Order"] integerValue];
                        relatedView.SameLayerCountIndex=sameLayerCountIndex;
                    }else{
                        relatedView.SameLayerCountIndex=index++;
                    }
                    [allViewDicM setValue:relatedView forKey:key];
                }
            }else if ([value isKindOfClass:[NSDictionary class]]) {//说明这个类型的控件只有一个(跟字典转XML有关)
                count=1;
                ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                relatedView.selfView=value;
                relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                relatedView.fatherRelatedView=views;
                relatedView.layerCount=views.layerCount+1;
                if (value[@"ZH_Recoder_Order"]) {
                    NSInteger sameLayerCountIndex=[value[@"ZH_Recoder_Order"] integerValue];
                    relatedView.SameLayerCountIndex=sameLayerCountIndex;
                }else{
                    relatedView.SameLayerCountIndex=0;
                }
                [allViewDicM setValue:relatedView forKey:key];
            }
            if (allViewTypeAndCount[key]==nil) {
                [allViewTypeAndCount setValue:[NSString stringWithFormat:@"%zd",count] forKey:key];
            }else{
                NSInteger oldCount=[allViewTypeAndCount[key] integerValue];
                NSInteger newCount=oldCount+=count;
                [allViewTypeAndCount setValue:[NSString stringWithFormat:@"%zd",newCount] forKey:key];
            }
            
            if ([key isEqualToString:@"view"]) {//view 要加上subViews
                if ([value isKindOfClass:[NSDictionary class]]) {
                    ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                    relatedView.selfView=value;
                    relatedView.fatherRelatedView=views;
                    relatedView.layerCount=views.layerCount+1;
                    relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                    [self getViewKindAndCount:allViewTypeAndCount forViews:relatedView saveAllViews:allViewDicM];
                }else if ([value isKindOfClass:[NSArray class]]) {
                    for (id view in value) {
                        ZHAddLayoutRelatedView *relatedView=[ZHAddLayoutRelatedView new];
                        relatedView.selfView=view;
                        relatedView.fatherRelatedView=views;
                        relatedView.layerCount=views.layerCount+1;
                        relatedView.categoryView=[ZHRepearDictionary getKeyForKey:key];
                        [self getViewKindAndCount:allViewTypeAndCount forViews:relatedView saveAllViews:allViewDicM];
                    }
                }
            }
        }
    }
}

/**获取所有views的frame值*/
- (void)getAllViewsFrame:(NSMutableArray *)allViewsFrame forViews:(NSArray *)views{
    for (ZHAddLayoutRelatedView *relatedView in views) {
        if ([relatedView.selfView isKindOfClass:[NSDictionary class]]) {
            if (relatedView.selfView[@"rect"]) {
                
                ZHAddLayoutViewRectModel *model=[ZHAddLayoutViewRectModel new];
                model.categoryView=relatedView.categoryView;
                model.layerCount=relatedView.layerCount;
                model.SameLayerCountIndex=relatedView.SameLayerCountIndex;
                [model setValuesForKeysWithDictionary:relatedView.selfView[@"rect"]];
                
                if (relatedView.fatherRelatedView==nil) {
                    [allViewsFrame addObject:model];
                }else{
                    ZHAddLayoutRelatedView *tempRelatedView=relatedView;
                    while (tempRelatedView.fatherRelatedView!=nil) {
                        tempRelatedView=tempRelatedView.fatherRelatedView;
                        ZHAddLayoutViewRectModel *tempModel=[ZHAddLayoutViewRectModel new];
                        if (tempRelatedView.selfView[@"rect"]) {
                            [tempModel setValuesForKeysWithDictionary:tempRelatedView.selfView[@"rect"]];
                            model.x_value+=tempModel.x_value;
                            model.y_value+=tempModel.y_value;
                        }
                    }
                    [allViewsFrame addObject:model];
                }
            }
        }
    }
}

/**开始绘制纯矩形的cell模拟*/
- (NSString *)saveCollectionViewCell_DrawRect:(CGRect)rect dataArr:(NSArray *)dataArr cellIdentity:(NSString *)cellIdentity{
    @autoreleasepool {
        NSString *macDocuments=[ZHFileManager getMacDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"LayoutLibriary"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        
        if (cellIdentity.length<=0) {
            cellIdentity=[ZHNSString getRandomStringWithLenth:26];
            while([ZHFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@.png",[macDocuments stringByAppendingPathComponent:cellIdentity]]]){
                cellIdentity=[ZHNSString getRandomStringWithLenth:26];
            }
        }
        UIView *keyView=[UIApplication sharedApplication].keyWindow;
        ZHDraw *drawView=[[ZHDraw alloc]initWithFrame:rect];
        drawView.type=ZHDrawTypeDraw;
        drawView.backgroundColor=[UIColor whiteColor];
        [keyView addSubview:drawView];
        [drawView clearData];
        for (ZHDrawModel *model in dataArr) {
            [drawView addZHDrawModel:model];
        }
        [drawView takeOffScreenRendering];
        UIImage *image=[drawView snapshotImage];
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *savePath=[NSString stringWithFormat:@"%@_Rect.png",[macDocuments stringByAppendingPathComponent:cellIdentity]];
        [imageData writeToFile:savePath atomically:YES];
        if (drawView) {
            [drawView removeFromSuperview];
        }
        return savePath;
    }
}

/**开始绘制更加真实的cell模拟*/
- (NSString *)saveCollectionViewCell_DrawView:(CGRect)rect dataArr:(NSArray *)dataArr cellIdentity:(NSString *)cellIdentity{
    @autoreleasepool {
        
        NSString *macDocuments=[ZHFileManager getMacDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"LayoutLibriary"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        
        if (cellIdentity.length<=0) {
            cellIdentity=[ZHNSString getRandomStringWithLenth:26];
            while([ZHFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@.png",[macDocuments stringByAppendingPathComponent:cellIdentity]]]){
                cellIdentity=[ZHNSString getRandomStringWithLenth:26];
            }
        }
        
        UIView *keyView=[UIApplication sharedApplication].keyWindow;
        ZHDraw *drawView=[[ZHDraw alloc]initWithFrame:rect];
        drawView.type=ZHDrawTypeView;
        drawView.backgroundColor=[UIColor whiteColor];
        [keyView addSubview:drawView];
        [drawView clearData];
        for (ZHDrawModel *model in dataArr) {
            [drawView addZHDrawModel:model];
        }
        [drawView creatSubViews];
        UIImage *image=[drawView snapshotImage];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *savePath=[NSString stringWithFormat:@"%@.png",[macDocuments stringByAppendingPathComponent:cellIdentity]];
        [imageData writeToFile:savePath atomically:YES];
        if (drawView) {
            [drawView removeFromSuperview];
        }
        return savePath;
    }
}

@end
