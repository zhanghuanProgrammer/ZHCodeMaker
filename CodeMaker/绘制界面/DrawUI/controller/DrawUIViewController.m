#import "DrawUIViewController.h"
#import "DrawBoard.h"
#import "Custombutton.h"
#import "DrawViewModel.h"
#import "ZHDrawSubViewHelp.h"
#import "SCLazyView.h"
#import "ExportTemplate.h"
#import "DrawViewConstarint.h"
#import "UIColor+Tools.h"
#import "UIColor+YYAdd.h"
#import "NSObject+YYModel.h"
#import "DrawViewParameterTool.h"
#import "DrawViewSaveModel.h"
#import "Masonry.h"

typedef NS_ENUM(NSUInteger, DrawViewType) {
    DrawViewTypeNone = 0,
    DrawViewTypeFont,
    DrawViewTypeText,
    DrawViewTypeBackcolor,
    DrawViewTypeTextColor,
    DrawViewTypeRecommend,
};

@interface DrawUIViewController ()<UITextFieldDelegate>
@property (nonatomic,assign)BOOL isEdit;
@property (nonatomic,assign)BOOL isSave;
@property (nonatomic,strong)DrawBoard *drawBoard;
@property (nonatomic,assign)NSInteger tagIndex;
@property (nonatomic,strong)UITextField *commandTextField;
@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)UITextView *recommendTextView;
@property (nonatomic,strong)NSMutableDictionary *constarintOperation;
@property (nonatomic,assign)DrawViewType editType;
@end

@implementation DrawUIViewController

void errorString(NSString *error){
    [JohnAlertManager showAlertWithType:JohnTopAlertTypeError title:error];
}

- (void)setIsEdit:(BOOL)isEdit{
    _isEdit=isEdit;
    if (isEdit) {
        self.drawBoard.hidden=YES;
        self.drawBoard.customBtn.hidden=YES;
        [TabBarAndNavagation setRightBarButtonItemTitle:@"绘制" TintColor:[UIColor blackColor] target:self action:@selector(editAction)];
        if([self.view isKindOfClass:[SCLazyView class]]){
            [(SCLazyView *)self.view actived];
        }
        [self.commandTextField becomeFirstResponder];
    }else{
        self.drawBoard.hidden=NO;
        self.drawBoard.customBtn.hidden=NO;
        [TabBarAndNavagation setRightBarButtonItemTitle:@"编辑" TintColor:[UIColor blackColor] target:self action:@selector(editAction)];
        self.textView.hidden = YES;
        self.recommendTextView.hidden = YES;
        if([self.view isKindOfClass:[SCLazyView class]]){
            [(SCLazyView *)self.view unActived];
        }
        [self.commandTextField becomeFirstResponder];
    }
}

- (NSMutableArray *)drawViews{
    return _drawViews ?: (_drawViews = [[NSMutableArray alloc] init]);
}
- (NSMutableArray *)selectViews{
    return _selectViews ?: (_selectViews = [[NSMutableArray alloc] init]);
}

- (NSMutableDictionary *)constarintOperation{
    return _constarintOperation ?: (_constarintOperation = [[NSMutableDictionary alloc] init]);
}
- (DrawViewModel *)selectModel{
    if (self.selectView) {
        for (DrawViewModel *model in self.drawViews) {
            if ([model.relateView isEqual:self.selectView]) {
                return model;
            }
        }
    }
    return nil;
}
- (void)cancleAllSelect{
    for (UIView *view in self.selectViews){
        if (view != self.selectView){
            [view cornerRadiusWithFloat:0 borderColor:[UIColor clearColor] borderWidth:0];
        }
    }
    if (self.selectView) {
        [((SCLazyView *)self.view) tapSelectSubView:self.selectView];
        self.selectView = nil;
    }
    [self.selectViews removeAllObjects];
}

- (void)setEditType:(DrawViewType)editType{
    _editType = editType;
    switch (editType) {
        case DrawViewTypeNone:
            self.title = @"绘制";
            break;
        case DrawViewTypeFont:
            self.title = @"set - Font";
            break;
        case DrawViewTypeText:
            self.title = @"set - Text";
            break;
        case DrawViewTypeBackcolor:
            self.title = @"set - Backcolor";
            break;
        case DrawViewTypeTextColor:
            self.title = @"set - TextColor";
            break;
        case DrawViewTypeRecommend:
            self.title = @"set - Recommend";
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绘制";
    [self addBlocks];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.view=[[SCLazyView alloc]initWithFrame:self.view.bounds];
    if([self.view isKindOfClass:[SCLazyView class]]){
        ((SCLazyView *)self.view).viewController=self;
        ((SCLazyView *)self.view).models=self.drawViews;
        ((SCLazyView *)self.view).constarintOperation=self.constarintOperation;
    }
    
    DrawBoard *drawBoard = [[DrawBoard alloc]initWithFrame:self.view.bounds];
    drawBoard.vc=self;
    self.drawBoard=drawBoard;
    drawBoard.backgroundColor=[UIColor clearColor];
    [self.view addSubview:drawBoard];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setNav];
    self.isEdit=NO;
    self.tagIndex=0;
    
    UITextField *textFiled =[[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    textFiled.delegate=self;
    textFiled.backgroundColor = [UIColor blackColor];
    textFiled.textColor=[UIColor whiteColor];
    self.commandTextField=textFiled;
    self.commandTextField.tag = 999;
    self.commandTextField.hidden= NO;
    [self.commandTextField becomeFirstResponder];
    self.commandTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commandTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.commandTextField];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 120, self.view.width/2.0, 120)];
    self.textView.textColor = [UIColor redColor];
    self.textView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:2];
    [self.view addSubview:self.textView];
    self.textView.hidden=YES;
    self.textView.tag=999;
    self.recommendTextView = [[UITextView alloc]initWithFrame:CGRectMake(self.view.width/2.0, 120, self.view.width/2.0, 120)];
    self.recommendTextView.textColor = [UIColor greenColor];
    self.recommendTextView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:2];
    [self.view addSubview:self.recommendTextView];
    self.recommendTextView.hidden=YES;
    self.recommendTextView.tag=999;
}

- (void)openHistroy{
    [TabBarAndNavagation pushViewController:@"DrawViewOpenHistroyViewController" toTarget:self pushHideTabBar:YES backShowTabBar:NO];
}

- (NSString *)recommendText{
    NSMutableString *recommendText = [NSMutableString string];
    NSInteger cur = 0;
    if (self.selectViews.count>1) {
        [recommendText appendString:@"推荐:\n1.上 2.下 3.左 4.右 5.宽 6.高\n7.对齐上 .8对齐下 9.对齐左 .10对齐右\n11.横对齐 12.竖对齐\n13.等宽 14.等高"];
        cur = 15;
    }else{
        [recommendText appendString:@"推荐:\n1.上 2.下 3.左 4.右 5.宽 6.高\n7.上下左右 8.上下左右(父控件)"];
        if (self.selectView) {
            NSArray *fatherViews = [[DrawViewParameterTool new] getFatherView:self.selectModel models:self.drawViews];
            cur = 9;
            for (DrawViewModel *model in fatherViews) {
                [recommendText appendFormat:@"\n%@.添加到view%@",@(cur++),@([self.drawViews indexOfObject:model]+1)];
            }
            NSArray *childViews = [[DrawViewParameterTool new] getChildView:self.selectModel models:self.drawViews];
            if (childViews.count>0) {
                NSMutableString *tempM = [NSMutableString string];
                for (DrawViewModel *model in childViews) {
                    [tempM appendFormat:@" %@",@([self.drawViews indexOfObject:model]+1)];
                }
                [recommendText appendFormat:@"\n%@.添加子view%@",@(cur++),tempM];
                [recommendText appendFormat:@"\n%@.均分子控件view%@",@(cur++),tempM];
            }
        }
    }
    return recommendText;
}

/**这一块功能暂时搁浅,主要是有点难搞,加上没时间,不要在约束上花太多时间*/
- (BOOL)selectRecommend:(NSInteger)index{
    switch (index) {
        case 1:{
            self.commandTextField.text = [NSString stringWithFormat:@"t %@",@([[DrawViewParameterTool new] getDirectViewDistance:self.selectModel models:self.drawViews direct:1])];
        }break;
        case 2:{
            self.commandTextField.text = [NSString stringWithFormat:@"b %@",@([[DrawViewParameterTool new] getDirectViewDistance:self.selectModel models:self.drawViews direct:3])];
        }break;
        case 3:{
            self.commandTextField.text = [NSString stringWithFormat:@"l %@",@([[DrawViewParameterTool new] getDirectViewDistance:self.selectModel models:self.drawViews direct:0])];
        }break;
        case 4:{
            self.commandTextField.text = [NSString stringWithFormat:@"r %@",@([[DrawViewParameterTool new] getDirectViewDistance:self.selectModel models:self.drawViews direct:2])];
        }break;
        case 5:{
            self.commandTextField.text = [NSString stringWithFormat:@"w %@",@((NSInteger)self.selectView.width)];
        }break;
        case 6:{
            self.commandTextField.text = [NSString stringWithFormat:@"h %@",@((NSInteger)self.selectView.height)];
        }break;
        case 7:{
            [self selectRecommend:1];[self runScrip];[self selectRecommend:2];[self runScrip];
            [self selectRecommend:3];[self runScrip];[self selectRecommend:4];[self runScrip];
            self.commandTextField.text = @"";
        }break;
        case 8:{
            self.commandTextField.text = @"-t 0";[self runScrip];
            self.commandTextField.text = @"-b 0";[self runScrip];
            self.commandTextField.text = @"-l 0";[self runScrip];
            self.commandTextField.text = @"-r 0";[self runScrip];
        }break;
        default:return NO;
    }
    [self selectEditText];
    return YES;
}

- (void)addBlocks{
    __weak typeof(self)weakSelf=self;
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        [weakSelf.commandTextField becomeFirstResponder];
    } WithIdentity:@"ShouldInputCommand"];
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        if (!weakSelf.isEdit) {
            return;
        }
        if (weakSelf.selectView) {
            DrawViewModel *model = [weakSelf getDrawViewModel:[NSString stringWithFormat:@"%p",weakSelf.selectView]];
            NSString *commandText = [model conmandText];
            commandText = [[NSString stringWithFormat:@"view%zd %p\n",[weakSelf.drawViews indexOfObject:model]+1,model.relateView] stringByAppendingString:commandText];
            weakSelf.textView.text = commandText;
            weakSelf.textView.hidden = !(weakSelf.textView.text.length>0);
            [weakSelf.view bringSubviewToFront:weakSelf.textView];
            weakSelf.recommendTextView.text = [self recommendText];
            weakSelf.recommendTextView.hidden = !(weakSelf.recommendTextView.text.length>0);
            [weakSelf.view bringSubviewToFront:weakSelf.recommendTextView];
            weakSelf.textView.y = weakSelf.selectView.centerY>weakSelf.view.height/2.0?(weakSelf.selectView.y-weakSelf.textView.height-10):(weakSelf.selectView.maxY+10);
            if (((SCLazyView *)weakSelf.view).shouldSetVaule) {
                CGFloat maxY = 0;
                for (DrawViewModel *model in weakSelf.drawViews) {
                    if(model.relateView.maxY>maxY)maxY = model.relateView.maxY;
                }
                if(maxY>weakSelf.view.height - weakSelf.textView.height - 10)maxY=weakSelf.view.height - weakSelf.textView.height - 10;
                weakSelf.textView.y = maxY + 10;
            }
            weakSelf.recommendTextView.y = weakSelf.textView.y;
        }else{
            weakSelf.textView.text = @"";
            weakSelf.textView.hidden = YES;
            weakSelf.recommendTextView.text = @"";
            weakSelf.recommendTextView.hidden = YES;
        }
    } WithIdentity:@"DrawViewSelectView"];
    [ZHBlockSingleCategroy addBlockWithNULL:^{
        [weakSelf openHistroy];
    } WithIdentity:@"DrawUIViewControllerOpenHistory"];
    [ZHBlockSingleCategroy addBlockWithNSArray:^(NSArray *Array) {
        [weakSelf openDrawViewModels:Array];
    } WithIdentity:@"DrawUIViewControllerOpenModels"];
}

- (void)setNav{
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"编辑" TintColor:[UIColor blackColor] target:self action:@selector(editAction)];
}

- (void)backAction{
    if (self.drawViews.count>0) {
        if (!self.isSave) {
            self.isSave=YES;
            [TabBarAndNavagation setLeftBarButtonItemTitle:@"<保存返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
            [self exportTemplate];
        }else{
//            [self exit];return;
            __weak typeof(self)weakSelf=self;
            [ZHAlertAction alertWithTitle:@"是否保存到历史记录" withMsg:@"可到历史记录中找到并且打开" addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
                [weakSelf exit];
                [DrawViewSaveModel saveDrawViewModels:self.drawViews snapView:self.view];
            },^{
                [weakSelf exit];
            }] otherButtonTitles:@[@"保存",@"取消"]];
        }
    }else{
        [self exit];
    }
}
- (void)exit{
    [self.navigationController popViewControllerAnimated:YES];
    [Custombutton removeAllFromKeyWindow];
}

- (void)exportTemplate{
    NSDictionary *parameter = [[DrawViewParameterTool new]parameterFromDrawViewModels:self.drawViews];
    [ZHAlertAction alertWithTitle:@"导出类型" withMsg:nil addToViewController:self ActionSheet:NO otherButtonBlocks:@[^{
        [ExportTemplate exportTemplateForStoryboardWithParameter:parameter fileName:@"ViewController"];
    },^{
        [ExportTemplate exportTemplateForStoryboardWithParameter:parameter fileName:@"TableViewCell"];
    },^{
        [ExportTemplate exportTemplateForStoryboardWithParameter:parameter fileName:@"CollectionViewCell"];
    }] otherButtonTitles:@[@"UIView",@"UITableViewCell",@"UICollectionViewCell"]];
}
- (void)editAction{
    self.isEdit=!self.isEdit;
    [self shouldSave];
}

- (DrawViewModel *)getDrawViewModel:(NSString *)viewIp{
    for (DrawViewModel *model in self.drawViews) if ([[NSString stringWithFormat:@"%p",model.relateView]isEqualToString:viewIp]) return model;
    return nil;
}
- (void)addView:(CGRect)frame type:(NSString *)viewType{
    DrawViewModel *model=[DrawViewModel new];
    model.categoryView=viewType;
    UIView *view=[ZHDrawSubViewHelp getViewWithFrame:frame withViewCategory:model.categoryView];
    view.tag=++self.tagIndex;
    model.relateView=view;
    model.frame = frame;
    model.relateVC = self;
    [view addShadowWithShadowOffset:CGSizeZero];
    [view addBlurEffectWithAlpha:0.1];
    [self.view addSubview:view];
    [self.view bringSubviewToFront:self.drawBoard];
    [self.drawViews addObject:model];
    [self shouldSave];
}

/**打开历史记录*/
- (void)openDrawViewModels:(NSArray *)models{
    for (DrawViewModel *model in self.drawViews) [model.relateView removeAllSubviews];
    [self.drawViews removeAllObjects];
    self.tagIndex = 0;
    for (DrawViewModel *model in models) {
        UIView *view=[ZHDrawSubViewHelp getViewWithFrame:model.frame withViewCategory:model.categoryView];
        view.tag=++self.tagIndex;
        model.relateView=view;
        model.relateVC = self;
        [view addShadowWithShadowOffset:CGSizeZero];
        [view addBlurEffectWithAlpha:0.1];
        [self.view addSubview:view];
        [self.view bringSubviewToFront:self.drawBoard];
        [self.drawViews addObject:model];
        [self shouldSave];
    }
    for (DrawViewModel *model in models) {
        [model reOpenViewIpAjust:models];
    }
}

- (void)removeView:(UIView *)view{
    for (NSInteger i=0; i<self.drawViews.count; i++) {
        DrawViewModel *model=self.drawViews[i];
        if ([model.relateView isEqual:view]) {
            [self.drawViews removeObject:model];
            break;
        }
    }
    for (DrawViewModel *model in self.drawViews) {
        [model deleteOverDataViewIp:self.drawViews relateViewIP:[NSString stringWithFormat:@"%p",view]];
    }
    [view removeFromSuperview];
    [self shouldSave];
}

- (void)shouldSave{
    if (self.drawViews.count>0) {
        self.isSave=NO;
        [TabBarAndNavagation setLeftBarButtonItemTitle:@"导出" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    }else{
        [TabBarAndNavagation setLeftBarButtonItemTitle:@"<保存返回" TintColor:[UIColor blackColor] target:self action:@selector(backAction)];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self selectAllText];
    [self runScripNormal];
    return YES;
}

- (void)selectAllText{
    UITextPosition *begin = self.commandTextField.beginningOfDocument;
    UITextPosition *end = [self.commandTextField positionFromPosition:begin offset:self.commandTextField.text.length];
    UITextRange *range = [self.commandTextField textRangeFromPosition:begin toPosition:end];
    self.commandTextField.selectedTextRange=range;
}

- (void)selectEditText{
    if (self.editType == DrawViewTypeRecommend &&
        [self.commandTextField.text rangeOfString:@" "].location!=NSNotFound) {
        NSInteger index = [self.commandTextField.text rangeOfString:@" "].location+1;
        UITextPosition *begin = [self.commandTextField positionFromPosition:self.commandTextField.beginningOfDocument offset:index];;
        UITextPosition *end = [self.commandTextField positionFromPosition:begin offset:self.commandTextField.text.length - index];
        UITextRange *range = [self.commandTextField textRangeFromPosition:begin toPosition:end];
        self.commandTextField.selectedTextRange=range;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.textColor=[UIColor whiteColor];
    return YES;
}

- (void)runScripNormal{
    if ([self runScripEditType]) {
        return;
    }
    if ([self runScripPublic]) {
        return;
    }
    if (!self.isEdit) {
        [self runScripHuiZhi];
        return;
    }
    [self runScrip];
}

- (void)runScrip{
    BOOL isSuccess = YES;
    static BOOL isInSuper = NO;
    if (self.constarintOperation.count>0) {
        //这里面是一个控件的top,left,right,bottom,两个控件的关联约束
        //执行约束,里面必须为数字,并且数字要以空格隔开,否则就报红
        if (self.constarintOperation.count==1) {
            NSArray *constarint =[self.constarintOperation allValues][0];
            DrawViewModel *model = [self getDrawViewModel:[self.constarintOperation allKeys][0]];
            NSArray *values = [self.commandTextField.text componentsSeparatedByString:@" "];
            if (values.count >= constarint.count) {
                for (NSInteger i=0; i<constarint.count; i++) {
                    NSString *value = values[i];
                    if ([ZHNSString isPureInt:value]||[ZHNSString isPureFloat:value]) {
                        DrawViewConstarint *constarintModel = [DrawViewConstarint new];
                        constarintModel.constant = value;
                        constarintModel.firstAttribute = constarint[i];
                        [model addOrUpdateCommand:constarintModel];
                    }else{
                        isSuccess = NO;
                        errorString(@"里面必须为数字,并且数字要以空格隔开,否则就报红");
                    }
                }
            }else{
                isSuccess = NO;
                errorString(@"里面必须为数字,并且数字个数要和选中的约束个数相等,否则就报红");
            }
        }else if(self.constarintOperation.count==2){
            NSInteger isLastControll = [((SCLazyView *)self.view).lastSelectControll isEqualToString:[self.constarintOperation allKeys][0]];
            NSArray *constarint1 =[self.constarintOperation allValues][!isLastControll];
            NSString *secondItem = [self.constarintOperation allKeys][!isLastControll];
            DrawViewModel *model1 = [self getDrawViewModel:secondItem];
            NSArray *constarint2 = [self.constarintOperation allValues][isLastControll];
            NSString *firstItem = [self.constarintOperation allKeys][isLastControll];
            DrawViewModel *model2 = [self getDrawViewModel:firstItem];
            NSString *value = self.commandTextField.text;
            if ([ZHNSString isPureInt:value]||[ZHNSString isPureFloat:value]) {
                DrawViewConstarint *constarintModel = [DrawViewConstarint new];
                constarintModel.constant = value;
                constarintModel.firstItem = firstItem;
                constarintModel.secondItem = secondItem;
                constarintModel.firstAttribute = constarint2[0];
                constarintModel.secondAttribute = constarint1[0];
                [model1 ifExsitRemove:constarintModel];
                [model2 addOrUpdateCommand:constarintModel];
            }else{
                errorString(@"里面必须为数字,并且数字只能有一个,否则就报红");
            }
        }else{
            isSuccess = NO;
            errorString(@"选中的约束相关的View个数不能超过两个,否则就报红");
        }
    }else if(self.selectView){
        //这里是选中一个UIView后的width,height,属性等添加和删除,UIView的嵌套关联
        DrawViewModel *model = [self getDrawViewModel:[NSString stringWithFormat:@"%p",self.selectView]];
        NSString *command = [[self.commandTextField.text stringByTrim] lowercaseString];
        if ([command hasPrefix:@"rm "]) {//删除 全部 或者 某一个
            NSString *subCommand = [command substringFromIndex:3];
            if ([subCommand hasPrefix:@"all"]) {
                [model.commands removeAllObjects];
            }else if([ZHNSString isPureInt:subCommand]){
                NSInteger index = [subCommand integerValue];
                index -- ; if(index < 0) index = 0;
                if(model.commands.count > index) [model.commands removeObjectAtIndex:index];
                else{isSuccess = NO; errorString(@"删除的下标越界了");}
            }else{
                isSuccess = NO;
                errorString(@"删除 只能是 rm all 或者 rv 整数字");
            }
        }else if ([ZHNSString isPureInt:command]){//选择第几个
            NSInteger index = [command integerValue];
            index -- ; if(index < 0) index = 0;
            if(model.commands.count > index){
                id obj = model.commands[index];
                if([obj isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dic = obj;
                    if([[dic allKeys][0] isEqualToString:@"inview"]){
                        self.commandTextField.text=[NSString stringWithFormat:@"%@ ?",[dic allKeys][0]];
                    }else{
                        self.commandTextField.text=[NSString stringWithFormat:@"%@ %@",[dic allKeys][0],[dic allValues][0]];
                    }
                }
                if([obj isKindOfClass:[DrawViewConstarint class]]){
                    DrawViewConstarint *model = obj;
                    self.commandTextField.text=[model selectDescription];
                    if (model.secondItem.length>0) [((SCLazyView *)self.view) reSelectControll:model];
                }
                return;
            }else{isSuccess = NO; errorString(@"选择的下标越界了");}
        }else if([command hasPrefix:@"cl "]||[command hasPrefix:@"textcl "]){//颜色属性
            BOOL isTextColor = [command hasPrefix:@"textcl "];
            NSString *subCommand = [command substringFromIndex:isTextColor?7:3];
            UIColor *color = nil;
            if ([subCommand hasPrefix:@"#"]) {
                if (subCommand.length==7) {
                    color = [UIColor colorWithHexString:subCommand];
                }else{
                    isSuccess = NO;
                    errorString(@"颜色如果是十六进制,请输入正确的格式");
                }
            }else{
                NSArray *values = [subCommand componentsSeparatedByString:@" "];
                BOOL isColor = YES;
                if (values.count >= 3) {
                    for (NSInteger i=0; i<values.count; i++) {
                        NSString *value = values[i];
                        if (![ZHNSString isPureInt:value]) {
                            isColor = NO;
                            break;
                        }
                    }
                }else isColor = NO;
                if (!isColor) {
                    errorString(@"颜色里面如果是数字就必须为三个数字或以上,并且数字要以空格隔开,否则就报红");
                }else{
                    color =values.count==3? RGB([values[0] integerValue], [values[1] integerValue], [values[2] integerValue]):
                    RGBA([values[0] integerValue], [values[1] integerValue], [values[2] integerValue], [values[3] integerValue]);
                }
            }
            if (color) {
                [model addOrUpdateCommand:@{(isTextColor?@"textColorRed":@"bgColorRed"):[NSString stringWithFormat:@"%.01f",255*[color red]]}];
                [model addOrUpdateCommand:@{(isTextColor?@"textColorGreen":@"bgColorGreen"):[NSString stringWithFormat:@"%.01f",255*[color green]]}];
                [model addOrUpdateCommand:@{(isTextColor?@"textColorBlue":@"bgColorBlue"):[NSString stringWithFormat:@"%.01f",255*[color blue]]}];
                [model addOrUpdateCommand:@{(isTextColor?@"textColorAlpha":@"bgColorAlpha"):[NSString stringWithFormat:@"%.01f",255*[color alpha]]}];
            }
        }else if([command hasPrefix:@"text "]){//文本属性
            [model addOrUpdateCommand:@{@"text":[command substringFromIndex:@"text ".length]}];
        }else if([command hasPrefix:@"line "]){//行数属性
            NSString *subCommand = [command substringFromIndex:@"line ".length];
            if([ZHNSString isPureInt:subCommand]||[ZHNSString isPureFloat:subCommand]){
                [model addOrUpdateCommand:@{@"line":subCommand}];
            }else{ isSuccess = NO;errorString(@"line后面必须为整数或者小数"); }
        }else if([command hasPrefix:@"align "]){//文本对齐属性
            NSString *subCommand = [command substringFromIndex:@"align ".length];
            NSString *align = @"";
            if([subCommand hasPrefix:@"d"])align=@"default";
            if([subCommand hasPrefix:@"l"])align=@"left";
            if([subCommand hasPrefix:@"r"])align=@"right";
            if([subCommand hasPrefix:@"c"])align=@"center";
            if (align.length>0) {
                [model addOrUpdateCommand:@{@"align":align}];
            }else{
                isSuccess = NO;errorString(@"align 对齐方式不明 建议为 d,l,r,c");
            }
        }else if([command hasPrefix:@"inview "]){//在某个view里面
            NSString *subCommand = [command substringFromIndex:@"inview ".length];
            if([ZHNSString isPureInt:subCommand]){
                NSInteger index = [subCommand integerValue];
                index -- ; if(index < 0) index = 0;
                if(self.drawViews.count > index) {
                    DrawViewModel *target = self.drawViews[index];
                    [model addOrUpdateCommand:@{@"inview":[NSString stringWithFormat:@"%p",target.relateView]}];
                }
                else{isSuccess = NO; errorString(@"addSubView的下标越界了");}
            }else{
                isSuccess = NO;
                errorString(@"如果想让这个view嵌套在某个父View中,请输入正确父View下标");
            }
        }else if([command hasPrefix:@"-"]){//在父控件里面的上下左右
            isInSuper = YES;
            self.commandTextField.text = [self.commandTextField.text substringFromIndex:1];
            [self runScrip];
            return;
        }else if([command hasPrefix:@"t "]||[command hasPrefix:@"l "]||[command hasPrefix:@"r "]||[command hasPrefix:@"b "]||[command hasPrefix:@"w "]||[command hasPrefix:@"h "]||[command hasPrefix:@"cx "]||[command hasPrefix:@"cy "]){//top,left,right,bottom,width,height约束
            NSString *subCommand = [command substringFromIndex:[command rangeOfString:@" "].location+1];
            if([ZHNSString isPureInt:subCommand]||[ZHNSString isPureFloat:subCommand]){
                NSString *firstAttribute = @"";
                if([command hasPrefix:@"t "])firstAttribute=@"top";
                if([command hasPrefix:@"l "])firstAttribute=@"left";
                if([command hasPrefix:@"r "])firstAttribute=@"right";
                if([command hasPrefix:@"b "])firstAttribute=@"bottom";
                if([command hasPrefix:@"w "])firstAttribute=@"width";
                if([command hasPrefix:@"h "])firstAttribute=@"height";
                if([command hasPrefix:@"cx "])firstAttribute=@"centerX";
                if([command hasPrefix:@"cy "])firstAttribute=@"centerY";
                DrawViewConstarint *constarintModel = [DrawViewConstarint new];
                constarintModel.constant = subCommand;
                constarintModel.firstAttribute = isInSuper? [@"-" stringByAppendingString:firstAttribute]:firstAttribute;
                if(isInSuper && ([command hasPrefix:@"w "]||[command hasPrefix:@"h "]||[command hasPrefix:@"cx "]||[command hasPrefix:@"cy "]))firstAttribute=[firstAttribute substringFromIndex:1];
                [model addOrUpdateCommand:constarintModel];
            }else{
                isSuccess = NO;
                errorString(@"约束后面必须为整数或者小数");
            }
        }else if([command hasPrefix:@"w="]||[command hasPrefix:@"h="]||[command hasPrefix:@"cx="]||[command hasPrefix:@"cy="]){//与其它view宽和高相等,垂直对齐,水平对齐
            NSString *subCommand = [[command substringFromIndex:[command rangeOfString:@"="].location+1] stringByTrim];
            NSArray *values = [subCommand componentsSeparatedByString:@" "];
            NSString *firstAttribute = @"",*secondItem=@"";
            if (values.count>=2) {
                NSString *value1=values[0],*value2=values[1];
                NSInteger index = [value1 integerValue]-1;
                if(index <0)index=0;
                if (index<self.drawViews.count) {
                    DrawViewModel *target = self.drawViews[index];
                    if (target!=model) {
                        secondItem = [NSString stringWithFormat:@"%p",target.relateView];
                        if([ZHNSString isPureInt:value1]&&([ZHNSString isPureInt:value2]||[ZHNSString isPureFloat:value2])){
                            if([command hasPrefix:@"w="]){firstAttribute=@"width";}
                            if([command hasPrefix:@"h="]){firstAttribute=@"height";}
                            if([command hasPrefix:@"cx="]){firstAttribute=@"centerX";}
                            if([command hasPrefix:@"cy="]){firstAttribute=@"centerY";}
                            DrawViewConstarint *constarintModel = [DrawViewConstarint new];
                            constarintModel.constant = value2;
                            constarintModel.secondItem = secondItem;
                            constarintModel.secondAttribute = firstAttribute;
                            constarintModel.firstAttribute = firstAttribute;
                            [model addOrUpdateCommand:constarintModel];
                        }else{ isSuccess = NO; errorString(@"与其它view宽和高相等,垂直对齐,水平对齐 后面必须为两个数,第一个为整数,代表view标志,第二个代表constant");}
                    }else{ isSuccess = NO; errorString(@"不能与view自己宽和高相等,垂直对齐,水平对齐");}
                }else{ isSuccess = NO; errorString(@"对齐的view的下标越界");}
            }else{ isSuccess = NO; errorString(@"与其它view宽和高相等,垂直对齐,水平对齐 后面必须为两个数,第一个为整数,代表view标志,第二个代表constant");}
        }else if([command hasPrefix:@"wh "]){//自身宽高等比
            NSString *subCommand = [command substringFromIndex:@"wh ".length];
            if ([ZHNSString contain:@":" inText:subCommand]) {
                NSArray *values = [subCommand componentsSeparatedByString:@":"];
                if (values.count>=2) {//选择某个命令,可以进行更改
                    NSString *value1=values[0],*value2=values[1];
                    if([ZHNSString isPureInt:value1]&&[ZHNSString isPureInt:value2]){
                        DrawViewConstarint *constarintModel = [DrawViewConstarint new];
                        constarintModel.constant = subCommand;
                        constarintModel.firstAttribute = @"ratio";
                        [model addOrUpdateCommand:constarintModel];
                    }else{ isSuccess = NO; errorString(@"wh 后面必须为整数比例 例如1:2");}
                }
            }else{ isSuccess = NO; errorString(@"wh 后面必须为比例 例如1:2");}
        }else if([command hasPrefix:@"font "]){//字体大小
            NSString *subCommand = [command substringFromIndex:@"font ".length];
            if([ZHNSString isPureInt:subCommand]||[ZHNSString isPureFloat:subCommand]){
                [model addOrUpdateCommand:@{@"font":subCommand}];
            }else{ isSuccess = NO; errorString(@"font后面必须为整数或者小数");}
        }else{
            NSArray *values = [self.commandTextField.text componentsSeparatedByString:@" "];
            if (values.count>=2) {//选择某个命令,可以进行更改
                NSString *result = [model changeKeyValueCommand:@{values[0]:values[1]}];
                if (result.length>0) {
                    isSuccess = NO;
                    errorString(result);
                }
            }else{
                isSuccess = NO;
                errorString(@"不识别指令");
            }
        }
    }else{
        NSString *command = [[self.commandTextField.text stringByTrim] lowercaseString];
        if ([command hasPrefix:@"help"]) {
            self.textView.text = @"使用帮助:\n\
            1.进入编辑界面,会默认激活输入框,该输入框可执短命令\n\
            2.每个控件有9个控制点,中间的控制点点击两次删除,四个角可以调控控件的大小,拖动控件本身可以移动控件本身的位置,边上的4个控制点用于添加约束\n\
            3.控制点添加约束的规则,如果要设置某个控件的上下左右的间距,那么直接选中控件,然后选中4个边上的控制点,在命令框中写入4个数字,空格隔开,按enter键就可以添加了,如果要设置两个控件的关联约束,分别选中两个控件上的某个控制点,只能选中一个,然后在命令框中写入1个数字,按enter键就可以添加了\n\
            4.选择某个控件,输入 t 10 或者 l 10 或者 r 10 或者 b 10 或者 w 10 或者 h 10 是代表上下左右和宽高的约束,如果已经有了,会替换和更新,如果在前面加-,那么代表在相对父类,优先级大 -t 10 或者 -l 10 或者 -r 10 或者 -b 10 ,cx 0,代表centerX ,cy 0代表centerY\n\
            5.如果不想要某个命令,直接选中控件,然后会列出所有命令,rm all代表删除所有,rm 2代表删除第二个\n\
            6.选择某个控件,会列出所有命令,直接输入下标数字,会将命令直接显示在命令框里,这个时候,只需要修改值就可以改变了,如果命令是通过控制点添加的约束,那么选中该命令,控制点会自动选中,只需要修改值就OK了\n\
            7.选择某个控件,cl #ff00ff 或者 cl 234 235 236都是代表修改背景颜色 textcl #ff00ff 或者 cl 234 235 236都是代表修改字体颜色\n\
            8.选择某个控件,text 一串文本 代表为为控件设置text ,line 2 代表为为控件设置text行数 align c 或者 align d 或者 align l 或者 align r 设置字体对齐模式 font 14 设置字体大小\n\
            9.选中某个控件,inview 另外一个view的下标,代表这个控件是另外一个控件的子控件\n\
            10.选中某个控件,wh 1:2 代表自身宽度和高度的比例\n\
            11.与其它view宽和高相等,垂直对齐,水平对齐 w= ,h= ,cx= ,cy= ,(后面必须为两个数,第一个为整数,代表view标志,第二个代表constant),例如w= 1 1意识是宽度比下标为1的view的宽度大1";
            self.textView.hidden=NO;
            [self.view bringSubviewToFront:self.textView];
            self.textView.centerY = self.view.height/2.0;
            return;
        }else{
            isSuccess = NO;
            errorString(@"既没有选中的约束也没有选中的View,否则就报红");
        }
    }
    if (isSuccess) {
        self.commandTextField.textColor=[UIColor greenColor];
        [self.constarintOperation removeAllObjects];
        [((SCLazyView *)self.view) runCommandSuccess];
        [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
    }else{
        self.commandTextField.textColor=[UIColor redColor];
    }
    isInSuper = NO;
}

- (BOOL)runScripPublic{
    NSString *commandTemp = [[self.commandTextField.text stringByTrim] lowercaseString];
    if (self.isEdit) {
        BOOL isChangeType = NO;
        if ([commandTemp isEqualToString:@"e"]) {
            self.editType = DrawViewTypeNone;
            isChangeType = YES;
        }
        if ([commandTemp isEqualToString:@"ef"]) {
            self.editType = DrawViewTypeFont;
            isChangeType = YES;
        }
        if ([commandTemp isEqualToString:@"et"]) {
            self.editType = DrawViewTypeText;
            isChangeType = YES;
        }
        if ([commandTemp isEqualToString:@"eb"]) {
            self.editType = DrawViewTypeBackcolor;
            isChangeType = YES;
        }
        if ([commandTemp isEqualToString:@"ec"]) {
            self.editType = DrawViewTypeTextColor;
            isChangeType = YES;
        }
        if ([commandTemp isEqualToString:@"er"]) {
            self.editType = DrawViewTypeRecommend;
            isChangeType = YES;
        }
        if (isChangeType) {
            self.commandTextField.text = @"";
            return YES;
        }
    }
    if ([commandTemp isEqualToString:@"c"]) {
        if (!self.isEdit) {
            [self.drawBoard cancelClick];
        }else{
            [self cancleAllSelect];
        }
        self.commandTextField.text = @"";
        return YES;
    }
    if (self.drawBoard.onDraw&&!self.isEdit) {
        [self.drawBoard CustombuttonTap];
        return YES;
    }
    if(commandTemp.length<=0){
        if (!self.selectView && self.drawViews.count>0) {
            DrawViewModel *model = [self.drawViews firstObject];
            [(SCLazyView *)self.view tapSelectSubView:model.relateView];
            return YES;
        }
        if (!self.selectView)return YES;
        DrawViewModel *model = [self getDrawViewModel:[NSString stringWithFormat:@"%p",self.selectView]];
        NSInteger index = [self.drawViews indexOfObject:model];
        index++;
        if(self.drawViews.count<=index)index=0;
        model = self.drawViews[index];
        [(SCLazyView *)self.view tapSelectSubView:model.relateView];
        return YES;
    }
    if ([commandTemp isEqualToString:@"q"]) {
        self.isEdit=!self.isEdit;
        self.commandTextField.text = @"";
        return YES;
    }
    if ([commandTemp isEqualToString:@"z"]) {
        if (self.drawViews.count>0) {
            DrawViewModel *model = [self.drawViews lastObject];
            [(SCLazyView *)self.view tapSelectSubView:model.relateView];
        }
        if (self.selectView) {
            [self removeView:self.selectView];
            self.selectView = nil;
        }
        self.commandTextField.text = @"";
        return YES;
    }
    if ([commandTemp isEqualToString:@"w"]) {
        if (self.selectView) {
            DrawViewModel *w = [[DrawViewParameterTool new] getDirectView:[self selectModel] models:self.drawViews direct:1];
            if (w){[self cancleAllSelect];[((SCLazyView *)self.view) tapSelectSubView:w.relateView];}
        }
        self.commandTextField.text = @"";
        return YES;
    }
    if ([commandTemp isEqualToString:@"s"]) {
        if (self.selectView) {
            DrawViewModel *w = [[DrawViewParameterTool new] getDirectView:[self selectModel] models:self.drawViews direct:3];
            if (w){[self cancleAllSelect];[((SCLazyView *)self.view) tapSelectSubView:w.relateView];}
        }
        self.commandTextField.text = @"";
        return YES;
    }
    if ([commandTemp isEqualToString:@"a"]) {
        if (self.selectView) {
            DrawViewModel *w = [[DrawViewParameterTool new] getDirectView:[self selectModel] models:self.drawViews direct:0];
            if (w){[self cancleAllSelect];[((SCLazyView *)self.view) tapSelectSubView:w.relateView];}
        }
        self.commandTextField.text = @"";
        return YES;
    }
    if ([commandTemp isEqualToString:@"d"]) {
        if (self.selectView) {
            DrawViewModel *w = [[DrawViewParameterTool new] getDirectView:[self selectModel] models:self.drawViews direct:2];
            if (w){[self cancleAllSelect];[((SCLazyView *)self.view) tapSelectSubView:w.relateView];}
        }
        self.commandTextField.text = @"";
        return YES;
    }
    
    if ([commandTemp isEqualToString:@"r"]) {
        if (self.selectView) {
            [self removeView:self.selectView];
            self.selectView = nil;
            self.commandTextField.text = @"";
        }
        return YES;
    }
    if ([commandTemp isEqualToString:@"h"]) {
        if (self.isEdit) {
            ((SCLazyView *)self.view).shouldSetVaule = !((SCLazyView *)self.view).shouldSetVaule;
        }
        self.commandTextField.text = @"";
        return YES;
    }
    if ([commandTemp isEqualToString:@"m"]) {
        if (self.isEdit) {
            for (UIView *controller in ((SCLazyView *)self.view).controllers){
                if ([controller.mas_key isEqualToString:@"controller4"]) {
                    controller.hidden = !controller.hidden;
                }
            }
        }
        self.commandTextField.text = @"";
        return YES;
    }
    return NO;
}

- (void)runScripHuiZhi{
    if (self.selectView) {
        NSString *commandTemp = [[self.commandTextField.text stringByTrim] lowercaseString];
        if ([commandTemp rangeOfString:@" "].location!=NSNotFound) {
            commandTemp = [ZHNSString removeSpacePrefix:commandTemp];
            commandTemp = [ZHNSString removeSpaceSuffix:commandTemp];
            NSArray *arr = [commandTemp componentsSeparatedByString:@" "];
            if (arr.count>=2) {
                NSString *w_string = arr[0];
                NSString *h_string = arr[1];
                if (w_string.length > 0 && h_string.length >0) {
                    if (([ZHNSString isPureInt:w_string]||[ZHNSString isPureFloat:w_string])&&
                        ([ZHNSString isPureInt:h_string]||[ZHNSString isPureFloat:h_string])) {
                        CGFloat w = [w_string floatValue];
                        CGFloat h = [h_string floatValue];
                        if (w>0) self.selectView.width = w;
                        if (h>0) self.selectView.width = h;
                        return;
                    }
                }
            }
        }
        if ([commandTemp hasPrefix:@"x "]||[commandTemp hasPrefix:@"y "]||[commandTemp hasPrefix:@"w "]||[commandTemp hasPrefix:@"h "]) {
            NSInteger type = 0;
            if([commandTemp hasPrefix:@"x "])type = 1;
            if([commandTemp hasPrefix:@"y "])type = 2;
            if([commandTemp hasPrefix:@"w "])type = 3;
            if([commandTemp hasPrefix:@"h "])type = 4;
            commandTemp = [commandTemp substringFromIndex:2];
            if (commandTemp.length>0 && [ZHNSString isPureInt:commandTemp]) {
                NSInteger commandInt = [commandTemp integerValue];
                if (self.selectView) {
                    if (type==1) self.selectView.x = commandInt;
                    if (type==2) self.selectView.y = commandInt;
                    if (type==3) self.selectView.width = commandInt;
                    if (type==4) self.selectView.height = commandInt;
                    return;
                }
            }
        }
    }
    errorString(@"不识别指令");
}

- (BOOL)runScripEditType{
    if (self.editType!=0 && self.selectView) {
        DrawViewModel *model = [self getDrawViewModel:[NSString stringWithFormat:@"%p",self.selectView]];
        NSString *command = [[self.commandTextField.text stringByTrim] lowercaseString];
        switch (self.editType) {
            case DrawViewTypeFont:
                if([ZHNSString isPureInt:command]||[ZHNSString isPureFloat:command]){
                    [model addOrUpdateCommand:@{@"font":command}];
                    self.commandTextField.text = @"";
                    [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
                }else{errorString(@"font(字体) 必须为整数或者小数");}
                return YES;
                break;
            case DrawViewTypeText:
                [model addOrUpdateCommand:@{@"text":command}];
                self.commandTextField.text = @"";
                [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
                return YES;
                break;
            case DrawViewTypeBackcolor:{
                UIColor *color = [self getColorFromCommand:command];
                if (color) {
                    [model addOrUpdateCommand:@{@"bgColorRed":[NSString stringWithFormat:@"%.01f",255*[color red]]}];
                    [model addOrUpdateCommand:@{@"bgColorGreen":[NSString stringWithFormat:@"%.01f",255*[color green]]}];
                    [model addOrUpdateCommand:@{@"bgColorBlue":[NSString stringWithFormat:@"%.01f",255*[color blue]]}];
                    [model addOrUpdateCommand:@{@"bgColorAlpha":[NSString stringWithFormat:@"%.01f",255*[color alpha]]}];
                }
                [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
                return YES;
            }break;
            case DrawViewTypeTextColor:{
                UIColor *color = [self getColorFromCommand:command];
                if (color) {
                    [model addOrUpdateCommand:@{@"textColorRed":[NSString stringWithFormat:@"%.01f",255*[color red]]}];
                    [model addOrUpdateCommand:@{@"bgColorGreen":[NSString stringWithFormat:@"%.01f",255*[color green]]}];
                    [model addOrUpdateCommand:@{@"bgColorBlue":[NSString stringWithFormat:@"%.01f",255*[color blue]]}];
                    [model addOrUpdateCommand:@{@"bgColorAlpha":[NSString stringWithFormat:@"%.01f",255*[color alpha]]}];
                }
                [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
                return YES;
            }break;
            case DrawViewTypeRecommend:{
                if ([ZHNSString isPureInt:command]){//选择第几个
                    NSInteger index = [command integerValue];
                    if(index < 0) index = 0;
                    if (![self selectRecommend:index]) {
                        errorString(@"选择的下标越界了");
                    }
                    [ZHBlockSingleCategroy runBlockNULLIdentity:@"DrawViewSelectView"];
                    return YES;
                }
            }break;
            default:break;
        }
    }
    return NO;
}

- (UIColor *)getColorFromCommand:(NSString *)command{
    UIColor *color = nil;
    if ([command hasPrefix:@"#"]) {
        if (command.length==7) {
            color = [UIColor colorWithHexString:command];
        }else{
            errorString(@"颜色如果是十六进制,请输入正确的格式");
        }
    }else{
        NSArray *values = [command componentsSeparatedByString:@" "];
        BOOL isColor = YES;
        if (values.count >= 3) {
            for (NSInteger i=0; i<values.count; i++) {
                NSString *value = values[i];
                if (![ZHNSString isPureInt:value]) {
                    isColor = NO;
                    break;
                }
            }
        }else isColor = NO;
        if (!isColor) {
            errorString(@"颜色里面如果是数字就必须为三个数字或以上,并且数字要以空格隔开,否则就报红");
        }else{
            color =values.count==3? RGB([values[0] integerValue], [values[1] integerValue], [values[2] integerValue]):
            RGBA([values[0] integerValue], [values[1] integerValue], [values[2] integerValue], [values[3] integerValue]);
        }
    }
    return color;
}

@end
