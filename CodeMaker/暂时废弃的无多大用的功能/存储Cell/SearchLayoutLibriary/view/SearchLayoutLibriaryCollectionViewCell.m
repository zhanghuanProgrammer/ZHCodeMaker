#import "SearchLayoutLibriaryCollectionViewCell.h"

@interface SearchLayoutLibriaryCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@property (nonatomic,weak)SearchLayoutLibriaryCellModel *dataModel;
@end

@implementation SearchLayoutLibriaryCollectionViewCell


- (void)refreshUI:(SearchLayoutLibriaryCellModel *)dataModel{
	_dataModel=dataModel;
    self.countLabel.text=[NSString stringWithFormat:@"%zd",dataModel.count];
    self.subLabel.hidden=self.countLabel.hidden=(dataModel.count==0);
	self.iconImageView.image=[UIImage imageNamed:dataModel.icon];
    self.subLabel.userInteractionEnabled=self.iconImageView.userInteractionEnabled=!dataModel.isUseForOtherUIViewController;
}

- (void)awakeFromNib {
	[super awakeFromNib];
    [self.iconImageView addUITapGestureRecognizerWithTarget:self withAction:@selector(addCountAction)];
    [self.subLabel addUITapGestureRecognizerWithTarget:self withAction:@selector(subCountAction)];
    [self.subLabel cornerRadius];
    [self.countLabel cornerRadius];
    self.countLabel.adjustsFontSizeToFitWidth=YES;
    self.countLabel.textAlignment=NSTextAlignmentCenter;
    [self cornerRadiusWithFloat:10 borderColor:[[UIColor grayColor] colorWithAlphaComponent:0.6] borderWidth:1];
}

- (void)setSelected:(BOOL)selected{
	[super setSelected:selected];
}

- (void)addCountAction{
    self.dataModel.count++;
    self.countLabel.text=[NSString stringWithFormat:@"%zd",self.dataModel.count];
    self.subLabel.hidden=self.countLabel.hidden=(self.dataModel.count==0);
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"UpdateSearchLayoutLibriary"];
}

- (void)subCountAction{
    self.dataModel.count--;
    self.countLabel.text=[NSString stringWithFormat:@"%zd",self.dataModel.count];
    self.subLabel.hidden=self.countLabel.hidden=(self.dataModel.count==0);
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"UpdateSearchLayoutLibriary"];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView{
	[super setSelectedBackgroundView:selectedBackgroundView];
}

@end
