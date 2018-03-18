#import "ZHAddLayoutLibriaryHelp.h"

@implementation ZHAddLayoutLibriaryHelp
- (NSString *)saveCodeFileDirector{
    if (!_saveCodeFileDirector||_saveCodeFileDirector.length<=0) {
        NSString *macDocuments=[ZHFileManager getMacDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"LayoutLibriary"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"CodeFiles"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        
        NSDateFormatter * formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
        NSString *dateString=[formatter stringFromDate:[NSDate date]];
        
        macDocuments=[macDocuments stringByAppendingPathComponent:dateString];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        _saveCodeFileDirector=macDocuments;
    }
    return _saveCodeFileDirector;
}
- (NSString *)saveCellFileDirector{
    if (!_saveCellFileDirector||_saveCellFileDirector.length<=0) {
        NSString *macDocuments=[ZHFileManager getMacDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"LayoutLibriary"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"CellFiles"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        
        NSDateFormatter * formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
        NSString *dateString=[formatter stringFromDate:[NSDate date]];
        
        macDocuments=[macDocuments stringByAppendingPathComponent:dateString];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        _saveCellFileDirector=macDocuments;
    }
    return _saveCellFileDirector;
}
- (NSString *)backUpDataBasePath{
    if (!_backUpDataBasePath||_backUpDataBasePath.length<=0) {
        NSString *macDocuments=[ZHFileManager getMacDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"LayoutLibriary"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        macDocuments=[macDocuments stringByAppendingPathComponent:@"DataBase"];
        [ZHFileManager creatDirectorIfNotExsit:macDocuments];
        _backUpDataBasePath=macDocuments;
    }
    return _backUpDataBasePath;
}
@end
