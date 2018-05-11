#import "StroyBoardCreatePropertyTableViewCell.h"
#import "CMOutlet.h"
#import "StroyBoardCreateProperty.h"

@interface StroyBoardCreatePropertyTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic,weak)StroyBoardCreatePropertyCellModel *dataModel;
@end

@implementation StroyBoardCreatePropertyTableViewCell


- (void)refreshUI:(StroyBoardCreatePropertyCellModel *)dataModel{
	_dataModel=dataModel;
	self.nameLabel.text=[ZHFileManager getFileNameNoPathComponentFromFilePath:dataModel.title];
    self.subTitleLabel.text=[ZHFileManager getFileNameNoPathComponentFromFilePath:dataModel.subTitle];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    [self.okButton addTarget:self action:@selector(okAction) forControlEvents:1<<6];
    
    [self.okButton cornerRadiusWithFloat:5];
    self.okButton.backgroundColor=[UIColor orangeColor];
}

- (void)okAction{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:[self getViewController].view animated:YES];
    hud.label.text = @"正在生成代码!";
    
    //开始备份一份StroyBoard
    [self backupNewStroyBoard:self.dataModel.title];//还是不备份了
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 处理耗时操作的代码块...
        NSInteger count = [CMOutlet createOutletWithStroyBoardPath:self.dataModel.title withProjectPath:self.dataModel.subTitle];
        count+=[StroyBoardCreateProperty createPropertyWithStroyBoardPath:self.dataModel.title withProjectPath:self.dataModel.subTitle];
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            if(count==-1){
                hud.label.text=[NSString stringWithFormat:@"工程路径已不存在"];
            }else if(count==0){
                hud.label.text=[NSString stringWithFormat:@"找到 0 个(空!)"];
            }else
                hud.label.text=[NSString stringWithFormat:@"处理了%ld个outlet属性",count];
            //回调或者说是通知主线程刷新，
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
        });
    });
}

- (void)backupNewStroyBoard:(NSString *)filePath{
    //有后缀的文件名
    NSString *tempFileName=[ZHFileManager getFileNameFromFilePath:filePath];
    //无后缀的文件名
    NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
    //获取无文件名的路径
    NSString *newFilePath=[filePath stringByReplacingOccurrencesOfString:tempFileName withString:@""];
    //拿到新的有后缀的文件名
    tempFileName=[tempFileName stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@备份",fileName]];
    newFilePath = [newFilePath stringByAppendingPathComponent:tempFileName];
    [ZHFileManager copyItemAtPath:filePath toPath:newFilePath];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
