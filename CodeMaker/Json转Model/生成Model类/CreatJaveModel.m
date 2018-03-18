#import "CreatJaveModel.h"

//实现自动根据里面的类型自动生成属性

int judge_java(char *p){
    printf("数字为:%s\n",p);
    char *s=p;
    int flag=-1;
    //判断里面是否含有小数点
    while (*s!='\0') {
        if(*s=='.')
            flag=2;//2代表浮点数
        else if(!(*s>='0'&&*s<='9')){
            flag=3;//3代表出错
            NSLog(@"plist说的nsnumber里面含有非数字");
        }
        s++;
    }
    if(flag==-1)flag=1;//3代表成功
    return flag;
}

@implementation CreatJaveModel

+ (void)mySetterGetter:(NSString *)tempStr type:(NSString *)type ToSetterGetter:(NSMutableString *)setterGetter {
    [setterGetter appendFormat:@"public %@ get%@(){\n\
     return this.%@;\n\
     }\n\
     public void set%@(%@ %@){\n\
     this.%@ = %@;\n\
     }\n\n",type,[ZHNSString upFirstCharacter:tempStr],tempStr,[ZHNSString upFirstCharacter:tempStr],type,[ZHNSString lowerFirstCharacter:tempStr],tempStr,[ZHNSString lowerFirstCharacter:tempStr]];
}

//辅助函数KVC
//属性值property的生成
+ (void)myNSMutableArray:(NSString *)tempStr subModelName:(NSString *)subModelName ToNSMutableString:(NSMutableString *)StrM ToSetterGetter:(NSMutableString *)setterGetter {
    [StrM appendFormat:@"private List<%@> %@;\n\n",subModelName,tempStr];
    NSString *type=[NSString stringWithFormat:@"List<%@>",subModelName];
    [setterGetter appendFormat:@"public %@ get%@(){\n\
     if(%@==null)%@=new ArrayList <>();\n\
     return this.%@;\n\
     }\n\
     public void set%@(%@ %@){\n\
     this.%@ = %@;\n\
     }\n\n",type,[ZHNSString upFirstCharacter:tempStr],tempStr,tempStr,tempStr,[ZHNSString upFirstCharacter:tempStr],type,[ZHNSString lowerFirstCharacter:tempStr],tempStr,[ZHNSString lowerFirstCharacter:tempStr]];
}

+ (void)myNSNumberInt:(NSString *)tempStr ToNSMutableString:(NSMutableString *)StrM ToSetterGetter:(NSMutableString *)setterGetter{
    [StrM appendFormat:@"private int %@;\n\n",tempStr];
    [self mySetterGetter:tempStr type:@"int" ToSetterGetter:setterGetter];
}
+ (void)myNSNumberFloat:(NSString *)tempStr ToNSMutableString:(NSMutableString *)StrM ToSetterGetter:(NSMutableString *)setterGetter{
    [StrM appendFormat:@"private float %@;\n\n",tempStr];
    [self mySetterGetter:tempStr type:@"float" ToSetterGetter:setterGetter];
}
+ (void)myNSString:(NSString *)tempStr ToNSMutableString:(NSMutableString *)StrM ToSetterGetter:(NSMutableString *)setterGetter{
    [StrM appendFormat:@"private String %@;\n\n",tempStr];
    [self mySetterGetter:tempStr type:@"String" ToSetterGetter:setterGetter];
}

//新增点语法支持:(函数)
//将字典转换成属性
+ (void)myNSDictionaryTransformToPropert:(NSString *)tempStr ToNSMutableString:(NSMutableString *)StrM withModelName:(NSString *)modelName ToSetterGetter:(NSMutableString *)setterGetter{
    [StrM appendFormat:@"private %@%@Model %@;\n\n",modelName,tempStr,tempStr];
    NSString *type=[NSString stringWithFormat:@"%@%@Model",modelName,tempStr];
    [self mySetterGetter:tempStr type:type ToSetterGetter:setterGetter];
}

//生产coreData的text
static int primeArr_java=NO;

//字典创建模型的主要函数
+ (void)creatProperty:(id)obj fileName:(NSString *)fileName WithContext:(NSString *)context savePath:(NSString *)savePath withNSNULL:(BOOL)NSNULL withNSDATE:(BOOL)NSDATE withNSNUMBER:(BOOL)NSNUMBER withModelName:(NSString *)modelName withFatherClass:(NSString *)className{
    
    NSMutableString *str=[NSMutableString string];//创建文本
    
    NSMutableString *getterAndSetter=[NSMutableString string];//创建文本
    
    NSMutableArray *arrName=[NSMutableArray new];
    
    NSMutableArray *arrSpecialName=[NSMutableArray new];
    
    NSMutableArray *dicName=[NSMutableArray new];
    
    NSMutableArray *stringArr=[NSMutableArray new];
    
    NSMutableArray *NSArrayOrDictionaryArr=[NSMutableArray new];
    
    NSMutableArray *intArr=[NSMutableArray new];
    
    NSMutableArray *floatArr=[NSMutableArray new];
    
    if([fileName isEqualToString:modelName]==NO){
        fileName=[modelName stringByAppendingString:fileName];
    }
    
    if([obj isKindOfClass:[NSDictionary class]]){//如果obj对象是字典
        
        primeArr_java++;
        for (id objtemp in obj) {//开始遍历字典里面的键值对
            if([obj[objtemp] isKindOfClass:[NSString class]]){//如果字典里面是字符串
                //这里需要进行一定的排除 id description
                
                [self myNSString:[self specialNSString:objtemp] ToNSMutableString:str ToSetterGetter:getterAndSetter];
                [stringArr addObject:[self specialNSString:objtemp]];
            }
            else if([obj[objtemp] isKindOfClass:[NSArray class]]){//如果字典里面是数组
                if(((NSArray *)obj[objtemp]).count>0&&[((NSArray *)obj[objtemp])[0] isKindOfClass:[NSDictionary class]] ){//判断里面的数组中是不是字典
                    [arrName addObject:objtemp];
                }else{
                    [arrSpecialName addObject:objtemp];
                }
                
                [NSArrayOrDictionaryArr addObject:[@"NSArray" stringByAppendingString:(NSString *)(objtemp)]];
                
                [self myNSMutableArray:objtemp subModelName:[NSString stringWithFormat:@"%@%@Model",modelName,objtemp] ToNSMutableString:str ToSetterGetter:getterAndSetter];
                
                NSString *tempFileName=objtemp;
                [self creatProperty:obj[objtemp] fileName:tempFileName WithContext:objtemp savePath:savePath withNSNULL:NSNULL withNSDATE:NSDATE withNSNUMBER:NSNUMBER  withModelName:modelName withFatherClass:@"NSDictionary"];
            }
            else if ([obj[objtemp] isKindOfClass:[NSDictionary class]]){//如果字典里面是字典
                [dicName addObject:objtemp];
                [NSArrayOrDictionaryArr addObject:[@"NSDictionary" stringByAppendingString:(NSString *)(objtemp)]];
                [self myNSDictionaryTransformToPropert:objtemp ToNSMutableString:str withModelName:modelName ToSetterGetter:getterAndSetter];
                
                NSString *tempFileName=objtemp;
                [self creatProperty:obj[objtemp] fileName:tempFileName WithContext:objtemp savePath:savePath withNSNULL:NSNULL withNSDATE:NSDATE withNSNUMBER:NSNUMBER withModelName:modelName withFatherClass:@"NSDictionary"];
            }
            else if ([obj[objtemp] isKindOfClass:[NSNull class]]){//如果字典里面是nsnull
                [self myNSString:[self specialNSString:objtemp] ToNSMutableString:str ToSetterGetter:getterAndSetter];
                [stringArr addObject:[self specialNSString:objtemp]];
            }
            else if([obj[objtemp] isKindOfClass:[NSNumber class]]){//如果字典里面是NSNumber
                
                if(NSNUMBER==NO){
                    //这里需要对里面的值进行判断
                    NSNumber *num=obj[objtemp];
                    NSString *strNum=[num stringValue];//将NSNumber转换成字符串
                    
                    char *strP=[strNum UTF8String];
                    int value_int;float value_float;
                    switch (judge_java(strP)) {
                        case 1:value_int=[num intValue];
                            [self myNSNumberInt:objtemp ToNSMutableString:str ToSetterGetter:getterAndSetter];
                            [intArr addObject:objtemp];
                            break;
                        case 2:value_float=[num floatValue];
                            [self myNSNumberFloat:objtemp ToNSMutableString:str ToSetterGetter:getterAndSetter];
                            [floatArr addObject:objtemp];
                            break;
                    }
                }else{
                    [self myNSString:[self specialNSString:objtemp] ToNSMutableString:str ToSetterGetter:getterAndSetter];
                    [stringArr addObject:[self specialNSString:objtemp]];
                }
            }
            else if([obj[objtemp] isKindOfClass:[NSData class]]){//如果字典里面是NSData
                
            }
            else if([obj[objtemp] isKindOfClass:[NSDate class]]){//如果字典里面是NSDate
                [self myNSString:[self specialNSString:objtemp] ToNSMutableString:str ToSetterGetter:getterAndSetter];
                [stringArr addObject:[self specialNSString:objtemp]];
            }
        }
    }
    else if([obj isKindOfClass:[NSArray class]]){//如果obj对象是数组
        primeArr_java++;
        NSMutableDictionary *dataModelType=[NSMutableDictionary dictionary];
        for (id objtemp in obj) {
            if([objtemp isKindOfClass:[NSDictionary class]]){
                for (NSString *tempSubStr in objtemp) {
                    if(dataModelType[tempSubStr]==nil){
                        [dataModelType setValue:objtemp[tempSubStr] forKey:tempSubStr];
                    }
                }
            }
            else if([objtemp isKindOfClass:[NSMutableArray class]]){
                NSString *tempFileName=context ;
                if([tempFileName isEqual:@""]&&primeArr_java==1)
                    tempFileName=modelName;
                [self creatProperty:objtemp fileName:tempFileName WithContext:context savePath:savePath withNSNULL:NSNULL withNSDATE:NSDATE withNSNUMBER:NSNUMBER  withModelName:modelName withFatherClass:@"NSArray"];
                break;//这种情况没有见过
            }
        }
        NSString *tempFileName=context ;
        if([tempFileName isEqual:@""]&&primeArr_java==1)
            tempFileName=modelName;
        [self creatProperty:dataModelType fileName:tempFileName WithContext:context savePath:savePath withNSNULL:NSNULL withNSDATE:NSDATE withNSNUMBER:NSNUMBER  withModelName:modelName withFatherClass:@"NSArray"];
    }
   
    NSString *path=savePath;
    
    [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    primeArr_java--;
    
    //属性生成的相关操作
    path=[path stringByAppendingString:fileName];

    if(str.length>0){//如果没有就不创建文件夹
        
        NSMutableString *textStrM=[NSMutableString string];
        [textStrM appendString:@"import org.json.JSONArray;\n\
         import org.json.JSONException;\n\
         import org.json.JSONObject;\n"];
        
        [textStrM appendFormat:@"public class %@Model {\n\n",fileName];
        [textStrM appendString:str];
        [textStrM appendString:getterAndSetter];
//        [self fill:textStrM withArrInt:intArr withArrFloat:floatArr withArrString:stringArr withArrOrDic:NSArrayOrDictionaryArr fileName:fileName withNSDATE:NSDATE withNSNUMBER:NSNULL];
//        [self fillList:textStrM withArrInt:intArr withArrFloat:floatArr withArrString:stringArr withArrOrDic:NSArrayOrDictionaryArr fileName:fileName withNSDATE:NSDATE withNSNUMBER:NSNULL];
        [textStrM appendString:@"}\n"];
        
        [textStrM setString:[[ZHWordWrap new]wordWrapText:textStrM]];
        [textStrM writeToFile:[savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Model.java",fileName]]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// 特殊字段排除
//比如出现系统关键字:description,id等
+ (NSString *)specialNSString:(NSString *)string{
    return string;
    
    if([string isEqualToString:@"id"]||[string isEqualToString:@"description"]){
        return [@"My" stringByAppendingString:string];
    }
    return string;
}

+ (void)fill:(NSMutableString *)StrM withArrInt:(NSArray *)arrInt withArrFloat:(NSArray *)arrFloat withArrString:(NSArray *)arrString withArrOrDic:(NSArray *)arrOrDic fileName:(NSString *)fileName withNSDATE:(BOOL)NSDATE withNSNUMBER:(BOOL)NSNUMBER{
    [StrM appendFormat:@"public static %@Model fill(JSONObject jo) throws JSONException {\n%@Model o = new %@Model();\n",fileName,fileName,fileName];
    
    if(arrInt.count>0){
        for (NSString *tempStr in arrInt) {
            if (NSNUMBER) {
                [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
                 o.set%@(jo.getString(\"%@\"));\n\
                 }\n",tempStr,[ZHNSString upFirstCharacter:tempStr],tempStr];
            }else{
                [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
                 o.set%@(jo.getInt(\"%@\"));\n\
                 }\n",tempStr,[ZHNSString upFirstCharacter:tempStr],tempStr];
            }
        }
    }
    if(arrFloat.count>0){
        for (NSString *tempStr in arrFloat) {
            if (NSNUMBER) {
                [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
                 o.set%@(jo.getString(\"%@\"));\n\
                 }\n",tempStr,[ZHNSString upFirstCharacter:tempStr],tempStr];
            }else{
                [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
                 o.set%@(jo.getDouble(\"%@\"));\n\
                 }\n",tempStr,[ZHNSString upFirstCharacter:tempStr],tempStr];
            }
        }
    }
    if(arrString.count>0){
        for (NSString *tempStr in arrString) {
            [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
             o.set%@(jo.getString(\"%@\"));\n\
             }\n",tempStr,[ZHNSString upFirstCharacter:tempStr],tempStr];
        }
    }
    if(arrOrDic.count>0){
        for (NSString *tempStr in arrOrDic) {
            if([tempStr hasPrefix:@"NSDictionary"]){
                NSString *subStr=[tempStr substringFromIndex:12];
                [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
                 o.set%@(jo.get%@(\"%@\"));\n\
                 }\n",subStr,[ZHNSString upFirstCharacter:subStr],[ZHNSString upFirstCharacter:subStr],subStr];
            }else{
                NSString *subStr=[tempStr substringFromIndex:7];
                [StrM appendFormat:@"if (jo.has(\"%@\")) {\n\
                 o.set%@(jo.getJSONArray(\"%@\"));\n\
                 }\n",subStr,[ZHNSString upFirstCharacter:subStr],subStr];
            }
        }
    }
    [StrM appendString:@"return o;\n}\n"];
}

+ (void)fillList:(NSMutableString *)StrM withArrInt:(NSArray *)arrInt withArrFloat:(NSArray *)arrFloat withArrString:(NSArray *)arrString withArrOrDic:(NSArray *)arrOrDic fileName:(NSString *)fileName withNSDATE:(BOOL)NSDATE withNSNUMBER:(BOOL)NSNUMBER{
    [StrM appendFormat:@"public static List<%@Model> fillList(JSONArray ja) throws JSONException {\nif (ja == null || ja.length() == 0)\nreturn null;\nList<%@Model> sqs = new ArrayList<%@Model>();\n",fileName,fileName,fileName];
    [StrM appendString:@"for (int i = 0; i < ja.length(); i++) {\n\
     sqs.add(fill(ja.getJSONObject(i)));\n\
     }\n\
     return sqs;\n"];
    [StrM appendString:@"}\n"];
}


@end
