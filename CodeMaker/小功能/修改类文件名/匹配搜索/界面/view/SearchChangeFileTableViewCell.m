#import "SearchChangeFileTableViewCell.h"

@interface SearchChangeFileTableViewCell ()
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (nonatomic,weak)SearchChangeFileCellModel *dataModel;
@end

@implementation SearchChangeFileTableViewCell

- (void)refreshUI:(SearchChangeFileCellModel *)dataModel{
	_dataModel=dataModel;
    self.switchView.on=dataModel.isSelect;
    [self setTitle:dataModel.title withKeyWord:dataModel.searchText];
}

- (NSArray *)exsitTargetString:(NSString *)targetString inText:(NSString *)text{
    NSMutableArray *arrM=[NSMutableArray array];
    
    targetString=[targetString lowercaseString];
    text=[text lowercaseString];
    
    NSInteger index=0;
    unichar ch1,ch2;
    
    while (text.length>0&&targetString.length>0) {
        ch1=[text characterAtIndex:0];
        ch2=[targetString characterAtIndex:0];
        if (ch1==ch2) {
            text=[text substringFromIndex:1];
            targetString=[targetString substringFromIndex:1];
            [arrM addObject:[NSValue valueWithRange:NSMakeRange(index, 1)]];
        }else{
            text=[text substringFromIndex:1];
        }
        index++;
    }
    return arrM;
}


- (void)setTitle:(NSString *)title withKeyWord:(NSString *)keyWord{
    NSMutableAttributedString *att=[[NSMutableAttributedString alloc]initWithString:title];
    NSArray *ranges=[self exsitTargetString:keyWord inText:title];
    for (NSValue *value in ranges) {
        NSRange range=[value rangeValue];
        [att addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    }
    self.titleLabel.attributedText=att;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle=UITableViewCellSelectionStyleNone;
    [self.switchView addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
}

- (void)switchAction{
    self.dataModel.isSelect=!self.dataModel.isSelect;
    [ZHBlockSingleCategroy runBlockNULLIdentity:@"select_SearchChangeFileViewController"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end