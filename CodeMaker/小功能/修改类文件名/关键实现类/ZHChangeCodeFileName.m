#import "ZHChangeCodeFileName.h"

@implementation ZHChangeCodeFileName

/**从路径中获取可修改的文件名*/
+ (NSArray *)getChangeNamesFromFilePath:(NSString *)filePath{
    NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m",@".mm",@".cpp"]];
    NSMutableArray *arrM=[NSMutableArray array];
    
    for (NSString *filePath in fileArr) {
        
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        if ([self filter:fileName]==NO) {
            [arrM addObject:filePath];
        }
    }
    
    NSArray *pbxprojArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".pbxproj"]];
    if (pbxprojArr.count>0) {
        //说明这是个工程文件
        
        NSMutableArray *tempArrM=[NSMutableArray array];
        NSArray *OCArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m"]];
        for (NSString *filePathTemp in OCArr) {
            NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePathTemp];
            if ([tempArrM containsObject:fileName]==NO) {
                [tempArrM addObject:fileName];
            }else{
                [tempArrM removeObject:fileName];
            }
        }
        NSMutableArray *newArrM=[NSMutableArray array];
        for (NSString *filePathTemp in arrM) {
            NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePathTemp];
            if ([tempArrM containsObject:fileName]==NO) {
                [newArrM addObject:filePathTemp];
            }
        }
        return newArrM;
    }
    return arrM;
}

/**分析并拿取就文件名字和设置新名字的json字符串*/
+ (NSString *)getOldNameAndSetString:(NSString *)filePath{
    NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:filePath hasPathExtension:@[@".h",@".m",@".mm",@".cpp"]];
    
    NSMutableString *changeText=[NSMutableString string];
    [changeText setString:@"{\n"];
    
    NSMutableArray *repeatArrM=[NSMutableArray array];
    
    for (NSString *filePath in fileArr) {
        
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        
        if ([repeatArrM containsObject:fileName]==NO) {
            [repeatArrM addObject:fileName];
            [changeText appendString:[self getOldNameAndSetNewName:fileName]];
            [changeText appendString:@",\n"];
        }
    }
    
    [changeText setString:[changeText stringByReplacingCharactersInRange:NSMakeRange([changeText rangeOfString:@"," options:NSBackwardsSearch|NSLiteralSearch].location, 1) withString:@""]];
    
    [changeText appendString:@"}"];
    
    return changeText;
}

/**给具体路径拿取就文件名字和设置新名字的json字符串*/
+ (NSString *)getOldNameAndSetStringByPathArr:(NSArray *)pathArr{
    
    NSMutableString *changeText=[NSMutableString string];
    [changeText setString:@"{\n"];
    
    NSMutableArray *repeatArrM=[NSMutableArray array];
    
    for (NSString *filePath in pathArr) {
        
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        
        if ([repeatArrM containsObject:fileName]==NO) {
            [repeatArrM addObject:fileName];
            [changeText appendString:[self getOldNameAndSetNewName:fileName]];
            [changeText appendString:@",\n"];
        }
    }
    
    [changeText setString:[changeText stringByReplacingCharactersInRange:NSMakeRange([changeText rangeOfString:@"," options:NSBackwardsSearch|NSLiteralSearch].location, 1) withString:@""]];
    
    [changeText appendString:@"}"];
    
    return changeText;
}

/**对新名字和旧名字进行判断*/
+ (NSString *)getChangeDicFromJsonDic:(NSMutableDictionary *)dicTemp{
    
    NSString *result=@"";
    NSMutableArray *arrM=[NSMutableArray array];
    for (NSString *str in [dicTemp allValues]) {
        if ([arrM containsObject:str]) {
            result= @"存在相同的文件名";
            break;
        }else{
            [arrM addObject:str];
        }
        if([self isPrefixNum:str]){
            result= @"存在文件名以数字开头";
            break;
        }
    }
    if (result.length>0) {
        [dicTemp removeAllObjects];
        return result;
    }
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    for (NSString *key in dicTemp) {
        if ([dicTemp[key] length]<=0) {
            continue;
        }
        if ([key isEqualToString:dicTemp[key]]) {
            continue;
        }
        if ([dicTemp[key] rangeOfString:@"<#"].location!=NSNotFound||[dicTemp[key] rangeOfString:@"#>"].location!=NSNotFound) {
            continue;
        }
        
        [dic setValue:dicTemp[key] forKey:key];
    }
    [dicTemp removeAllObjects];
    [dicTemp setDictionary:dic];
    
    return @"";
}

/**修改多个文件*/
+ (NSString *)changeMultipleCodeFileName:(NSString *)path{
    NSString *tempPath=[[ZHFileManager getMacDesktop]stringByAppendingPathComponent:@"代码助手.m"];
    NSString *strTemp=[NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:nil];
    if ([strTemp hasSuffix:@"\n"]) {
        strTemp=[strTemp substringToIndex:strTemp.length-1];
    }
    NSMutableDictionary *dicTemp;
    if (strTemp.length>0) {
        dicTemp=[NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[strTemp dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]];
    }else{
        return @"修改内容被清空!";
    }
    if(dicTemp==nil){
        return @"修改内容格式被修改!";
    }
    
    NSString *result=@"";
    
    result=[self getChangeDicFromJsonDic:dicTemp];
    
    if (result.length>0) {
        return result;
    }
    if (dicTemp.count==0) {
        return @"你没有填写!";
    }
    
    NSArray *fileArr=[ZHFileManager subPathFileArrInDirector:path hasPathExtension:@[@".h",@".m",@".mm",@".cpp"]];
    
    //判断是否存在名字为工程或者文件夹里已经存在的
    NSArray *allvalues=[dicTemp allValues];
    for (NSString *filePath in fileArr) {
        NSString *fileName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        if ([allvalues containsObject:fileName]) {
            return @"新文件名与另一文件名同名";
        }
    }
    
    for (NSString *filePath in fileArr) {
        NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        for (NSString *key in dicTemp) {
            text=[self changeOldName:key newName:dicTemp[key] inText:text];
        }
        
        NSString *fileNameNoPathExtension=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
        
        if (dicTemp[fileNameNoPathExtension]!=nil) {
            NSString *newPath=[self oldName:filePath ChangeToNewName:dicTemp[fileNameNoPathExtension]];
            [text writeToFile:newPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if ([filePath isEqualToString:newPath]==NO) {
                [ZHFileManager removeItemAtPath:filePath];
            }
        }else{
            [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    
    NSArray *pchFileArr=[ZHFileManager subPathFileArrInDirector:path hasPathExtension:@[@".pch"]];
    
    for (NSString *filePath in pchFileArr) {
        NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        for (NSString *key in dicTemp) {
            text=[self changeOldName:key newName:dicTemp[key] inText:text];
        }
        [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    NSArray *pbxprojArr=[ZHFileManager subPathFileArrInDirector:path hasPathExtension:@[@".pbxproj"]];
    for (NSString *filePath in pbxprojArr) {
        NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSUInteger start=[text rangeOfString:@"/* Begin PBXFileReference section */"].location;
        NSUInteger end=[text rangeOfString:@"/* End PBXFileReference section */"].location;
        if (start!=NSNotFound&&end!=NSNotFound) {
            start+=@"/* Begin PBXFileReference section */".length;
            
            NSString *needChangeText=[text substringWithRange:NSMakeRange(start, end-start)];
            
            for (NSString *key in dicTemp) {
                needChangeText=[self changeFor_pbxproj_OldName:key newName:dicTemp[key] inText:needChangeText];
            }
            
            text=[text stringByReplacingCharactersInRange:NSMakeRange(start, end-start) withString:needChangeText];
        }
        
        [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSArray *stroyBoardOrXibArr=[ZHFileManager subPathFileArrInDirector:path hasPathExtension:@[@".storyboard",@".xib"]];
    for (NSString *filePath in stroyBoardOrXibArr) {
        NSString *text=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        for (NSString *key in dicTemp) {
            text=[self changeFor_storyboard_OldName:key newName:dicTemp[key] inText:text];
        }
        
        [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    //修改对应Xib的文件名字
    for (NSString *filePath in stroyBoardOrXibArr) {
        if ([filePath hasSuffix:@".xib"]) {
            for (NSString *key in dicTemp) {
                if (![key isEqualToString:dicTemp[key]]) {
                    NSString *xibName=[ZHFileManager getFileNameNoPathComponentFromFilePath:filePath];
                    if ([key isEqualToString:xibName]) {
                        NSString *noFileNamePath=[ZHFileManager getFilePathRemoveFileName:filePath];
                        [ZHFileManager moveItemAtPath:filePath toPath:[noFileNamePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xib",dicTemp[key]]]];
                        break;
                    }
                }
            }
        }
    }
    return @"";
}

#pragma mark----辅助函数
/**是不是以数字开头*/
+ (BOOL)isPrefixNum:(NSString *)text{
    if (text.length>0) {
        unichar ch=[text characterAtIndex:0];
        if (ch>='0'&&ch<='9') {
            return YES;
        }
    }
    return NO;
}
/**旧文件名字改成新文件名字*/
+ (NSString *)oldName:(NSString *)oldName ChangeToNewName:(NSString *)newName{
    NSString *newPath=@"";
    NSString *fileName=[ZHFileManager getFileNameFromFilePath:oldName];
    newPath=[oldName substringToIndex:oldName.length-fileName.length];
    NSString *pathExtension=[oldName pathExtension];
    newPath=[newPath stringByAppendingPathComponent:newName];
    newPath=[newPath stringByAppendingString:[NSString stringWithFormat:@".%@",pathExtension]];
    return newPath;
}

+ (NSString *)getOldNameAndSetNewName:(NSString *)fileName{
    NSString *lowercaseString=[fileName lowercaseString];
    if ([lowercaseString hasSuffix:@"viewcontroller"]) {
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"ViewController".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>ViewController\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"tableviewcell"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"TableViewCell".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>TableViewCell\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"collectionviewcell"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"CollectionViewCell".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>CollectionViewCell\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"cell"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"Cell".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>Cell\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"cellmodel"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"CellModel".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>CellModel\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"model"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"Model".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>Model\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"delegate"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"Delegate".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>Delegate\"",fileName,subFileName];
    }
    else if ([lowercaseString hasSuffix:@"manager"]){
        NSString *subFileName=[fileName substringToIndex:fileName.length-@"Manager".length];
        if(subFileName.length<=0)subFileName=@"空";
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>Manager\"",fileName,subFileName];
    }
    else{
        return [NSString stringWithFormat:@"    \"%@\":\"<#%@#>\"",fileName,fileName];
    }
}

/**修改单个文件*/
+ (NSString *)changeSingleFile:(NSString *)oldPath newPath:(NSString *)newPath{
    
    if ([ZHFileManager fileExistsAtPath:newPath]) {
        return @"新文件路径已存在,请检查!";
    }else{
        if ([ZHFileManager createFileAtPath:newPath]==NO) {
            return @"新文件路径格式有误!";
        }
    }
    
    NSString *text=[NSString stringWithContentsOfFile:oldPath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *oldName=[ZHFileManager getFileNameNoPathComponentFromFilePath:oldPath];
    NSString *newName=[ZHFileManager getFileNameNoPathComponentFromFilePath:newPath];
    text=[self changeOldName:oldName newName:newName inText:text];
    [text writeToFile:newPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return @"修改成功!";
}

/**替换代码文件内容的函数,替换整个text里面的旧名字,改成新名字*/
+ (NSString *)changeOldName:(NSString *)oldName newName:(NSString *)newName inText:(NSString *)text{
    if ([oldName isEqualToString:newName]) {
        return text;
    }
    
    NSUInteger indexStart=[text rangeOfString:oldName options:NSLiteralSearch].location;
    
    unichar proir,next;
    BOOL proirResult,nextResult;
    while (indexStart!=NSNotFound) {
        
        proirResult=YES;
        nextResult=YES;
        
        //获取前一个字符串
        if (indexStart>0) {
            proir=[text characterAtIndex:indexStart-1];
            proirResult=[self isNoCharacter:proir isProir:YES];
        }else{
            proirResult=NO;
        }
        
        //获取后一个字符串
        if(indexStart+oldName.length<text.length-1){
            next=[text characterAtIndex:indexStart+oldName.length];
            nextResult=[self isNoCharacter:next isProir:NO];
        }else{
            nextResult=NO;
        }
        
        if (proirResult==YES&&nextResult==YES) {//条件满足,开始替换
            text=[text stringByReplacingCharactersInRange:NSMakeRange(indexStart, oldName.length) withString:newName];
            indexStart=indexStart+newName.length;
        }else{
            indexStart++;
        }
        
        if (indexStart<text.length) {
            indexStart=[text rangeOfString:oldName options:NSLiteralSearch range:NSMakeRange(indexStart, text.length-indexStart)].location;
        }else{
            break;
        }
    }
    
    return text;
}
/**替换pbxproj的函数,替换整个text里面的旧名字,改成新名字*/
+ (NSString *)changeFor_pbxproj_OldName:(NSString *)oldName newName:(NSString *)newName inText:(NSString *)text{
    if ([oldName isEqualToString:newName]) {
        return text;
    }
    
    NSUInteger indexStart=[text rangeOfString:oldName options:NSLiteralSearch].location;
    
    unichar proir,next;
    BOOL proirResult,nextResult;
    while (indexStart!=NSNotFound) {
        
        proirResult=YES;
        nextResult=YES;
        
        //获取前一个字符串
        if (indexStart>0) {
            proir=[text characterAtIndex:indexStart-1];
            proirResult=[self isNoCharacter:proir isProir:YES];
        }else{
            proirResult=NO;
        }
        
        //获取后一个字符串
        if(indexStart+oldName.length<text.length-1){
            next=[text characterAtIndex:indexStart+oldName.length];
            nextResult=[self isNoCharacter:next isProir:NO];
            if (nextResult==YES) {
                //继续加一个条件
                NSString *fileSuffix=[text substringWithRange:NSMakeRange(indexStart+oldName.length, 4)];
                NSArray *suffixs=@[@".h",@".m",@".mm",@".cpp"];
                nextResult=NO;
                for (NSString *suffix in suffixs) {
                    if ([fileSuffix hasPrefix:[NSString stringWithFormat:@"%@\";",suffix]]||[fileSuffix hasPrefix:[NSString stringWithFormat:@"%@;",suffix]]) {
                        nextResult=YES;
                        break;
                    }
                }
            }
        }else{
            nextResult=NO;
        }
        
        if (proirResult==YES&&nextResult==YES) {//条件满足,开始替换
            text=[text stringByReplacingCharactersInRange:NSMakeRange(indexStart, oldName.length) withString:newName];
            indexStart=indexStart+newName.length;
        }else{
            indexStart++;
        }
        
        if (indexStart<text.length) {
            indexStart=[text rangeOfString:oldName options:NSLiteralSearch range:NSMakeRange(indexStart, text.length-indexStart)].location;
        }else{
            break;
        }
    }
    
    return text;
}
/**替换pbxproj的函数,替换整个text里面的旧名字,改成新名字*/
+ (NSString *)changeFor_storyboard_OldName:(NSString *)oldName newName:(NSString *)newName inText:(NSString *)text{
    if ([oldName isEqualToString:newName]) {
        return text;
    }
    
    NSUInteger indexStart=[text rangeOfString:oldName options:NSLiteralSearch].location;
    
    unichar proir,next;
    BOOL proirResult,nextResult;
    while (indexStart!=NSNotFound) {
        
        proirResult=YES;
        nextResult=YES;
        
        //获取前一个字符串
        if (indexStart>0) {
            proir=[text characterAtIndex:indexStart-1];
            proirResult=[self isNoCharacter:proir isProir:YES];
            if (proirResult==YES) {
                if (proir!='"') {
                    proirResult=NO;
                }
            }
        }else{
            proirResult=NO;
        }
        
        //获取后一个字符串
        if(indexStart+oldName.length<text.length-1){
            next=[text characterAtIndex:indexStart+oldName.length];
            nextResult=[self isNoCharacter:next isProir:NO];
            if (nextResult==YES) {
                if (next!='"') {
                    nextResult=NO;
                }
            }
        }else{
            nextResult=NO;
        }
        
        if (proirResult==YES&&nextResult==YES) {//条件满足,开始替换
            text=[text stringByReplacingCharactersInRange:NSMakeRange(indexStart, oldName.length) withString:newName];
            indexStart=indexStart+newName.length;
        }else{
            indexStart++;
        }
        
        if (indexStart<text.length) {
            indexStart=[text rangeOfString:oldName options:NSLiteralSearch range:NSMakeRange(indexStart, text.length-indexStart)].location;
        }else{
            break;
        }
    }
    
    return text;
}
+ (BOOL)isNoCharacter:(unichar)ch isProir:(BOOL)isProir{
    
    if (ch>='a'&&ch<='z') {
        return NO;
    }
    if (ch>='A'&&ch<='Z') {
        return NO;
    }
    if (isProir==YES&&(ch=='_'||ch=='+')) {
        return NO;
    }
    return YES;
}

+ (BOOL)filter:(NSString *)fileName{
    NSArray *arr=@[@"main",@"AppDelegate",@"_______Tests",@"project",@"_______UITests",@""];
    if ([arr containsObject:fileName]) {
        return YES;
    }else{
        return NO;
    }
}
@end
