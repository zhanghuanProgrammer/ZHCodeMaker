#import "ExportTemplate.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "ZHJsonToXMLOrder.h"

@implementation ExportTemplate

+ (BOOL)exportTemplateForStoryboardWithParameter:(NSDictionary *)parameter fileName:(NSString *)fileName{
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *resultH = [engine processTemplateInFileAtPath:templatePath withVariables:parameter];
    NSString *original = resultH;
    NSDictionary *resultDic = [NSDictionary dictionaryWithXML:resultH needRecoderOrder:YES];
    resultH = [[ZHJsonToXMLOrder new] jsonDicToXMLNoNeedHead:resultDic withRootName:@"document"];
    NSString *deskTopLocation=[ZHFileManager getMacDesktop];
    NSString *pathH = [deskTopLocation stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.storyboard", @"导出模板"]];
    if (!resultDic||resultDic.count<=0) {
        [original writeToFile:pathH atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:@"XML格式化失败,请检查xml!"];
    }
    BOOL isSuccess = [resultH writeToFile:pathH atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [JohnAlertManager showAlertWithType:JohnTopAlertTypeSuccess title:isSuccess?@"导出成功!":@"导出失败!"];
    return isSuccess;
}

@end
