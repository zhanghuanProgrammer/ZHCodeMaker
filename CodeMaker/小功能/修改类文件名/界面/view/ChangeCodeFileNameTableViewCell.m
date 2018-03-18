#import "ChangeCodeFileNameTableViewCell.h"

@interface ChangeCodeFileNameTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (nonatomic,weak)ChangeCodeFileNameCellModel *dataModel;
@end

@implementation ChangeCodeFileNameTableViewCell


- (void)refreshUI:(ChangeCodeFileNameCellModel *)dataModel{
	_dataModel=dataModel;
    self.nameLabel.text=[ZHFileManager getFileNameNoPathComponentFromFilePath:dataModel.title];
    self.rightLabel.hidden=!(dataModel.subTitle.length>0);
    self.nameLabel.textColor=dataModel.subTitle.length>0?[UIColor blackColor]:[UIColor orangeColor];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle=UITableViewCellSelectionStyleNone;
	self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    self.nameLabel.numberOfLines=0;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end