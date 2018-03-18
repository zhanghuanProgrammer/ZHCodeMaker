#import "GetXIBTableViewCell.h"
#import "ZHStoryboardManager.h"
#import "ZHStroyBoardToFrameMVC.h"



@interface GetXIBTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *creatCodeButton;
@property (nonatomic,weak)GetXIBCellModel *dataModel;
@end

@implementation GetXIBTableViewCell


- (void)refreshUI:(GetXIBCellModel *)dataModel{
	_dataModel=dataModel;
	self.nameLabel.text=dataModel.title;
    if (dataModel.iconImageName.length>0) {
        self.iconImageView.image=[UIImage imageNamed:dataModel.iconImageName];
    }else{
        self.iconImageView.image=nil;
    }
    
    self.creatCodeButton.hidden=dataModel.noFile;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.iconImageView cornerRadiusWithFloat:20];
    
    self.creatCodeButton.titleLabel.numberOfLines=0;
    self.creatCodeButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.creatCodeButton.backgroundColor=[[UIColor redColor]colorWithAlphaComponent:0.5];
    [self.creatCodeButton setTintColor:[UIColor whiteColor]];
    [self.creatCodeButton cornerRadiusWithFloat:10];
    
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    [self.creatCodeButton addTarget:self action:@selector(creatCodeAction) forControlEvents:1<<6];
}

- (void)creatCodeAction{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:[self getViewController].view animated:YES];
    
    hud.label.text = @"正在生成代码!";
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 处理耗时操作的代码块...
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:self.dataModel.filePath]==NO) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text =@"路径不存在";
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
            return ;
        }
        
        if (self.dataModel.type==GetSBViewControllerTypePureHand) {
            ZHStoryboardManager *manager=[ZHStoryboardManager new];
            [manager Xib_To_Masonry:self.dataModel.filePath];
        }else if (self.dataModel.type==GetSBViewControllerTypeMVC) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.label.text =@"无必要,请谅解(因为里面没有tableView或者一些复杂的控件)";
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
            return ;
        }else if (self.dataModel.type==GetSBViewControllerTypeFrame) {
            [[ZHStroyBoardToFrameMVC new] Xib_To_Frame:self.dataModel.filePath];
        }
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.label.text=@"生成成功";
            //回调或者说是通知主线程刷新，
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
        });
        
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
