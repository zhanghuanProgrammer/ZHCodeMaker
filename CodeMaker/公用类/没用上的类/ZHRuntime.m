#import "ZHRuntime.h"
#import <objc/runtime.h>

@implementation ZHRuntime

//返回指定某个类的所有属性
+ (NSArray *)allPropertiesFromClass:(Class)cls{
    unsigned int count;
    // 获取类的所有属性
    // 如果没有属性，则count为0，properties为nil
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        [propertiesArray addObject:name];
    }
    //     注意，这里properties是一个数组指针，是C的语法，
    //     我们需要使用free函数来释放内存，否则会造成内存泄露
    free(properties);
    return propertiesArray;
}

//返回指定某个类的所有属性名和属性值
+ (NSDictionary *)allPropertyNamesAndValuesFromObject:(id)object{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        // 得到属性名
        NSString *propertyName = [NSString stringWithUTF8String:name];
        // 获取属性值
        id propertyValue = [object valueForKey:propertyName];
        if (propertyName && propertyValue != nil) {
            [resultDict setObject:propertyValue forKey:propertyName];
        }
    }
    // 记得释放
    free(properties);
    return resultDict;
}

//返回指定某个类的所有方法名
+ (NSArray *)allMethodsFromClass:(Class)cls{
    NSMutableArray *methodArr=[NSMutableArray array];
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int i = 0; i < outCount; ++i) {
        Method method = methods[i];
        // 获取方法名称，但是类型是一个SEL选择器类型
        SEL methodSEL = method_getName(method);
        // 需要获取C字符串
        const char *name = sel_getName(methodSEL);
        // 将方法名转换成OC字符串
        NSString *methodName = [NSString stringWithUTF8String:name];
        [methodArr addObject:methodName];
        // 获取方法的参数列表
        //        int arguments = method_getNumberOfArguments(method);
        //        NSLog(@"方法名：%@, 参数个数：%d", methodName, arguments);
    }
    // 记得释放
    free(methods);
    return methodArr;
}

//返回指定某个类的所有成员变量
+ (NSArray *)allMemberVariablesFromClass:(Class)cls{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(cls, &count);
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; ++i) {
        Ivar variable = ivars[i];
        const char *name = ivar_getName(variable);
        NSString *varName = [NSString stringWithUTF8String:name];
        [results addObject:varName];
    }
    return results;
}

+ (NSArray *)allAtributesFromClass:(Class)cls{
    unsigned int count;
    NSMutableArray *allAtributesArr=[NSMutableArray array];
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        
        //        NSLog(@"name:%s",property_getName(property));
        [allAtributesArr addObject:[NSString stringWithUTF8String:property_getAttributes(property)]];
        //        NSLog(@"attributes:%s",property_getAttributes(property));
        
    }
    free(properties);
    return allAtributesArr;
}

// 获取所有的属性名和对应的类型
+ (NSDictionary *)allNameAndAtributesFromClass:(Class)cls{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        [dicM setValue:[NSString stringWithUTF8String:property_getAttributes(property)] forKey:[NSString stringWithUTF8String:property_getName(property)]];
        //        NSLog(@"name:%s",property_getName(property));
        //        NSLog(@"attributes:%s",property_getAttributes(property));
    }
    free(properties);
    return dicM;
}

+ (NSArray *)allMethodsDetailInfoFromClass:(Class)cls{
    unsigned int mothCout =0;
    
    //获取方法列表
    Method* methodList = class_copyMethodList(cls,&mothCout);
    
    //创建存储方法信息的数组
    NSMutableArray * methodlists = [NSMutableArray array];
    
    //遍历数组，提取每个方法的信息
    for(int i=0;i<mothCout;i++)
    {
        //获取方法
        Method method = methodList[i];
        //        IMP imp_f = method_getImplementation(temp_f);
        //        SEL name_f = method_getName(temp_f);
        
        //创建方法信息字典
        NSMutableDictionary * methodInfo = [NSMutableDictionary dictionary];
        
        //获取方法名
        const char * name =sel_getName(method_getName(method));
        NSString * methodName = [NSString stringWithUTF8String:name];
        [methodInfo setValue:methodName forKey:@"methodName"];
        
        
        //获取方法返回值类型
        const char * returnType = method_copyReturnType(method);
        NSString * returnTypeString = [NSString stringWithUTF8String:returnType];
        [methodInfo setValue:returnTypeString forKey:@"returnTypeString"];
        
        
        //获取方法参数个数、每个参数的类型
        int arguments = method_getNumberOfArguments(method);
        if (arguments) {
            //创建存储参数类型名的数组
            NSMutableArray * methodArgumentTypes = [NSMutableArray array];
            
            for (int j = 0; j<arguments; j++) {
                //获取每个参数的类型
                char argumentType[256];
                
                method_getArgumentType(method, j, argumentType, 256);
                
                NSString * argumentTypeName = [NSString stringWithUTF8String:argumentType];
                [methodArgumentTypes addObject:argumentTypeName];
            }
            
            [methodInfo setObject:methodArgumentTypes forKey:@"methodArgumentTypes"];
        }
        
        //获取方法编码格式
        const char* encoding = method_getTypeEncoding(method);
        NSString * encodingName = [NSString stringWithUTF8String:encoding];
        [methodInfo setValue:encodingName forKey:@"encodingName"];
        
        [methodlists addObject:methodInfo];
        
    }
    
    free(methodList);
    
    return methodlists;
}

/**返回所有协议名*/
+ (NSArray *)allProtocolFromClass:(Class)cls{
    unsigned int mothCout =0;
    
    __unsafe_unretained Protocol **protocolList=class_copyProtocolList(cls, &mothCout);
    
    //创建存储方法信息的数组
    NSMutableArray * protocolLists = [NSMutableArray array];
    
    //遍历数组，提取每个方法的信息
    for(int i=0;i<mothCout;i++)
    {
        //获取协议
        Protocol *protocol=protocolLists[i];
        const char *protocolName=protocol_getName(protocol);
        [protocolLists addObject:[NSString stringWithUTF8String:protocolName]];
        
    }
    
    free(protocolList);
    
    return [NSArray arrayWithArray:protocolLists];
}

//打印指定某个类的所有成员变量
+ (void)printAllMemberVariablesFromObject:(id)object{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([object class], &count);
    printf("打印%s{\n",[NSStringFromClass([object class]) UTF8String]);
    for (NSUInteger i = 0; i < count; ++i) {
        Ivar variable = ivars[i];
        const char *name = ivar_getName(variable);
        NSString *varName = [NSString stringWithUTF8String:name];
        
        // 获取属性值
        id propertyValue = [object valueForKey:varName];
        if (varName && propertyValue) {
            NSString *info=[NSString stringWithFormat:@"    %@ : %@",varName,propertyValue];
            printf("%s\n",[info UTF8String]);
        }
    }
    printf("}\n");
}
@end
