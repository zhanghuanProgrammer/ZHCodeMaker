#import "SaveTVCLayoutLibriaryTableViewCell.h"

@interface SaveTVCLayoutLibriaryTableViewCell ()

@end

@implementation SaveTVCLayoutLibriaryTableViewCell
- (void)refreshUI:(ZHLayoutLibriaryTableViewCellModel *)dataModel{
	_dataModel=dataModel;
	self.iconImageView.image=[UIImage imageNamed:dataModel.drawViewAddress];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle=UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
