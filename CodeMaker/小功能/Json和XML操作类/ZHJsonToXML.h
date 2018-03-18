#import <Foundation/Foundation.h>

@interface ZHJsonToXML : NSObject
- (NSString *)jsonDicToXML:(NSDictionary *)jsonDic;
- (NSString *)jsonDicToXMLNoNeedHead:(NSDictionary *)jsonDic withRootName:(NSString *)rootName;
- (NSString *)jsonDicToXML:(NSDictionary *)jsonDic WithRootName:(NSString *)rootName;

- (BOOL)dicToXML:(NSDictionary *)dic toXMLStrM:(NSMutableString *)XML;
- (void)arrToXML:(NSArray *)arr key:(NSString *)key toXMLStrM:(NSMutableString *)XML;
- (void)deafultToXML:(id)obj key:(NSString *)key toXMLStrM:(NSMutableString *)XML;
- (NSString *)getCountStr;

@end
