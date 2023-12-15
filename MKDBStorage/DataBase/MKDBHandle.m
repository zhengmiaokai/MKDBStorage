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

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel {
    @autoreleasepool {
        NSDictionary* dataDic = [dataBaseModel objectRecordPropertyDictionary];
        NSArray* values = [dataDic allValues];
        NSMutableArray* newValues = [NSMutableArray arrayWithCapacity:values.count];
        for(id value in values) {
            [newValues addObject:[NSString stringWithFormat:@"'%@'",value]];//数据类型可以不用加''
        }
        NSString *queryString = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName,[dataDic.allKeys componentsJoinedByString:@","],[newValues componentsJoinedByString:@","]];
        BOOL success = [self executeUpdate:queryString];
        return success;
    }
}

- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues {
    @autoreleasepool {
        NSDictionary* keyValues = [dataBaseModel objectRecordPropertyDictionary];
        NSString* setStr = @"";
        for (NSString* key in keyValues.allKeys) {
            if (setStr.length == 0) {
                setStr = [setStr stringByAppendingFormat:@" %@ = '%@'", key, keyValues[key]];
            } else {
                setStr = [setStr stringByAppendingFormat:@", %@ = '%@'", key, keyValues[key]];
            }
        }
        NSString* whereStr = @"";
        for (NSString* wkey in wKeyValues.allKeys) {
            if (whereStr.length == 0) {
                whereStr = [whereStr stringByAppendingFormat:@" %@ = '%@'", wkey, wKeyValues[wkey]];
            } else {
                whereStr = [whereStr stringByAppendingFormat:@", %@ = '%@'", wkey, wKeyValues[wkey]];
            }
        }
        NSString *queryString = [NSString stringWithFormat:@"UPDATE %@ SET%@ WHERE%@", tableName, setStr, whereStr];
        BOOL success = [self executeUpdate:queryString];
        return success;
    }
}

- (NSArray *)selectWithQuery:(NSString*)query dataBaseModel:(NSString *)className {
    FMResultSet* result =  [self executeQuery:query]; /*@"select count(*) as count  from countryCodeTable"*/
    NSMutableArray* datas = [NSMutableArray new];
    @autoreleasepool {
        while ([result next]) {
            MKDBModel* dataBaseModel = [[NSClassFromString(className) alloc] initWithDBRes:result];
            [datas addObject:dataBaseModel];
        }
        [result close];
    }
    return datas;
}

- (BOOL)selectWithQuery:(NSString*)query resultBlock:(void(^)(FMResultSet *result))resultBlock {
    BOOL success = NO;
    FMResultSet* result =  [self executeQuery:query]; /* @"select count(*) as count  from countryCodeTable" */
    while ([result next]) {
        success = YES;
        if (resultBlock != nil) {
            resultBlock(result);
        }
        break;
    }
    [result close];
    return success;
}

- (BOOL)deleteWithQuery:(NSString*)query {
    BOOL success = [self executeUpdate:query]; /* delete from tableName where key = value */
    return success;
}

- (BOOL)creatWithTableName :(NSString *)tableName dataBaseModel:(Class)dataBaseClass {
    MKDBModel *dbModel = [[dataBaseClass alloc] init];
    NSString* query = [NSString stringWithFormat:@"create table if not exists %@(%@)", tableName, [dbModel typeStringToCreateTable]];
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

@end
