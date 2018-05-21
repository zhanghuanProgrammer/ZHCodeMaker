#import "LookImageTableViewCell.h"
#import "CMOutlet.h"
#import "StroyBoardCreateProperty.h"
#import "CMStringUtils.h"
#import "ResourceSettings.h"
#import "ResourceFileSearcher.h"
#import "ResourceStringSearcher.h"
#import "StringUtils.h"

// Constant strings
static NSString * const kDefaultResourceSuffixs    = @"imageset|jpg|gif|png";
static NSString * const kDefaultResourceSeparator  = @"|";

static NSString * const kResultIdentifyFileIcon    = @"FileIcon";
static NSString * const kResultIdentifyFileName    = @"FileName";
static NSString * const kResultIdentifyFileSize    = @"FileSize";
static NSString * const kResultIdentifyFilePath    = @"FilePath";

@interface LookImageTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic,weak)LookImageCellModel *dataModel;
@property (strong, nonatomic) NSMutableArray *unusedResults;
@property (assign, nonatomic) BOOL isFileDone;
@property (assign, nonatomic) BOOL isStringDone;
@end

@implementation LookImageTableViewCell


- (void)refreshUI:(LookImageCellModel *)dataModel{
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
    [ZHAlertAction alertWithTitle:@"操作类型" withMsg:nil addToViewController:[self getViewController] ActionSheet:NO otherButtonBlocks:@[^{
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:[self getViewController].view animated:YES];
        hud.label.text = @"正在导出!";
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [CMStringUtils emportAllImageFile:self.dataModel.subTitle];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
        });
    },^{
        __weak typeof(self)weakSelf=self;
        [weakSelf setupSettings];
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:[weakSelf getViewController].view animated:YES];
        hud.label.text = @"正在导出!";
        NSString *emportFilePath = [[ZHFileManager getMacDesktop] stringByAppendingPathComponent:@"未命名文件夹"];
        [ZHFileManager removeItemAtPath:emportFilePath];
        
        [ZHBlockSingleCategroy addBlockWithNULL:^{
            weakSelf.isFileDone = YES;
            [weakSelf searchUnusedResourcesIfNeeded];
        } WithIdentity:@"kNotificationResourceFileQueryDone"];
        [ZHBlockSingleCategroy addBlockWithNULL:^{
            weakSelf.isStringDone = YES;
            [weakSelf searchUnusedResourcesIfNeeded];
            [MBProgressHUD hideAllHUDsForView:[weakSelf getViewController].view animated:YES];
        } WithIdentity:@"kNotificationResourceStringQueryDone"];
        
        [ResourceSettings sharedObject].projectPath = weakSelf.dataModel.subTitle;
        // Reset
        [[ResourceFileSearcher sharedObject] reset];
        [[ResourceStringSearcher sharedObject] reset];
        [weakSelf.unusedResults removeAllObjects];
        
        
        weakSelf.isFileDone = NO;
        weakSelf.isStringDone = NO;
        NSArray *resourceSuffixs = [ResourceSettings sharedObject].resourceSuffixs;
        if (!resourceSuffixs.count) {
            return ;
        }
        
        NSArray *excludeFolders = [ResourceSettings sharedObject].excludeFolders;
        [[ResourceFileSearcher sharedObject] startWithProjectPath:weakSelf.dataModel.subTitle excludeFolders:excludeFolders resourceSuffixs:resourceSuffixs];
        
        [[ResourceStringSearcher sharedObject] startWithProjectPath:weakSelf.dataModel.subTitle excludeFolders:excludeFolders resourceSuffixs:resourceSuffixs resourcePatterns:[ResourceSettings sharedObject].resourcePatterns];
    },^{
        NSString *emportFilePath = [[ZHFileManager getMacDesktop] stringByAppendingPathComponent:@"未命名文件夹"];
        if ([ZHFileManager fileExistsAtPath:emportFilePath]==NO) {
            MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:[self getViewController].view animated:YES];
            hud.label.text = @"桌面上不存在  未命名文件夹  !";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
            return;
        }
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedToView:[self getViewController].view animated:YES];
        hud.label.text = @"正在导出!";
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [CMStringUtils emportCategoryImageFile:self.dataModel.subTitle];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:[self getViewController].view animated:YES];
            });
        });
    }] otherButtonTitles:@[@"导出所有切图",@"导出所有没有用到的切图",@"批量分类哪些可导入,哪些不能"]];
}

- (void)setupSettings {
    self.unusedResults = [NSMutableArray array];
    NSString *exclude = @"";
    if ([ResourceSettings sharedObject].excludeFolders.count) {
        exclude = [[ResourceSettings sharedObject].excludeFolders componentsJoinedByString:kDefaultResourceSeparator];
    }
    NSArray *resSuffixs = [ResourceSettings sharedObject].resourceSuffixs;
    if (!resSuffixs.count) {
        resSuffixs = [kDefaultResourceSuffixs componentsSeparatedByString:kDefaultResourceSeparator];
        [ResourceSettings sharedObject].resourceSuffixs = resSuffixs;
    }
    
    NSArray *resPatterns = [ResourceSettings sharedObject].resourcePatterns;
    resPatterns = [[ResourceStringSearcher sharedObject] createDefaultResourcePatternsWithResourceSuffixs:resSuffixs];
    [ResourceSettings sharedObject].resourcePatterns = resPatterns;
//    [ResourceSettings sharedObject].matchSimilarName = @(NO);
}

- (void)searchUnusedResourcesIfNeeded {
    NSString *tips = @"Searching...";
    if (self.isFileDone) {
        tips = [tips stringByAppendingString:[NSString stringWithFormat:@"%ld resources", [[ResourceFileSearcher sharedObject].resNameInfoDict allKeys].count]];
    }
    if (self.isStringDone) {
        tips = [tips stringByAppendingString:[NSString stringWithFormat:@"%ld strings", [ResourceStringSearcher sharedObject].resStringSet.count]];
    }
    
    if (self.isFileDone && self.isStringDone) {
        NSArray *resNames = [[[ResourceFileSearcher sharedObject].resNameInfoDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSString *name in resNames) {
            if (![[ResourceStringSearcher sharedObject] containsResourceName:name]
                ) {
                if (![[ResourceStringSearcher sharedObject] containsSimilarResourceName:name]
                    || ![ResourceSettings sharedObject].matchSimilarName.boolValue) {
                    //TODO: if imageset name is A but contains png with name B, and using as B, should ignore A.imageset
                    ResourceFileInfo *resInfo = [ResourceFileSearcher sharedObject].resNameInfoDict[name];
                    if (!resInfo.isDir
                        || ![self usingResWithDiffrentDirName:resInfo]) {
                        [self.unusedResults addObject:resInfo.path];
                    }
                }
            }
        }
    }
    for (NSString *filePath in self.unusedResults) {
        NSString *emportDirector = [self creatEmportDirector];
        [ZHFileManager copyItemAtPath:filePath toPath:[emportDirector stringByAppendingPathComponent:[ZHFileManager getFileNameFromFilePath:filePath]]];
    }
}

- (NSString *)creatEmportDirector{
    NSString *emportFilePath = [[ZHFileManager getMacDesktop] stringByAppendingPathComponent:@"未命名文件夹"];
    [ZHFileManager creatDirectorIfNotExsit:emportFilePath];
    return emportFilePath;
}

- (BOOL)usingResWithDiffrentDirName:(ResourceFileInfo *)resInfo {
    if (!resInfo.isDir) {
        return NO;
    }
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:resInfo.path];
    for (NSString *fileName in fileEnumerator) {
        if (![StringUtils isImageTypeWithName:fileName]) {
            continue;
        }
        
        NSString *fileNameWithoutExt = [StringUtils stringByRemoveResourceSuffix:fileName];
        
        if ([fileNameWithoutExt isEqualToString:resInfo.name]) {
            return NO;
        }
        
        if ([[ResourceStringSearcher sharedObject] containsResourceName:fileNameWithoutExt]) {
            return YES;
        }
    }
    return NO;
}

@end
