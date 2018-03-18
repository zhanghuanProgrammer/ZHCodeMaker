#import "ZHJsonToXML.h"

@interface ZHJsonToXML ()
@property (nonatomic,assign)NSInteger count;
@end

@implementation ZHJsonToXML
- (NSString *)jsonDicToXML:(NSDictionary *)jsonDic{
    NSMutableString *XML=[NSMutableString string];
    [XML setString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"];

    //找到root
    if(jsonDic[@"_root"]!=nil) [XML appendFormat:@"<%@",jsonDic[@"_root"]];
    else [XML appendFormat:@"<%@",@"root"];
    
    [self dicToXML:jsonDic toXMLStrM:XML];
    if(jsonDic[@"_root"]!=nil) [XML appendFormat:@"</%@>",jsonDic[@"_root"]];
    else [XML appendFormat:@"</%@>",@"root"];
    return XML;
}

- (NSString *)jsonDicToXMLNoNeedHead:(NSDictionary *)jsonDic withRootName:(NSString *)rootName{
    NSMutableString *XML=[NSMutableString string];
    //找到root
    [XML appendFormat:@"<%@",rootName];
    [self dicToXML:jsonDic toXMLStrM:XML];
    [XML appendFormat:@"</%@>",rootName];
    return XML;
}

- (NSString *)jsonDicToXML:(NSDictionary *)jsonDic WithRootName:(NSString *)rootName{
    NSMutableString *XML=[NSMutableString string];
    [XML setString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    //找到root
    [XML appendFormat:@"<%@",rootName];
    [self dicToXML:jsonDic toXMLStrM:XML];
    [XML appendFormat:@"</%@>",rootName];
    return XML;
}

- (BOOL)dicToXML:(NSDictionary *)dic toXMLStrM:(NSMutableString *)XML{
    
    //添加节点和对应的property
    BOOL hasSubDic=NO;
    BOOL hasSubArr=NO;
    for (NSString *key in dic) {
        id obj=dic[key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            hasSubDic=YES;
            continue;
        }else if ([obj isKindOfClass:[NSArray class]]){
            hasSubArr=YES;
            continue;
        }else{
            [self deafultToXML:obj key:key toXMLStrM:XML];
        }
    }
    if (hasSubDic==NO&&hasSubArr==NO) [XML appendFormat:@"/>\n"];
    else [XML appendFormat:@">\n"];
    //添加对应的value
    if (hasSubDic||hasSubArr) {
        for (NSString *key in dic) {
            id obj=dic[key];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                self.count++;
                [XML appendFormat:@"%@<%@",[self getCountStr],key];
                if ([self dicToXML:obj toXMLStrM:XML])
                    [XML appendFormat:@"%@</%@>\n",[self getCountStr],key];
                self.count--;
            }else if ([obj isKindOfClass:[NSArray class]]){
                [self arrToXML:obj key:key toXMLStrM:XML];
            }
        }
    }
    
    if (hasSubDic||hasSubArr) {
        return YES;
    }
    return NO;
}

- (void)arrToXML:(NSArray *)arr key:(NSString *)key toXMLStrM:(NSMutableString *)XML{
    for (id obj in arr) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            self.count++;
            if (key.length>0) [XML appendFormat:@"%@<%@",[self getCountStr],key];
            if ([self dicToXML:obj toXMLStrM:XML])
                if (key.length>0) [XML appendFormat:@"%@</%@>\n",[self getCountStr],key];
            self.count--;
        }else if ([obj isKindOfClass:[NSArray class]]){
            [self arrToXML:obj key:nil toXMLStrM:XML];
        }else{
            [self deafultToXML:obj key:nil toXMLStrM:XML];
        }
    }
}

- (void)deafultToXML:(id)obj key:(NSString *)key toXMLStrM:(NSMutableString *)XML{

    if ([obj isKindOfClass:[NSString class]]&&key.length>0) {
        NSString *value=obj;
        if ([value rangeOfString:@"\""].location!=NSNotFound)
            value=[value stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
        if ([value rangeOfString:@"<"].location!=NSNotFound)
            value=[value stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        if ([value rangeOfString:@">"].location!=NSNotFound)
            value=[value stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        if ([value rangeOfString:@"&"].location!=NSNotFound)
            value=[value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        if ([key isEqualToString:@"_name_zh"]==NO) {
            [XML appendFormat:@" %@=\"%@\"",key,value];
        }
    }else if([obj isKindOfClass:[NSNumber class]]&&key.length>0){
        if ([key isEqualToString:@"_name_zh"]==NO) {
            [XML appendFormat:@" %@=\"%@\"",key,(NSNumber *)obj];
        }
    }
}

- (NSString *)getCountStr{
    NSMutableString *strM=[NSMutableString string];
    for (NSInteger i=0; i<self.count; i++) {
        [strM appendString:@"    "];
    }
    return strM;
}

@end
