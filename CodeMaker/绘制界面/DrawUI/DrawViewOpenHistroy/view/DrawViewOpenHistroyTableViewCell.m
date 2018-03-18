#import "DrawViewOpenHistroyTableViewCell.h"

@interface DrawViewOpenHistroyTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,weak)DrawViewOpenHistroyCellModel *dataModel;

@end

@implementation DrawViewOpenHistroyTableViewCell
- (void)refreshUI:(DrawViewOpenHistroyCellModel *)dataModel{
	_dataModel=dataModel;
	self.nameLabel.text=dataModel.title;
	self.iconImageView.image=[UIImage imageNamed:dataModel.iconImageName];
}

- (void)awakeFromNib {
	[super awakeFromNib];
    self.selectionStyle=UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
