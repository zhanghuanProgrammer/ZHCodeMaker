#import "SmallFunctionViewController.h"
#import "SmallFunctionTableViewCell.h"
#import "ZHRemoveTheComments.h"
#import "ZHStatisticalCodeRows.h"
#import "ZHFormatCode.h"
#import "CodeCounter.h"
#import "ZHImageCompression.h"

@interface SmallFunctionViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation SmallFunctionViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
        
        NSArray *arr=@[@"去除代码注释",@"修改类文件名",@"格式化代码风格",@"查看工程或文件总代码行数",@"图片压缩",@"Json数据格式化",@"Json数据去除无用字符",@"Json数据转XML",@"Json数据转plist",@"Json数据缩减体积",@"XML转Json"];
        
        for (NSInteger i=0; i<arr.count; i++) {
            @autoreleasepool {
                SmallFunctionCellModel *SmallFunctionModel=[SmallFunctionCellModel new];
                SmallFunctionModel.title=arr[i];
                [_dataArr addObject:SmallFunctionModel];
            }
        }
	}
	return _dataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
    
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
    self.tableView.tableFooterView=[UIView new];
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    //设置NavagationBar (Left和Right) Title
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(leftBarClick)];
    self.title=@"小功能";
}
- (void)leftBarClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableViewDelegate实现的方法:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.dataArr[indexPath.row];
	if ([modelObjct isKindOfClass:[SmallFunctionCellModel class]]){
		SmallFunctionTableViewCell *smallFunctionCell=[tableView dequeueReusableCellWithIdentifier:@"SmallFunctionTableViewCell"];
		SmallFunctionCellModel *model=modelObjct;
		[smallFunctionCell refreshUI:model];
		return smallFunctionCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    SmallFunctionCellModel *model=self.dataArr[indexPath.row];
    NSString *Msg;
    if ([model.title isEqualToString:@"去除代码注释"]) {
        [ZHFileManager createFileAtPath:macDesktopPath];
        Msg=@"请把要去除注释的 \"文件或文件夹路径\" 填写在桌面的\"代码助手.m\"中";
        [self removeTheCommentWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"修改类文件名"]) {
        [TabBarAndNavagation pushViewController:@"ChangeCodeFileNameViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
    }else if ([model.title isEqualToString:@"格式化代码风格"]) {
        [ZHFileManager createFileAtPath:macDesktopPath];
        Msg=@"请把要格式化代码风格的 \"文件或文件夹路径\" 填写在桌面的\"代码助手.m\"中";
        [self formatWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"查看工程或文件总代码行数"]) {
        [ZHFileManager createFileAtPath:macDesktopPath];
        Msg=@"请把要查看工程或文件总代码行数的 \"文件或文件夹\" 路径填写在桌面的\"代码助手.m\"中";
        [self totalNumberOfLinesOfCodeWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"Json数据格式化"]) {
        Msg=@"请把要格式化的Json数据 填写在桌面的\"代码助手.m\"中";
        [self jsonFormattingWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"Json数据去除无用字符"]) {
        Msg=@"请把要去除无用字符的Json数据 填写在桌面的\"代码助手.m\"中";
        [self jsonRemoveUselessStringWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"Json数据转XML"]) {
        Msg=@"请把要转XML的Json数据 填写在桌面的\"代码助手.m\"中";
        [self jsonToXMLWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"Json数据转plist"]) {
        Msg=@"请把要转plist的Json数据 填写在桌面的\"代码助手.m\"中";
        [self jsonToPlistWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"Json数据缩减体积"]) {
        Msg=@"请把要缩减体积的Json数据 填写在桌面的\"代码助手.m\"中";
        [self jsonCompressionWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"XML转Json"]) {
        Msg=@"请把要转Json的XML数据 填写在桌面的\"代码助手.m\"中";
        [self xmlToJsonWithTitle:model.title withMsg:Msg];
    }else if ([model.title isEqualToString:@"图片压缩"]) {
        Msg=@"请把要压缩图片路径和压缩比例 填写在桌面的\"代码助手.m\"中";
        [self compresionWithTitle:model.title withMsg:Msg];
        [[CreatFatherFile new] creatFatherFile:@"代码助手" andData:@[@"压缩比例--:--\"<#0-1#>\"",@"路径--:--[\n\"<#请填写#>\"\n]"]];
    }
}

- (NSString *)getPath{
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    
    NSString *text=[NSString stringWithContentsOfFile:macDesktopPath encoding:NSUTF8StringEncoding error:nil];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return text;
}

- (void)removeTheCommentAction:(NSString *)path RemoveTheCommentsType:(ZHRemoveTheCommentsType)removeTheCommentsType{
    [ZHBackUp backUpProject:path asyncBlock:^NSString *{
        return [ZHRemoveTheComments BeginWithFilePath:[self getPath] type:removeTheCommentsType];
    } forVC:self];
}

/**去除注释*/
- (void)removeTheCommentWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
        [self removeTheCommentAction:[self getPath] RemoveTheCommentsType:ZHRemoveTheCommentsTypeEnglishComments];
    },^{
        [self removeTheCommentAction:[self getPath] RemoveTheCommentsType:ZHRemoveTheCommentsTypeAllComments];
    },^{
        [self removeTheCommentAction:[self getPath] RemoveTheCommentsType:ZHRemoveTheCommentsTypeDoubleSlashComments];
    },^{
        [self removeTheCommentAction:[self getPath] RemoveTheCommentsType:ZHRemoveTheCommentsTypeFuncInstructionsComments];
    },^{
        [self removeTheCommentAction:[self getPath] RemoveTheCommentsType:ZHRemoveTheCommentsTypeFileInstructionsComments];
    },^{}] otherButtonTitles:@[@"只留中文注释",@"删除全部注释",@"删除//注释",@"删除/**/或/***/注释",@"删除文件说明注释",@"取消"]];
}

/**格式化代码风格*/
- (void)formatWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
        [self format:[self getPath]];
    },^{}] otherButtonTitles:@[@"格式化代码风格",@"取消"]];
}

- (void)format:(NSString *)path{
    [ZHBackUp backUpProject:path asyncBlock:^NSString *{
        return [ZHFormatCode formatCodeFilePath:[self getPath]];
    } forVC:self];
}

- (void)statisticalNumberOfLinesOfCode{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
    
    NSString *path=[self getPath];
    if (path.length<=0) {
        hud.label.text = @"路径为空!";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        return;
    }
    hud.label.text = @"正在统计!";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *resultDeatilString=[[CodeCounter new] codeCounter:path];
        resultDeatilString=[NSString stringWithFormat:@"%@\n详细分析如下:\n%@",path,resultDeatilString];
        [CodeAssistantFileManager saveContent:resultDeatilString];
        
        // 处理耗时操作的代码块...
        NSString *resultString=[ZHStatisticalCodeRows Begin:path];
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.label.text=resultString;
            //回调或者说是通知主线程刷新，
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        });
    });
}

/**查看工程或文件总代码行数*/
- (void)totalNumberOfLinesOfCodeWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        [self statisticalNumberOfLinesOfCode];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写完路径,查看工程总代码行数" ActionSheet:NO];
}

/**Json数据格式化*/
- (void)jsonFormattingWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSDictionary *jsonDic=[CodeAssistantFileManager getJsonDicFromFile];
        [CodeAssistantFileManager saveContent:[jsonDic jsonPrettyStringEncoded]];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入Json数据,进行Json数据格式化" ActionSheet:NO];
}

/**Json数据去除无用字符*/
- (void)jsonRemoveUselessStringWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSDictionary *jsonDic=[CodeAssistantFileManager getJsonDicFromFile];
        [CodeAssistantFileManager saveContent:[jsonDic jsonStringEncoded]];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入Json数据,进行Json数据去除无用字符*" ActionSheet:NO];
}

/**Json数据转XML*/
- (void)jsonToXMLWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSDictionary *jsonDic=[CodeAssistantFileManager getJsonDicFromFile];
        [CodeAssistantFileManager saveContent:[[ZHJsonToXML new] jsonDicToXML:jsonDic]];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入Json数据,进行Json数据转XML" ActionSheet:NO];
}

/**Json数据转plist*/
- (void)jsonToPlistWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSDictionary *jsonDic=[CodeAssistantFileManager getJsonDicFromFile];
        [jsonDic writeToFile:[CodeAssistantFileManager getPath] atomically:YES];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入Json数据,进行Json数据转plist" ActionSheet:NO];
}

/**Json数据缩减体积*/
- (void)jsonCompressionWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSString *json=[CodeAssistantFileManager getFileContent];
        [CodeAssistantFileManager saveContent:[[ZHJson new] compressionJson:json]];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入Json数据,进行Json数据缩减体积" ActionSheet:NO];
}

/**XML转Json*/
- (void)xmlToJsonWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSString *xml=[CodeAssistantFileManager getFileContent];
        NSDictionary *jsonDic=[NSDictionary dictionaryWithXML:xml needRecoderOrder:NO];
        [CodeAssistantFileManager saveContent:[jsonDic jsonPrettyStringEncoded]];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入XML数据,进行XML转Json" ActionSheet:NO];
}

/**图片压缩*/
- (void)compresionWithTitle:(NSString *)title withMsg:(NSString *)msg{
    [ZHAlertAction alertWithTitle:title withMsg:msg addToViewController:self withCancleBlock:nil withOkBlock:^{
        NSDictionary *jsonDic=[CodeAssistantFileManager getJsonDicFromFile];
        CGFloat compresionPer=1;
        if ([[CreatFatherFile new]judge:jsonDic[@"压缩比例"]]) {
            compresionPer=[jsonDic[@"压缩比例"] floatValue];
        }
        if(compresionPer>=0&&compresionPer<=1){
            NSArray *arr=jsonDic[@"路径"];
            if ([arr isKindOfClass:[NSArray class]]) {
                for (NSString *str in arr) {
                    if ([ZHFileManager fileExistsAtPath:str]) {
                        [ZHImageCompression compresionImagePath:str compresionPer:compresionPer];
                    }
                }
            }
            [MBProgressHUD showHUDAddedToView:self.view withText:@"压缩成功" withDuration:1 animated:YES];
        }else
            [MBProgressHUD showHUDAddedToView:self.view withText:@"压缩比例不是数字类型" withDuration:1 animated:YES];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已导入XML数据,进行XML转Json" ActionSheet:NO];
}
@end
