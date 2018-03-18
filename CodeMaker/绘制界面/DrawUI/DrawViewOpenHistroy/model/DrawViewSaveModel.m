
#import "DrawViewSaveModel.h"
#import "ZHImage.h"
#import "DrawViewModel.h"

@implementation DrawViewSaveModel

+ (void)saveDrawViewModels:(NSMutableArray *)models snapView:(UIView *)snapView{
    if(snapView.subviews.count<=0 || models.count<=0)return;
    CGFloat maxHeight = 0,originalHeight=snapView.height;
    for (DrawViewModel *model in models) {
        UIView *view = model.relateView;
        model.relateViewIp = [NSString stringWithFormat:@"%p",view];
        if(view.maxY>maxHeight)maxHeight=view.maxY;
    }
    snapView.height = maxHeight;
    UIImage *image = [ZHImage getImageFromView:snapView];
    snapView.height = originalHeight;
    NSString *filePath = [[self backUpDataBasePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"DrawViews%@.png",[ZHNSString getRandomStringWithLenth:15]]];
    [ZHImage saveImage_PNG:image toFile:filePath];
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setValue:models forKey:@"models"];
    [dicM setValue:[DateTools currentDate] forKey:@"time"];
    [dicM setValue:filePath forKey:@"filePath"];
    [dicM setValue:[NSString stringWithFormat:@"%.02f",maxHeight] forKey:@"height"];
    
    NSMutableArray *dataArrM = [ZHSaveDataToFMDB selectDataWithIdentity:@"DrawViews"];
    if(!dataArrM)dataArrM=[NSMutableArray array];
    [dataArrM addObject:dicM];
    [ZHSaveDataToFMDB insertDataWithData:dataArrM WithIdentity:@"DrawViews"];
}

+ (NSString *)backUpDataBasePath{
    NSString *macDocuments=[ZHFileManager getMacDocuments];
    macDocuments=[macDocuments stringByAppendingPathComponent:@"DrawViews"];
    [ZHFileManager creatDirectorIfNotExsit:macDocuments];
    return macDocuments;
}

@end
