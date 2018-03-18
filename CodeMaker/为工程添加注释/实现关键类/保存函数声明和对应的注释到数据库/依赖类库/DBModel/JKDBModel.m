/*
 技术点1:利用了runtime和kvc,获取到该类的所有成员变量和成员类型
 技术点2:动态的往表中添加字段
 技术点3:利用插入语句的?,可以不用管后面真实插入的是那种数据类型,因为它本身会判断这个数据对象(FMDB用的好)
 */

#import "JKDBModel.h"
#import "JKDBHelper.h"
#import <objc/runtime.h>

@implementation JKDBModel









#pragma mark ------------------------ 生命周期 ------------------------
+ (void)initialize{
    if (self != [JKDBModel self]) {
        [self createTable];
    }
}
- (instancetype)init{
    self = [super init];
    if (self) {
        NSDictionary *dic = [self.class getAllProperties];
        _columeNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
        _columeTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
    }
    
    return self;
}











#pragma mark ------------------------ 数据库流程 ------------------------
/**
 * 创建表
 * 如果已经创建，判断是否需要添加新增字段到表格中
 */
+ (BOOL)createTable{
    __block BOOL res = YES;
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        //Table(表)的名字就用这个类的名字,这样就不会出现两个相同的表名
        NSString *tableName = NSStringFromClass(self.class);
        //下面开始根据表名和字段类型创建表 例如:pk INTEGER primary key autoincrement,account TEXT,name TEXT,sex TEXT,portraitPath TEXT,moblie TEXT,descn TEXT,age INTEGER
        //思路:用runtime获取该模型对象的每个字段的类型,就可以获取到创建表中字段的创建语句了
        NSString *columeAndType = [self.class getColumeAndTypeString];
        //创建字段，columeAndType中保存的是模型中所有的属性名与属性类型
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columeAndType];
        if (![db executeUpdate:sql]) {
            res = NO;
            *rollback = YES;
            return;
        };
        
        //前面是创建表,如果没有该表的话,但是如果有这个表,并且可能用户自己又新加了一个属性,如果没有手动过滤这儿属性的话,那么这个属性就应该要加入这张表
        NSMutableArray *columns = [NSMutableArray array];
        FMResultSet *resultSet = [db getTableSchema:tableName];//需要传入的参数：表名，返回值：查询表后的结果集FMResultSet
        while ([resultSet next]) {
            //取出结果集中name对应的值，即字段的名称（取出所有的字段名）
            NSString *column = [resultSet stringForColumn:@"name"];//获取到字段名,之所以不用getColumeAndTypeString来获取字段名,是因为这里可能有些字段名被过滤了
            [columns addObject:column];
        }
        
        //拿到存有所有属性（包括自己添加的主键字段）的字典
        NSDictionary *dict = [self.class getAllProperties];
        //拿到所有属性名
        NSArray *properties = [dict objectForKey:@"name"];
        
        //这个过滤数组的作用：检查模型中所有的属性在数据库中是否都有对应的字段，如果没有，立即新增一个字段
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
        //过滤数组
        NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
        
        for (NSString *column in resultArray) {
            NSUInteger index = [properties indexOfObject:column];
            NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
            NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
            //在表中添加新的字段（或者说新的列）
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self.class),fieldSql];
            if (![db executeUpdate:sql]) {
                res = NO;
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return res;
}

/**
 保存数据(保存模型数据).通过运行时拿到所有属性 -> 通过KVC，拿到所有属性地址存储的值，用一个数组保存 -> 利用先前拿到的属性名与值的数组，依照sqlite语法拼接成插入语句 -> 执行插入操作
 【关键】：想要插入数据到创建好的数据库，需要字段名与值；字段名就是所有的属性名，值就是属性地址存储的值;
 */
- (BOOL)save{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray *insertValues=[NSMutableArray array];
        NSString *sql = [self getSaveSQL:self outForVlaues:insertValues];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        self.pk = res?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
//        NSLog(res?@"插入成功":@"插入失败");
    }];
    return res;
}

+ (NSString *)dbPath:(NSString *)directoryName{
    return [JKDBHelper dbPath:directoryName];
}

/** 批量保存用户对象 */
+ (BOOL)saveObjects:(NSArray *)array directoryName:(NSString *)directoryName{
    //判断是否是JKBaseModel的子类
    for (JKDBModel *model in array) {
        if (![model isKindOfClass:[JKDBModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    jkDB.directoryName=directoryName;
    // 如果要支持事务
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (JKDBModel *model in array) {
            NSMutableArray *insertValues=[NSMutableArray array];
            NSString *sql = [(JKDBModel *)model getSaveSQL:model outForVlaues:insertValues];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            model.pk = flag?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
//            NSLog(flag?@"插入成功":@"插入失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 更新单个对象 */
- (BOOL)update{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray *updateValues=[NSMutableArray array];
        NSString *sql = [self getUpdateSQL:self outForVlaues:updateValues];
        if (sql.length<=0) {res = NO;NSLog(res?@"更新成功":@"更新失败"); return;}
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        NSLog(res?@"更新成功":@"更新失败");
    }];
    return res;
}

/** 批量更新用户对象*/
+ (BOOL)updateObjects:(NSArray *)array{
    for (JKDBModel *model in array) {
        if (![model isKindOfClass:[JKDBModel class]]) {
            return NO;
        }
    }
    __block BOOL res = YES;
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    // 如果要支持事务
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (JKDBModel *model in array) {
            
            NSMutableArray *updateValues=[NSMutableArray array];
            NSString *sql = [(JKDBModel *)model getUpdateSQL:model outForVlaues:updateValues];
            if (sql.length<=0) {res = NO;*rollback = YES;NSLog(res?@"更新成功":@"更新失败");return;}
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            NSLog(flag?@"更新成功":@"更新失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    
    return res;
}

/** 清空表 */
+ (BOOL)clearTable{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(res?@"清空成功":@"清空失败");
    }];
    return res;
}

/** 删除单个对象 */
- (BOOL)deleteObject{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 批量删除用户对象 */
+ (BOOL)deleteObjects:(NSArray *)array{
    for (JKDBModel *model in array) {
        if (![model isKindOfClass:[JKDBModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    // 如果要支持事务
    [jkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (JKDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:primaryId];
            if (!primaryValue || primaryValue <= 0) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            NSLog(flag?@"删除成功":@"删除失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    __block BOOL res = NO;
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ",tableName,criteria];
        res = [db executeUpdate:sql];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 获取列名 */
+ (NSArray *)getColumns{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    NSMutableArray *columns = [NSMutableArray array];
     [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
         NSString *tableName = NSStringFromClass(self.class);
         FMResultSet *resultSet = [db getTableSchema:tableName];
         while ([resultSet next]) {
             NSString *column = [resultSet stringForColumn:@"name"];
             [columns addObject:column];
         }
     }];
    return [columns copy];
}

/**保存或者更新*/
- (BOOL)saveOrUpdate{
    id primaryValue = [self valueForKey:primaryId];
    if ([primaryValue intValue] <= 0) {
        return [self save];
    }
    return [self update];
}

/** 查找某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria{
    NSArray *results = [self.class findByCriteria:criteria];
    if (results.count < 1) {
        return nil;
    }
    
    return [results firstObject];
}

/** 通过条件查找数据 */
+ (NSArray *)findByCriteria:(NSString *)criteria{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,criteria];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            JKDBModel *model = [[self.class alloc] init];
            for (int i=0; i< model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                } else if ([columeType isEqualToString:SQLBLOB]) {
                    [model setValue:[resultSet dataForColumn:columeName] forKey:columeName];
                }else if ([columeType isEqualToString:SQLREAL]) {
                    [model setValue:[NSNumber numberWithFloat:[resultSet doubleForColumn:columeName]] forKey:columeName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}

/**是否有数据*/
+ (BOOL)haveData{
    NSMutableArray *users = [NSMutableArray array];
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while ([resultSet next]) {
            [users addObject:@" "];
        }
    }];
    return users.count>0;
}
/** 查询全部数据 */
+ (NSArray *)findAll{
    return [self findByCriteria:@""];
}

/**通过PrimaryKey查找数据*/
+ (instancetype)findByPK:(int)inPk{
    NSString *condition = [NSString stringWithFormat:@"WHERE %@=%d",primaryId,inPk];
    return [self findFirstByCriteria:condition];
}

/**打印自己*/
- (NSString *)description{
    NSString *result = @"";
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        NSString *proName = [proNames objectAtIndex:i];
        id  proValue = [self valueForKey:proName];
        if (![proValue isKindOfClass:[NSData class]]) {
            result = [result stringByAppendingFormat:@"%@:%@\n",proName,proValue];
        }
    }
    return result;
}

/**更新或保存某某列名为某某值的一行*/
- (BOOL)saveOrUpdateByColumnName:(NSString*)columnName AndColumnValue:(NSString*)columnValue{
    id record = [self.class findFirstByCriteria:[NSString stringWithFormat:@"where %@ = %@",columnName,columnValue]];
    if (record) {
        id primaryValue = [record valueForKey:primaryId]; //取到了主键PK
        if ([primaryValue intValue] <= 0) {
            return [self save];
        }else{
            self.pk = [primaryValue integerValue];
            return [self update];
        }
    }else{
        return [self save];
    }
}

/** 通过条件删除 (多参数）*/
+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self deleteObjectsByCriteria:criteria];
}

/** 通过条件查找第一个 (多参数）*/
+ (instancetype)findFirstWithFormat:(NSString *)format, ...{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self findFirstByCriteria:criteria];
}

/** 通过条件查找 (多参数）*/
+ (NSArray *)findWithFormat:(NSString *)format, ...{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self findByCriteria:criteria];
}
















#pragma mark - ########################## 辅助 ##########################
#pragma mark - 必须被重写
/** 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
 */
+ (NSArray *)transients{
    return [NSArray array];
}

#pragma mark - 这里的函数是用来获取该模型的成员名和类型,生成对应的创建表的SQL语句
/**
 *  获取该类的所有属性以及属性对应的类型,并且存入字典中
 */
+ (NSDictionary *)getPropertys{
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    NSArray *theTransients = [[self class] transients];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([theTransients containsObject:propertyName]) {
            continue;
        }
        [proNames addObject:propertyName];
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         各种符号对应类型，部分类型在新版SDK中有所变化，如long 和long long
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         因为在项目中用的类型不多，故只考虑了少数类型
         */
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            [proTypes addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            [proTypes addObject:SQLBLOB];
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            [proTypes addObject:SQLINTEGER];
        } else {
            [proTypes addObject:SQLREAL];
        }
        
    }
    free(properties);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}
/** 获取模型中的所有属性，并且添加一个主键字段pk。这些数据都存入一个字典中 */
+ (NSDictionary *)getAllProperties{
    NSDictionary *dict = [self.class getPropertys];
    
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObject:primaryId];
    [proTypes addObject:[NSString stringWithFormat:@"%@ %@ %@",SQLINTEGER,PrimaryKey,@"autoincrement"]];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}
/**将属性名与属性类型拼接成sqlite语句：integer a,real b,...*/
+ (NSString *)getColumeAndTypeString{
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< proNames.count; i++) {
        [pars appendFormat:@"%@ %@",[proNames objectAtIndex:i],[proTypes objectAtIndex:i]];
        if(i+1 != proNames.count)
        {
            [pars appendString:@","];
        }
    }
    return pars;
}
/**生成Save的SQL语句*/
- (NSString *)getSaveSQL:(JKDBModel *)model outForVlaues:(NSMutableArray *)values{
    NSString *tableName = NSStringFromClass(model.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    for (int i = 0; i < model.columeNames.count; i++) {
        NSString *proname = [model.columeNames objectAtIndex:i];
        //如果是主键，不处理
        if ([proname isEqualToString:primaryId]) {
            continue;
        }
        [keyString appendFormat:@"%@,", proname];
        [valueString appendString:@"?,"];
        //【KVC】通过KVC将属性值取出来(运行时配合KVC还真方便)
        id value = [model valueForKey:proname];
        //属性值可能为空
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    //删除最后的那个","
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
    
    [values addObjectsFromArray:insertValues];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
    return sql;
}
/**生成Update的SQL语句*/
- (NSString *)getUpdateSQL:(JKDBModel *)model outForVlaues:(NSMutableArray *)values{
    id primaryValue = [model valueForKey:primaryId];
    if (!primaryValue || primaryValue <= 0) {
        return @"";
    }
    
    NSString *tableName = NSStringFromClass(model.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableArray *updateValues = [NSMutableArray  array];
    for (int i = 0; i < self.columeNames.count; i++) {
        NSString *proname = [self.columeNames objectAtIndex:i];
        if ([proname isEqualToString:primaryId]) {
            continue;
        }
        [keyString appendFormat:@" %@=?,", proname];
        id value = [self valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [updateValues addObject:value];
    }
    [updateValues addObject:primaryValue];
    
    [values addObjectsFromArray:updateValues];
    
    //删除最后那个逗号
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, primaryId];
    
    return sql;
}
/** 数据库中是否存在表 */
+ (BOOL)isExistInTable{
    __block BOOL res = NO;
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        res = [db tableExists:tableName];
    }];
    return res;
}

+ (void)close{
    JKDBHelper *jkDB = [JKDBHelper shareInstance];
    [jkDB close];
}

@end
