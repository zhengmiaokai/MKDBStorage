//
//  MKDBHandle.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBHandle.h"
#import "NSObject+Additions.h"

@implementation FMDatabase (Additions)

- (BOOL)creatWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass {
    MKDBModel *dbModel = [[dataBaseClass alloc] init];
    NSString* query = [NSString stringWithFormat:@"create table if not exists %@(%@)", tableName, [dbModel typeStrings]];
    BOOL success = [self executeUpdate:query];
    return success;
}

- (BOOL)addFieldTableName:(NSString *)tableName fieldName:(NSString *)fieldName fieldType:(NSString *)fieldType {
    NSString* defaultValue = nil;
    if ([fieldType isEqualToString:kFieldTypeInt]) {
        defaultValue = @"default(0)";
    } else {
        defaultValue = @"default('')";
    }
    NSString* query = [NSString stringWithFormat:@"alter table %@ add %@ %@ %@", tableName, fieldName, fieldType, defaultValue];
    BOOL success = [self executeUpdate:query];
    return success;
}

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel {
    @autoreleasepool {
        NSDictionary* dataDic = [dataBaseModel objectRecordPropertyDictionary];
        NSArray* values = [dataDic allValues];
        NSMutableArray* newValues = [NSMutableArray arrayWithCapacity:values.count];
        for(id value in values) {
            [newValues addObject:[NSString stringWithFormat:@"'%@'",value]];//数据类型可以不用加''
        }
        NSString *queryString = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", tableName,[dataDic.allKeys componentsJoinedByString:@","],[newValues componentsJoinedByString:@","]];
        BOOL success = [self executeUpdate:queryString];
        return success;
    }
}

- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues {
    @autoreleasepool {
        NSDictionary* keyValues = [dataBaseModel objectRecordPropertyDictionary];
        NSString* setQuery = @"";
        for (NSString* key in keyValues.allKeys) {
            if (setQuery.length == 0) {
                setQuery = [setQuery stringByAppendingFormat:@" %@ = '%@'", key, keyValues[key]];
            } else {
                setQuery = [setQuery stringByAppendingFormat:@", %@ = '%@'", key, keyValues[key]];
            }
        }
        NSString* whereQuery = @"";
        for (NSString* wkey in wKeyValues.allKeys) {
            if (whereQuery.length == 0) {
                whereQuery = [whereQuery stringByAppendingFormat:@" %@ = '%@'", wkey, wKeyValues[wkey]];
            } else {
                whereQuery = [whereQuery stringByAppendingFormat:@", %@ = '%@'", wkey, wKeyValues[wkey]];
            }
        }
        NSString *queryString = [NSString stringWithFormat:@"update %@ set%@ where%@", tableName, setQuery, whereQuery];
        BOOL success = [self executeUpdate:queryString];
        return success;
    }
}

- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass {
    NSString *query = [NSString stringWithFormat:@"select * from %@", tableName];
    FMResultSet* result =  [self executeQuery:query];
    NSMutableArray* datas = [NSMutableArray new];
    @autoreleasepool {
        while ([result next]) {
            MKDBModel* dataBaseModel = [[dataBaseClass alloc] initWithDBRes:result];
            [datas addObject:dataBaseModel];
        }
        [result close];
    }
    return datas;
}

- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass where:(NSDictionary *)wKeyValues {
    NSString* whereQuery = @"";
    for (NSString* wkey in wKeyValues.allKeys) {
        if (whereQuery.length == 0) {
            whereQuery = [whereQuery stringByAppendingFormat:@" %@ = '%@'", wkey, wKeyValues[wkey]];
        } else {
            whereQuery = [whereQuery stringByAppendingFormat:@", %@ = '%@'", wkey, wKeyValues[wkey]];
        }
    }
    
    NSString *query = [NSString stringWithFormat:@"select * from %@ where%@", tableName, whereQuery];
    FMResultSet* result =  [self executeQuery:query];
    NSMutableArray* datas = [NSMutableArray new];
    @autoreleasepool {
        while ([result next]) {
            MKDBModel* dataBaseModel = [[dataBaseClass alloc] initWithDBRes:result];
            [datas addObject:dataBaseModel];
        }
        [result close];
    }
    return datas;
}

- (int)selectCountWithTableName:(NSString *)tableName {
    int count = 0;
    NSString *query = [NSString stringWithFormat:@"select count(*) as count from %@", tableName];
    FMResultSet* result =  [self executeQuery:query];
    while ([result next]) {
        count = [result intForColumn:@"count"];
        break;
    }
    [result close];
    return count;
}

- (int)selectCountWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues {
    NSString* whereQuery = @"";
    for (NSString* wkey in wKeyValues.allKeys) {
        if (whereQuery.length == 0) {
            whereQuery = [whereQuery stringByAppendingFormat:@" %@ = '%@'", wkey, wKeyValues[wkey]];
        } else {
            whereQuery = [whereQuery stringByAppendingFormat:@", %@ = '%@'", wkey, wKeyValues[wkey]];
        }
    }
    
    int count = 0;
    NSString *query = [NSString stringWithFormat:@"select count(*) as count from %@ where%@", tableName, whereQuery];
    FMResultSet* result =  [self executeQuery:query];
    while ([result next]) {
        count = [result intForColumn:@"count"];
        break;
    }
    [result close];
    return count;
}

- (BOOL)deleteWithTableName:(NSString *)tableName {
    NSString *query = [NSString stringWithFormat:@"delete from %@", tableName];
    BOOL success = [self executeUpdate:query];
    return success;
}

- (BOOL)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues {
    NSString* whereQuery = @"";
    for (NSString* wkey in wKeyValues.allKeys) {
        if (whereQuery.length == 0) {
            whereQuery = [whereQuery stringByAppendingFormat:@" %@ = '%@'", wkey, wKeyValues[wkey]];
        } else {
            whereQuery = [whereQuery stringByAppendingFormat:@", %@ = '%@'", wkey, wKeyValues[wkey]];
        }
    }
    
    NSString *query = [NSString stringWithFormat:@"delete from %@ where%@", tableName, whereQuery];
    BOOL success = [self executeUpdate:query];
    return success;
}

@end
