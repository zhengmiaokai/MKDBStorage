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
    NSString* query = [NSString stringWithFormat:@"alter table %@ add %@ %@", tableName, fieldName, fieldType];
    BOOL success = [self executeUpdate:query];
    return success;
}

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel {
    @autoreleasepool {
        NSDictionary *keyValues = [dataBaseModel objectRecordPropertyDictionary];
        NSArray *keys = keyValues.allKeys;
        NSMutableArray *positions = [NSMutableArray arrayWithCapacity:keys.count];
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:keys.count];
        for(id key in keys) {
            [positions addObject:@"?"];
            [arguments addObject:keyValues[key]];
        }
        NSString *queryString = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", tableName,
                                 [keys componentsJoinedByString:@", "],
                                 [positions componentsJoinedByString:@", "]];
        BOOL success = [self executeUpdate:queryString withArgumentsInArray:arguments];
        return success;
    }
}

- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues {
    @autoreleasepool {
        NSDictionary* sKeyValues = [dataBaseModel objectRecordPropertyDictionary];
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:sKeyValues.count + wKeyValues.count];
        
        NSMutableArray* setQuerys = [NSMutableArray arrayWithCapacity:sKeyValues.count];
        for (NSString* sKey in sKeyValues.allKeys) {
            [setQuerys addObject:[NSString stringWithFormat:@"%@ = ?", sKey]];
            [arguments addObject:sKeyValues[sKey]];
        }
        
        NSMutableArray* whereQuerys = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        for (NSString* wKey in wKeyValues.allKeys) {
            [whereQuerys addObject:[NSString stringWithFormat:@"%@ = ?", wKey]];
            [arguments addObject:wKeyValues[wKey]];
        }
        NSString *queryString = [NSString stringWithFormat:@"update %@ set %@ where %@", tableName,
                                 [setQuerys componentsJoinedByString:@", "],
                                 [whereQuerys componentsJoinedByString:@" and "]];
        BOOL success = [self executeUpdate:queryString withArgumentsInArray:arguments];
        return success;
    }
}

- (BOOL)updateWithTableName:(NSString *)tableName set:(NSDictionary *)sKeyValues where:(NSDictionary *)wKeyValues {
    @autoreleasepool {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:sKeyValues.count + wKeyValues.count];
        
        NSMutableArray* setQuerys = [NSMutableArray arrayWithCapacity:sKeyValues.count];
        for (NSString* sKey in sKeyValues.allKeys) {
            [setQuerys addObject:[NSString stringWithFormat:@"%@ = ?", sKey]];
            [arguments addObject:sKeyValues[sKey]];
        }
        
        NSMutableArray* whereQuerys = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        for (NSString* wKey in wKeyValues.allKeys) {
            [whereQuerys addObject:[NSString stringWithFormat:@"%@ = ?", wKey]];
            [arguments addObject:wKeyValues[wKey]];
        }
        
        NSString *queryString = [NSString stringWithFormat:@"update %@ set %@ where %@", tableName,
                                 [setQuerys componentsJoinedByString:@", "],
                                 [whereQuerys componentsJoinedByString:@" and "]];
        BOOL success = [self executeUpdate:queryString withArgumentsInArray:arguments];
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
    @autoreleasepool {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        
        NSMutableArray* whereQuerys = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        for (NSString* wKey in wKeyValues.allKeys) {
            [whereQuerys addObject:[NSString stringWithFormat:@"%@ = ?", wKey]];
            [arguments addObject:wKeyValues[wKey]];
        }
        
        NSString *query = [NSString stringWithFormat:@"select * from %@ where %@", tableName,
                           [whereQuerys componentsJoinedByString:@" and "]];
        FMResultSet* result =  [self executeQuery:query withArgumentsInArray:arguments];
        NSMutableArray* datas = [NSMutableArray new];
        while ([result next]) {
            MKDBModel* dataBaseModel = [[dataBaseClass alloc] initWithDBRes:result];
            [datas addObject:dataBaseModel];
        }
        [result close];
        return datas;
    }
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
    @autoreleasepool {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        
        NSMutableArray* whereQuerys = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        for (NSString* wKey in wKeyValues.allKeys) {
            [whereQuerys addObject:[NSString stringWithFormat:@"%@ = ?", wKey]];
            [arguments addObject:wKeyValues[wKey]];
        }
        
        int count = 0;
        NSString *query = [NSString stringWithFormat:@"select count(*) as count from %@ where %@", tableName,
                           [whereQuerys componentsJoinedByString:@" and "]];
        FMResultSet* result =  [self executeQuery:query withArgumentsInArray:arguments];
        while ([result next]) {
            count = [result intForColumn:@"count"];
            break;
        }
        [result close];
        return count;
    }
}

- (BOOL)deleteWithTableName:(NSString *)tableName {
    NSString *query = [NSString stringWithFormat:@"delete from %@", tableName];
    BOOL success = [self executeUpdate:query];
    return success;
}

- (BOOL)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues {
    @autoreleasepool {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        
        NSMutableArray* whereQuerys = [NSMutableArray arrayWithCapacity:wKeyValues.count];
        for (NSString* wKey in wKeyValues.allKeys) {
            [whereQuerys addObject:[NSString stringWithFormat:@"%@ = ?", wKey]];
            [arguments addObject:wKeyValues[wKey]];
        }
        
        NSString *query = [NSString stringWithFormat:@"delete from %@ where %@", tableName,
                           [whereQuerys componentsJoinedByString:@" and "]];
        BOOL success = [self executeUpdate:query withArgumentsInArray:arguments];
        return success;
    }
}

@end
