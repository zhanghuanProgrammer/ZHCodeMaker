#import "ZHJsonToXMLOrder.h"

@interface ZHJsonToXMLOrder ()
@property (nonatomic,assign)NSInteger count;
@end
@implementation ZHJsonToXMLOrder

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
        //与ZHJsonToXML.m唯一不同的就是这里,在这里需要对立面的对象进行按序列插入生成xml
        NSMutableArray *allOrderSubDics=[NSMutableArray array];
        for (NSString *key in dic) {
            id obj=dic[key];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [allOrderSubDics addObject:[NSDictionary dictionaryWithObject:(NSDictionary *)obj forKey:key]];
            }
        }
        //进行排序
        [allOrderSubDics sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDictionary *dicTemp1=obj1,*dicTemp2=obj2;
            if (dicTemp1.count>0&&dicTemp2.count>0) {
                NSDictionary *dic1=[dicTemp1 allValues][0],*dic2=[dicTemp2 allValues][0];
                if (dic1[@"ZH_Recoder_Order"]&&dic2[@"ZH_Recoder_Order"]) {
                    NSInteger i1=[dic1[@"ZH_Recoder_Order"] integerValue];
                    NSInteger i2=[dic2[@"ZH_Recoder_Order"] integerValue];
                    return i1>i2;
                }
            }
            return YES;
        }];
        
        for (NSDictionary *orderDic in allOrderSubDics) {
            if (orderDic.count>0) {
                NSString *key=[orderDic allKeys][0];
                id value=[orderDic allValues][0];
                self.count++;
                [XML appendFormat:@"%@<%@",[self getCountStr],key];
                if ([self dicToXML:value toXMLStrM:XML])
                    [XML appendFormat:@"%@</%@>\n",[self getCountStr],key];
                self.count--;
            }
        }
        
        for (NSString *key in dic) {
            id obj=dic[key];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                
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

- (void)deafultToXML:(id)obj key:(NSString *)key toXMLStrM:(NSMutableString *)XML{
    if ([key isEqual:@"ZH_Recoder_Order"]) {
        return;
    }
    [super deafultToXML:obj key:key toXMLStrM:XML];
}

@end
