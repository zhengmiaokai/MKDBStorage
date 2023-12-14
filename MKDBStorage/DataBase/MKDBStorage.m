//
//  MKDBStorage.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"
#import "MKDBQueue.h"
#import "NSArray+Additions.h"

@interface MKDBStorage ()

@end

@implementation MKDBStorage

- (id)init {
    self = [super init];
    if (self) {
        _dbQueue = [MKDBQueue shareInstance].dbQueue;
        _gcdQueue = [MKDBQueue shareInstance].gcdQueue;
        
        [self onLoad];
    }
    return self;
}

- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    self = [super init];
    if (self) {
        [[MKDBQueue shareInstance] addDBQueue:dbName gcdQueue:gcdQueue];
        _dbQueue = [[MKDBQueue shareInstance] getDbQueueWithDbName:dbName];
        _gcdQueue = [[MKDBQueue shareInstance] getGcdQueueWithDbName:dbName];
        
        [self onLoad];
    }
    return self;
}

- (void)onLoad {
    // 创建|更新表信息
}

- (NSString *)tableName {
    if (_tableName == nil) {
        _tableName = [NSString stringWithFormat:@"%@_db_table",NSStringFromClass([self class])];
    }
    return _tableName;
}

- (void)inDatabase:(void (^)(FMDatabase *db))block {
    [self inDatabase:block isAsync:NO completion:nil];
}

- (void)inDatabase:(void (^)(FMDatabase *db))block isAsync:(BOOL)async completion:(void(^)(void))completion {
    if (async) {
        dispatch_async(_gcdQueue, ^{
            [self.dbQueue inDatabase:block];
            [self.dbQueue close];
            
            if (completion) {
                completion();
            }
        });
    } else {
        [_dbQueue inDatabase:block];
        [_dbQueue close];
        
        if (completion) {
            completion();
        }
    }
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self inTransaction:block isAsync:NO completion:nil];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block  isAsync:(BOOL)async completion:(void(^)(void))completion {
    if (async) {
        dispatch_async(_gcdQueue, ^{
            [self.dbQueue inTransaction:block];
            [self.dbQueue close];
            
            if (completion) {
                completion();
            }
        });
    } else {
        [_dbQueue inTransaction:block];
        [_dbQueue close];
        
        if (completion) {
            completion();
        }
    }
}

- (BOOL)saveDataWithList:(NSArray <MKDBModel *>*)list table:(NSString *)table {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = NO;
        for (int i=0; i<list.count; i++){
            MKDBModel* data = [list dbObjectAtIndex:i];
            success = [db insertWithTableName:table dataBaseModel:data];
            if (success == NO) {
                break;
            }
        }
        
        if (success == NO) {
            *rollback = YES;
        }
    }];
    return success;
}

- (void)saveDataWithList:(NSArray <MKDBModel *>*)list table:(NSString *)table isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = NO;
        for (int i=0; i<list.count; i++){
            MKDBModel* data = [list dbObjectAtIndex:i];
            success = [db insertWithTableName:table dataBaseModel:data];
            if (success == NO) {
                break;
            }
        }
        
        if (success == NO) {
            *rollback = YES;
        }
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(success);
        }
    }];
}

- (BOOL)saveDataWithData:(MKDBModel *)data table:(NSString *)table {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db insertWithTableName:table dataBaseModel:data];
    }];
    return success;
}

- (void)saveDataWithData:(MKDBModel *)data table:(NSString *)table isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db insertWithTableName:table dataBaseModel:data];
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(success);
        }
    }];
}

- (BOOL)deleteWithQuery:(NSString *)query {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db deleteWithQuery:query];
    }];
    return success;
}

- (void)deleteWithQuery:(NSString *)query isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db deleteWithQuery:query];
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(success);
        }
    }];
}

- (NSArray *)selectWithQuery:(NSString *)query modelClass:(NSString *)modelClass {
    __block NSArray* dataArr;
    [self inDatabase:^(FMDatabase *db) {
        dataArr = [db selectWithQuery:query dataBaseModel:modelClass];
    }];
    return dataArr;
}

- (void)selectWithQuery:(NSString *)query modelClass:(NSString *)modelClass isAsync:(BOOL)isAsync callBack:(void(^)(NSArray *))callBack {
    __block NSArray* dataArr;
    [self inDatabase:^(FMDatabase *db) {
        dataArr = [db selectWithQuery:query dataBaseModel:modelClass];
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(dataArr);
        }
    }];
}

@end
