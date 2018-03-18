#import "SmallFunctionTableViewCell.h"

@interface SmallFunctionTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,weak)SmallFunctionCellModel *dataModel;
@end

@implementation SmallFunctionTableViewCell


- (void)refreshUI:(SmallFunctionCellModel *)dataModel{
    _dataModel=dataModel;
    self.nameLabel.text=dataModel.title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.numberOfLines=0;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
