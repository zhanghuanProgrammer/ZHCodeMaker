#import "DetailViewController.h"

#import "DetailStepTableViewCell.h"
#import "DetailContentTableViewCell.h"

@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation DetailViewController
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
	}
	return _dataArr;
}

/**StroyBoard生成Masonry简介*/
- (void)StroyBoard_Masonry{
    NSArray *details=@[@"将 StroyBoard 放在您的MAC电脑的桌面上",
                       @"返回模拟器,就会看到您刚刚放的文件",
                       @"点击右边的生成代码到桌面",
                       @"桌面上会生成一个以当前时间命名的文件夹,里面就是您要的代码",
                       @"如果找不到Main.StroyBoard,可以使用该工程文件的Main.StroyBoard测试",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢(点击右上角视频链接)"
                       ];
    
    [self addData:details];
}

/**Xib生成Masonry简介*/
- (void)Xib_Masonry{
    NSArray *details=@[@"将 Xib 文件放在您的MAC电脑的桌面上",
                       @"返回模拟器,就会看到您刚刚放的文件",
                       @"点击右边的生成代码到桌面",
                       @"桌面上会生成一个以当前时间命名的文件夹,里面就是您要的代码",
                       @"如果您的Xib文件里面有ViewController,或者说您的Xib内容复杂(相当于几个xib文件合成一个,用下标取其对应对象),那么还会生成新的对应的文件夹,里面存放的是对应的代码",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**快速生成代码简介*/
- (void)QuickCreatCode{
    NSArray *details=@[@"我们基本上每一个界面都会有tableView或者collectionView",
                       @"我们添加它们时都发现很有规律,很无聊,尤其是写代理方法",
                       @"这个快速生成代码是您只需要填写少部分信息,就能根据您的这些信息帮您生成重复代码",
                       @"其实最麻烦的就是 代码助手.m文件里的格式怎么填,注意,这个文件的数据格式是Json,所以请不要打乱格式",
                       @"示例1:简单tableView",
                       @"{\n\
                       \"最大文件夹名字\":\"CocoaChina(随便给)\",\n\
                       \"ViewController的名字\":\"Set\",\n\
                       \"自定义Cell,以逗号隔开\":\"Set1,Set2,Set3\",\n\
                       \"是否需要对应的Model 1:0 (不填写么默认为否)\":\"1\",\n\
                       \"是否需要对应的StroyBoard 1:0 (不填写么默认为否)\":\"1\",\n\
                       \"自定义cell可编辑(删除) 1:0 (不填写么默认为否)\":\"1\"\n\
                       }",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"简单collectionView",
                       @"{\n\
                       \"最大文件夹名字\":\"GitHub(随便给)\",\n\
                       \"ViewController的名字\":\"Chat\",\n\
                       \"自定义Cell,以逗号隔开\":\"ChatMeText,ChatOtherText,ChatMeImage,ChatOtherImage\",\n\
                       \"是否需要对应的Model 1:0 (不填写么默认为否)\":\"1\",\n\
                       \"是否需要对应的StroyBoard 1:0 (不填写么默认为否)\":\"1\"\n\
                       }",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"tableView嵌套tableView或者collectionView",
                       @"{\n\
                       \"最大文件夹名字\":\"Code4App(随便给)\",\n\
                       \"ViewController的名字\":\"Code\",\n\
                       \"自定义Cell,以逗号隔开\":\"Code1,Code2,Code3,Code4,Code5\",\n\
                       \"自定义Cell标识符:(无:0 TableView:1(子cell以;隔开) ColloectionView:2(子cell以;隔开)),以逗号隔开\":\"0,1(Code2_1;Code2_2),2(Code3_1;Code3_2;Code3_3),2(Code4_1;Code4_2;Code4_3),0\",\n\
                       \"例如cell有A,B  那么嵌套这一行为:1(A1;A2),2(B1;B2)\":\"请填写\",\n\
                       \"是否需要对应的Model 1:0 (不填写么默认为否)\":\"1\",\n\
                       \"是否需要对应的StroyBoard 1:0 (不填写么默认为否)\":\"1\",\n\
                       \"自定义cell可编辑(删除) 1:0 (不填写么默认为否)\":\"1\"\n\
                       }\n\n注意这个格式稍微复杂,要注意,有以逗号\",\"分隔的,有以分号\";\"分隔的",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"最后有一点,就是因为电脑的复制粘贴板和模拟器的复制粘贴板不是同一个,所以无法支持跨模拟器复制粘贴,所以才用 代码助手.m这个文件来输入数据源",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**JSON转模型简介*/
- (void)Json_To_Model{
    NSArray *details=@[@"我们在网上看到很多JSON转模型的,包括很多插件,不过它们很多都是要么没有支持点语法,要么就是.m文件里还是需要我们自己去写某些第三方重写方法",
                       @"我这个是结合了这两个问题做的JSON转模型",
                       @"数据来源有3个,url,json字符串,plist文件",
                       @"url注意点,post的url本身是不带 \"?\",但是填写的时候要把参数写成和get一样的url格式,程序会把 \"?\" 后面的参数变成字典参数的",
                       @"如果有些url需要带额外头,那么建议使用json字符串,因为您只需要拿到json字符串就行了,注意保存(ctrl+s)",
                       @"测试示例 url:  http://seecsee.com/index/getRecommendAndroid",
                       @"最后有一点,就是因为电脑的复制粘贴板和模拟器的复制粘贴板不是同一个,所以无法支持跨模拟器复制粘贴,所以才用 \"代码助手.m\" 这个文件来输入数据源",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**@"为什么生成的代码里全是View1,label2之类的"*/
- (void)ViewAddNum{
    NSArray *details=@[@"在StroyBoard或Xib生成的代码后,我们会发现,有很多控件的名字是升序命名的,这看起来不符合命名规范",
                       @"原因就是我们没有给这个控件一个名字,那如何给这个控件一个名字呢?",
                       @"我们在ViewController里面都会设置CustomClass,那个是用来关联代码文件的,而且是每个控件都有的属性之一",
                       @"所以,我们可以把控件的名字填在那里,注意,填完后,按Enter键,才算赋值好了",
                       @"但是这样有个问题,就是,我们一般不习惯在那里(CustomClass)填值,而且后面想要这个XIB,或者StroyBoard原文件时,还得一个一个删除CustomClass里面的值",
                       @"所以请大家复制一份出来,拿着复制的那份进行赋值",
                       @"所以我不是很建议使用这种方法,最好是用文字替换来解决这个问题就行了",
                       @"其它的不适合这样做,比如将非纯手写工程转换成纯手写,那个控件名升序是不用管的",
                       @"给大家造成麻烦,实在不好意思",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**@"生成property outlet怎么用?"*/
- (void)propertyOutlet{
    NSArray *details=@[@"您有没有觉得,在用StroyBoard搭完界面后,每个控件需要拉线是件很痛苦的事,尤其是您的屏幕不够大的情况下,再加上您还要找到对应的文件,再加上您连好线了,不知道取什么英文名字,再去查字典,白拉出一条线",
                       @"可能拉一两条线,没什么关系,但是十几条而且还是不同文件(Cell),有点麻烦",
                       @"这个时候,最需的是,假如我在拖出这个控件时,有个属性值可以填个值,可以自动帮我们找到文件位置做拉线处理,没错,这个小功能就是帮您做这个事的",
                       @"好了,开始讲怎么用了,很简单",
                       @"点击添加工程,在Mac桌面上会有一个 代码助手.m 文件,把您的工程拖到里面,就会有您工程的路径,确定添加",
                       @"接下来您会发现里面有您工程的所有StroyBoard文件(除了LaunchScreen.stroyboard这个)",
                       @"右边的 OK 您应该看得到,对就是点击那个就可以了,简单吧! 但是注意,您还没给控件设置属性呢!",
                       @"只要您找到像拖线的控件,在它的customClass里,填写您想给它取得名字,但是前面要加一个 \"_\" 并且按Enter就设置好了,例如 \"_MyLabel1\" ,因为您的关联文件应该不会有 \"_\" 开头的",
                       @"好了,把您所需要拉线的控件都这样赋值好,就点击前面说的 OK 就可以了,试试吧,挺爽的",
                       @"您添加的工程会一直存在哦,下次进来不用再添加,如果想删除,侧滑就会有删除",
                       @"前面所说的只是一个功能,就是可以为控件快速拉条线并赋值名字,其实还有一个更爽的功能,就是约束拉线也可以帮您做",
                       @"用法很简单,前面为控件赋值名字是以 \"_\" 开头的,这时如果您是以 w_ 或 h_ 或 t_ 或 b_ 或 l_ 或 r_ 或 x_ 或 y_ 开头,后面接您想为这个约束取的名字,就可以把这条约束拉线出来了",
                       @"其中 w_(宽width)  h_(高height)   t_(上top)  b_(底buttom)  l_(左left)  r_(右right或trailing)  x_(CenterX)  y_(CenterY)",
                       @"当然,如果这个控件不存在这条约束,这时填写是没用的,不会帮您拉出来",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**将非纯手写工程转换成纯手写简介*/
- (void)pureHandProject{
    NSArray *details=@[@"我和我周边开发iOS的朋友经常碰到一个问题,老板要把一个非纯手写工程给我们一个月时间转换成纯手写,虽然没什么太多技术难点,但是new一个一个控件,并且凭空想象设置约束,有点抽象,有点小麻烦",
                       @"做久了会发现,好像就是把StroyBoard上的控件不要用它来帮您生成,而是自己来生成并且布局,其它代码基本不变,这就有点小规律了",
                       @"于是我决定做这个小功能,就是用来把StroyBoard上的控件自动生成,并且生成并且布局,其它代码照旧",
                       @"好了,说了这么多,开始说怎么使用吧(我觉得基本上不用说,一看就能知道怎么用,但还是讲点注意点吧)",
                       @"导入工程(在桌面的 代码助手.m 中填写)",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"导入完成后就可以开始转换了,为了保险起见,它会帮您备份一份,放在您原先工程的文件夹中,所以不用担心损坏原来的工程",
                       @"如果您实在担心损坏以前的工程,请您先自己备份一份",
                       @"因为有时您的工程比较大,所以备份所花的时间很长",
                       @"好了,备份完成后,您基本上可以看到您的工程已经转换成纯手写工程了,但是还不是真正的纯手写,因为纯手写是没有StroyBoard的(假装这样认为吧)",
                       @"除了push和跳转页面的代码需要修改以外,基本上其它代码好像可以原封不动了",
                       @"如果其它代码仍然有许多需要改动的或者里面不尽如意的,请提下建议(1141039693@qq.com),非常感谢,一切只是为了少写代码",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**去除代码注释简介*/
- (void)removeTheComments{
    NSArray *details=@[@"本人是一个英语盲,英语的代码注释对我没有帮助,反而看起来更乱,所以想在看第三方库时,把注释删除,于是写这个小功能,因为这个工程是工具类型软件,所以加上这些小功能",
                       @"其原理非常简单,就是将//,/**/里面的代码删除就可以了",
                       @"但后来发现去除注释是一个很大的麻烦,有兴趣的小伙伴可以自己试一下,可以这样说,要把所有注释去掉,并要求不伤及到有用的代码,是一件难事,因为注释中可能出现的情况太多,试一下就知道,多试几个工程(最好是别人的)",
                       @"因此,我做的这个在不伤及有用代码的情况下,尽力删除注释,有不完善的地方,请大家多包涵",
                       @"如果您的工程中的注释代码是正常类型的,完全可以使用这个去除注释,否则本码农不能保证完全去除成功!",
                       @"使用方法,填写路径(可以是单个文件,也可以是文件夹)(在桌面的 代码助手.m 中填写)",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"再选择您所要去除注释的类型就可以了",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**查看工程总代码行数简介*/
- (void)statisticalCodeRows{
    NSArray *details=@[@"这个小功能很简单,代码很短,不多说,就是统计工程代码行数的,没什么用处",
                       @"使用方法,填写路径(可以是单个文件,也可以是文件夹)(在桌面的 代码助手.m 中填写)",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"点击确定就可以看到结果了",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

/**修改类文件名简介*/
- (void)changeCodeFileName{
    NSArray *details=@[@"有时看到别人封装好用的的类库,想用于公司项目中,又担心公司说尽量不用第三方类库,于是我们不得不将类库名字改成自己的",
                       @"还有一种情况就是,当类库名字是以他人名字命名开头的时候,自己在调用起来时还需要记起来开头名,而且XCode现在还不让联想出来,就有点蛋疼了,于是又想改成以自己命名",
                       @"虽然把别人类库改成自己的,有窃取版权的说法,但是别人既然把类库公开分享,说明别人就是想奉献自己的劳动来帮助大家,所以我们哪样方便就哪样",
                       @"这个功能不仅可以修改第三方类库,同时也可以修改工程命名架构,比如,一开始,我们创建一个文件,当时根据情况取名,后来发现需求更改,或者是因为公用等等因素,这个文件的名字已经不太适合了,但是改起来又有点费劲,有人说把.h.m文件名修改一下,整个工程全局替换就可以了,的确如此,但是如果存在另外一个文件名嵌套这个文件名等等类似因素,那么还是比较难改,所以这个功能就是减少这一点点劳动量,让我们命名可以更加\"随意\",不用担心后期更改了",
                       @"好了,开始介绍使用方法",
                       @"如果是单个文件,就点击单个文件,在填写 代码助手.m 填写就路径和新路径就可以了,新旧文件名在路径中改",
                       @"如果是第三方库,或者是工程,就需要添加(文件夹或者工程了),在 代码助手.m 填写好路径就可以了",
                       @"填写完成后,注意保存(ctrl+s)",
                       @"点击相应的文件夹名或工程名就可以进去修改了",
                       @"每个文件左边都有一个开关,如果要修改这个文件名,就把开关打开",
                       @"点击右上角的修改,就会弹出对话框,这时您再到 代码助手.m 里面修改新的名字,不填写默认为不修改,命名不能以数字开头,新的命名不要和工程里面的其他名字一样",
                       @"填写完了,点击确定修改按钮就会开始进行修改",
                       @"还有什么不清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}
/**存储Cell简介*/
- (void)storageCell{
    NSArray *details=@[@"有时候cell的约束比较麻烦,如果能把这种常用的cell保存起来,下次直接使用就更好了",
                       @"所以做了这个存储cell的功能",
                       @"怎么使用?是用文字叙述是不便于讲述清楚的,请看下录制的讲解视频(点击右上角视频链接),谢谢"
                       ];
    
    [self addData:details];
}

- (void)addData:(NSArray *)details{
    for (NSInteger i=0; i<details.count; i++) {
        DetailStepCellModel *DetailStepModel=[DetailStepCellModel new];
        DetailStepModel.title=[NSString stringWithFormat:@"第 %ld 步",i+1];
        [self.dataArr addObject:DetailStepModel];
        
        DetailContentCellModel *DetailContentModel=[DetailContentCellModel new];
        DetailContentModel.width=self.view.frame.size.width-32-16;
        DetailContentModel.title=details[i];
        [self.dataArr addObject:DetailContentModel];
    }
}

- (void)loadData{
    if ([_helpString isEqualToString:@"Xib生成Masonry简介"]) {
        [self Xib_Masonry];
    }else if ([_helpString isEqualToString:@"StroyBoard生成Masonry简介"]){
        [self StroyBoard_Masonry];
    }else if ([_helpString isEqualToString:@"快速生成代码简介"]){
        [self QuickCreatCode];
    }else if ([_helpString isEqualToString:@"JSON转模型简介"]){
        [self Json_To_Model];
    }else if ([_helpString isEqualToString:@"为什么代码里全是View1,label2之类的?"]){
        [self ViewAddNum];
    }else if ([_helpString isEqualToString:@"生成property outlet怎么用?"]){
        [self propertyOutlet];
    }else if ([_helpString isEqualToString:@"将非纯手写工程转换成纯手写简介"]){
        [self pureHandProject];
    }else if ([_helpString isEqualToString:@"去除代码注释简介"]){
        [self removeTheComments];
    }else if ([_helpString isEqualToString:@"查看工程总代码行数简介"]){
        [self statisticalCodeRows];
    }else if ([_helpString isEqualToString:@"修改类文件名简介"]){
        [self changeCodeFileName];
    }else if ([_helpString isEqualToString:@"存储Cell简介"]){
        [self storageCell];
    }
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
    
    self.tableView.tableFooterView=[UIView new];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
	self.edgesForExtendedLayout=UIRectEdgeNone;

    [self loadData];
    
    [TabBarAndNavagation setLeftBarButtonItemTitle:@"<返回" TintColor:[UIColor blackColor] target:self action:@selector(leftBarClick)];
    [TabBarAndNavagation setRightBarButtonItemTitle:@"视频链接" TintColor:[UIColor blackColor] target:self action:@selector(videoLinkClick)];
    self.title=@"步骤阅读";
}

- (void)leftBarClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoLinkClick{
    
    NSString *macDesktopPath=[ZHFileManager getMacDesktop];
    macDesktopPath = [macDesktopPath stringByAppendingPathComponent:@"代码助手.m"];

    NSString *text=@"GitHub:https://github.com/zhanghuanProgrammer/ZH\n\
    所有视频总链接:  //https://pan.baidu.com/s/1hsho3p6\n\
    \n\
    1.快速生成代码\n\
    1.1快速生成代码-简单tableView    网址://https://pan.baidu.com/s/1jHOn9jC\n\
    1.2快速生成代码-简单CollectionView    网址://https://pan.baidu.com/s/1hs0lsck\n\
    1.3快速生成代码-tableView嵌套tableView或者CollectionView    网址://https://pan.baidu.com/s/1jHYwSC2\n\
    1.4快速生成代码补充    网址://https://pan.baidu.com/s/1qXX4JtM\n\
    \n\
    2.生成property outlet不用自己拉线    网址://https://pan.baidu.com/s/1c131aNY\n\
    \n\
    3.JSON转模型(Model)    网址://https://pan.baidu.com/s/1kV0fkEF\n\
    \n\
    4.将非纯手写工程转换成纯手写    网址://https://pan.baidu.com/s/1qYhEegG\n\
    \n\
    5.StroyBoard Xib 生成Masonry纯手写代码    网址://https://pan.baidu.com/s/1nvEorep\n\
    6.StroyBoard Xib 生成非纯手写代码    网址://https://pan.baidu.com/s/1nvEorep\n\
    \n\
    7.去除代码注释    网址://https://pan.baidu.com/s/1eR3wV9w\n\
    \n\
    8.修改类文件名    网址://https://pan.baidu.com/s/1skHTDxj\n\
    \n\
    9.查看工程或文件总代码行数    网址://https://pan.baidu.com/s/1miB84Zm\n\
    \n\
    10.存储cell(首页)    网址://https://pan.baidu.com/s/1kUMP9IJ\n\
    \n\
    11.ReadMe    网址://https://pan.baidu.com/s/1bpfwLpP\n\n有什么新的需求或者BUG请邮件1141039693@qq.com\n\n@\"祝大家事业有成,身体健康,生活开开心心,笑口常开\"";
    
    BOOL reslut=[text writeToFile:macDesktopPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if (reslut) {
        [ZHAlertAction alertWithMsg:@"视频链接已经保存到MAC 桌面上 代码助手.m 文件中,请点击查看" addToViewController:self ActionSheet:NO];
    }
    
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
	if ([modelObjct isKindOfClass:[DetailStepCellModel class]]){
		DetailStepTableViewCell *DetailStepCell=[tableView dequeueReusableCellWithIdentifier:@"DetailStepTableViewCell"];
		DetailStepCellModel *model=modelObjct;
		[DetailStepCell refreshUI:model];
		return DetailStepCell;
	}
	if ([modelObjct isKindOfClass:[DetailContentCellModel class]]){
		DetailContentTableViewCell *DetailContentCell=[tableView dequeueReusableCellWithIdentifier:@"DetailContentTableViewCell"];
		DetailContentCellModel *model=modelObjct;
		[DetailContentCell refreshUI:model];
		return DetailContentCell;
	}
	//随便给一个cell
	UITableViewCell *cell=[UITableViewCell new];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id modelObjct=self.dataArr[indexPath.row];
    if ([modelObjct isKindOfClass:[DetailStepCellModel class]]){
        return 28.0f;
    }
    if ([modelObjct isKindOfClass:[DetailContentCellModel class]]){
        DetailContentCellModel *model=modelObjct;
        return model.size.height+30+20;
    }
	return 44.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
