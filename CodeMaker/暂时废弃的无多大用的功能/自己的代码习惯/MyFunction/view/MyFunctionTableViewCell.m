#import "MyFunctionTableViewCell.h"

@interface MyFunctionTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,weak)MyFunctionCellModel *dataModel;
@end

@implementation MyFunctionTableViewCell


- (void)refreshUI:(MyFunctionCellModel *)dataModel{
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
