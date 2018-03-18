#import "SearchChangeFileViewController.h"

#import "SearchChangeFileTableViewCell.h"

@interface SearchChangeFileViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)UISearchBar *searchBarTextFiled;
@property (nonatomic,strong)NSMutableArray *searchDataArr;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UILabel *allSelect;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promoteHeight;

@end

@implementation SearchChangeFileViewController
- (NSMutableArray *)dataBase{
    if (!_dataBase) {
        _dataBase=[NSMutableArray array];
    }
    return _dataBase;
}

- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
	}
	return _dataArr;
}

- (NSMutableArray *)searchDataArr{
    if (!_searchDataArr) {
        _searchDataArr=[NSMutableArray array];
    }
    return _searchDataArr;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.edgesForExtendedLayout=UIRectEdgeNone;
    
    [self.allSelect cornerRadiusWithBorderColor:[UIColor blackColor] borderWidth:1];
    self.allSelect.backgroundColor=[UIColor grayColor];
    self.allSelect.textColor=[UIColor whiteColor];
    [self.allSelect addUITapGestureRecognizerWithTarget:self withAction:@selector(allSelectAction)];
    
    NSMutableArray *tempArrM=[NSMutableArray array];
    for (NSString *filePath in self.dataBase) {
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        if ([tempArrM containsObject:fileName]==NO) {
            SearchChangeFileCellModel *model=[SearchChangeFileCellModel new];
            model.title=fileName;
            model.path=filePath;
            model.isSelect=NO;
            [self.dataArr addObject:model];
            [tempArrM addObject:fileName];
        }
    }
    
    [self.searchDataArr addObjectsFromArray:self.dataArr];
    
    __weak typeof(self) weakSelf=self;
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        NSInteger selectCount=0;
        for (SearchChangeFileCellModel *model in weakSelf.dataArr) {
            if (model.isSelect) {
                selectCount++;
            }
        }
        if (selectCount==weakSelf.dataArr.count) {
            weakSelf.allSelect.text=@"全不选";
        }else{
            weakSelf.allSelect.text=@"全选";
        }
    } WithIdentity:@"select_SearchChangeFileViewController"];
    
    NSArray *pbxprojArr=[ZHFileManager subPathFileArrInDirector:self.filePath hasPathExtension:@[@".pbxproj"]];
    if (pbxprojArr==0) {
        self.promoteHeight.constant=0;
    }
    
}

- (void)allSelectAction{
    if ([self.allSelect.text isEqualToString:@"全选"]) {
        for (SearchChangeFileCellModel *model in self.dataArr) {
            model.isSelect=YES;
            [self.tableView reloadData];
        }
        self.allSelect.text=@"全不选";
    }else{//全不选
        for (SearchChangeFileCellModel *model in self.dataArr) {
            model.isSelect=NO;
            [self.tableView reloadData];
        }
        self.allSelect.text=@"全选";
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.searchBarTextFiled) {
        [UIView animateWithDuration:0.25 animations:^{
            self.searchBarTextFiled.x-=60;
            self.searchBarTextFiled.width+=60;
            [self.searchBarTextFiled layoutIfNeeded];
        }];
    }else{
        [self removeSearchBar];
        [self loadSearchBar];
    }
    
    self.searchBarTextFiled.delegate=self;
}
- (void)loadSearchBar{
    
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(back)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"修改" TintColor:[UIColor blackColor] target:self action:@selector(changeAction)];
    
    UISearchBar *searchBarTextFiled=[[UISearchBar alloc]initWithFrame:CGRectMake(70, 0, self.view.width-70-70, 44)];
    
    self.searchBarTextFiled=searchBarTextFiled;
    self.searchBarTextFiled.contentMode=UIViewContentModeLeft;
    self.searchBarTextFiled.placeholder=@"搜索";
    [self.navigationController.navigationBar addSubview:searchBarTextFiled];
    
}
- (void)removeSearchBar{
    [self.searchBarTextFiled resignFirstResponder];
    [self.searchBarTextFiled removeFromSuperview];
    
    self.searchBarTextFiled=nil;
}
- (void)back{
    [self removeSearchBar];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)changeAction{
    NSMutableArray *arrM=[NSMutableArray array];
    for (SearchChangeFileCellModel *model in self.dataArr) {
        if (model.isSelect) {
            [arrM addObject:model.title];
        }
    }
    
    NSMutableArray *paths=[NSMutableArray array];
    for (NSString *filePath in self.dataBase) {
        if ([arrM containsObject:[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath]]) {
            [paths addObject:filePath];
        }
    }
    if (paths.count==0) {
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
        
        hud.label.text = @"请选中文件再修改";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        return;
    }
    NSString *jsonString=[ZHChangeCodeFileName getOldNameAndSetStringByPathArr:paths];
    
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];
    [jsonString writeToFile:macDesktopPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [ZHAlertAction alertWithTitle:@"请修改文件名称" withMsg:@"文件已经生成在桌面,名字为\"代码助手.m\",请填写具体内容" addToViewController:self withCancleBlock:nil withOkBlock:^{
        [self changeFile];
    } cancelButtonTitle:@"取消" OkButtonTitle:@"已填写完内容,开始修改" ActionSheet:NO];
}

- (void)changeFile{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:self.view animated:YES];
    
    if (self.filePath.length<=0) {
        hud.label.text = @"路径为空!";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        return;
    }
    hud.label.text = [NSString stringWithFormat:@"正在备份(%@)...",[ZHFileManager fileSizeString:self.filePath]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //备份工程
        //有后缀的文件名
        NSString *tempFileName=[ZHFileManager getFileNameFromFilePath:self.filePath];
        
        //无后缀的文件名
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:self.filePath];
        
        //获取无文件名的路径
        NSString *newFilePath=[self.filePath stringByReplacingOccurrencesOfString:tempFileName withString:@""];
        //拿到新的有后缀的文件名
        tempFileName=[tempFileName stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@备份",fileName]];
        
        newFilePath = [newFilePath stringByAppendingPathComponent:tempFileName];
        
        if([ZHFileManager fileExistsAtPath:newFilePath]){
            [ZHFileManager removeItemAtPath:newFilePath];
        }
        
        BOOL result=[ZHFileManager copyItemAtPath:self.filePath toPath:newFilePath];
        
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"备份成功,正在修改...";
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text = @"备份失败!请先关闭工程(XCode)";
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
            return ;
        }
        
        // 处理耗时操作的代码块...
        NSString *resultString=[ZHChangeCodeFileName changeMultipleCodeFileName:self.filePath];
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultString.length>0) {
                hud.label.text = resultString;
            }else
                hud.label.text = @"修改完成";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        });
    });
}

- (BOOL)exsitTargetString:(NSString *)targetString inText:(NSString *)text{
    targetString=[targetString lowercaseString];
    text=[text lowercaseString];
    unichar ch1,ch2;
    
    while (text.length>0&&targetString.length>0) {
        ch1=[text characterAtIndex:0];
        ch2=[targetString characterAtIndex:0];
        if (ch1==ch2) {
            text=[text substringFromIndex:1];
            targetString=[targetString substringFromIndex:1];
        }else{
            text=[text substringFromIndex:1];
        }
        
        if (targetString.length==0) {
            return YES;
        }
        if (text.length==0) {
            return NO;
        }
    }
    return NO;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.searchDataArr removeAllObjects];
    //搜索条输入文字修改时触发
    if(searchText.length>0)
    {
        for (SearchChangeFileCellModel *model in self.dataArr) {
            if ([self exsitTargetString:searchText inText:model.title]) {
                model.searchText=searchText;
                [self.searchDataArr addObject:model];
            }
        }
        [self.tableView reloadData];
    }else{
        for (SearchChangeFileCellModel *model in self.dataArr) {
            model.searchText=@"";
        }
        [self.searchDataArr addObjectsFromArray:self.dataArr];
        [self.tableView reloadData];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.tableView]) {
        [self.searchBarTextFiled endEditing:YES];
    }
}

#pragma mark - TableViewDelegate实现的方法:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.searchDataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	id modelObjct=self.searchDataArr[indexPath.row];
	if ([modelObjct isKindOfClass:[SearchChangeFileCellModel class]]){
		SearchChangeFileTableViewCell *searchChangeFileCell=[tableView dequeueReusableCellWithIdentifier:@"SearchChangeFileTableViewCell"];
		SearchChangeFileCellModel *model=modelObjct;
		[searchChangeFileCell refreshUI:model];
		return searchChangeFileCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 50.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
