#import "SetDeaultProjectTableViewCell.h"

@interface SetDeaultProjectTableViewCell ()
@property (nonatomic,weak)SetDeaultProjectCellModel *dataModel;
@property (weak, nonatomic) IBOutlet UISwitch *deaultProjectSwitch;
@property (weak, nonatomic) IBOutlet UILabel *deaultProjectLabel;

@end

@implementation SetDeaultProjectTableViewCell

- (void)refreshUI:(SetDeaultProjectCellModel *)dataModel{
	_dataModel=dataModel;
    self.deaultProjectLabel.text=dataModel.title;
    self.deaultProjectSwitch.on=dataModel.isSelect;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle=UITableViewCellSelectionStyleNone;
    [self.deaultProjectSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.deaultProjectLabel.textColor=RGB(51, 51, 51);
    self.deaultProjectSwitch.onTintColor=RGB(33, 180, 190);
}

- (void)switchAction:(UISwitch *)swh{
    if (self.dataModel.isSelect) {
        swh.on=YES;
        return;
    }
    [ZHBlockSingleCategroy runBlockNSStringIdentity:@"SetDeaultProjectViewControllerSwitch" Str1:self.dataModel.subTitle];
}

@end
