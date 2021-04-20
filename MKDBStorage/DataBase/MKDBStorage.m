//
//  MKDBStorage.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"
#import "MKDBQueue.h"
#import <MKUtils/MarcoConstant.h>
#import <MKUtils/NSArray+Additions.h>

@interface MKDBStorage ()

@end

@implementation MKDBStorage

- (id)init {
    self = [super init];
    if (self) {
        _queue = [[MKDBQueue shareInstance] getDbQueue];
        _gcd_queue = [[MKDBQueue shareInstance] get_gcd_queue];
        
        [self initDatas];
    }
    return self;
}

- (id)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    self = [super init];
    if (self) {
        [[MKDBQueue shareInstance] addDb:dbName gcdQueue:gcdQueue];
        _queue = [[MKDBQueue shareInstance] getDbQueueWithDbName:dbName];
        _gcd_queue = [[MKDBQueue shareInstance] getGcdQueueWithDbName:dbName];
        
        [self initDatas];
    }
    return self;
}

- (void)initDatas { }

- (NSString *)tableName {
    if (_tableName == nil) {
        _tableName = [NSString stringWithFormat:@"%@_db",NSStringFromClass([self class])];
    }
    return _tableName;
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block  isAsync:(BOOL)async completion:(void(^)(void))completion {
    if (async) {
        @weakify(self);
        dispatch_async(_gcd_queue, ^{
            @strongify(self);
            [self.queue inTransaction:block];
            [self.queue close];
            
            if (completion) {
                completion();
            }
        });
    } else {
        [_queue inTransaction:block];
        [_queue close];
        
        if (completion) {
            completion();
        }
    }
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self inTransaction:block isAsync:NO completion:nil];
}

- (BOOL)saveDataWithList:(NSArray <MKDBModel *>*)list table:(NSString *)table {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = NO;
        for (int i=0; i<list.count; i++){
            MKDBModel* data = [list safeObjectAtIndex:i];
            success = [db saveWithTableName:self.tableName dataBaseModel:data];
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
            MKDBModel* data = [list safeObjectAtIndex:i];
            success = [db saveWithTableName:self.tableName dataBaseModel:data];
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
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db saveWithTableName:self.tableName dataBaseModel:data];
        if (success == NO) {
            *rollback = YES;
        }
    }];
    return success;
}

- (void)saveDataWithData:(MKDBModel *)data table:(NSString *)table isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db saveWithTableName:self.tableName dataBaseModel:data];
        if (success == NO) {
            *rollback = YES;
        }
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(success);
        }
    }];
}

- (BOOL)deleteWithQuery:(NSString *)query {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db deleteWithQuery:query];
        if (success == NO) {
            *rollback = YES;
        }
    }];
    return success;
}

- (void)deleteWithQuery:(NSString *)query isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = [db deleteWithQuery:query];
        if (success == NO) {
            *rollback = YES;
        }
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(success);
        }
    }];
}

- (NSArray *)selectWithQuery:(NSString *)query modelClass:(NSString *)modelClass {
    __block NSArray* dataArr;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        dataArr = [db selectWithQuery:query dataBaseModel:modelClass];
    }];
    
    return dataArr;
}

- (void)selectWithQuery:(NSString *)query modelClass:(NSString *)modelClass isAsync:(BOOL)isAsync callBack:(void(^)(NSArray *))callBack {
    __block NSArray* dataArr;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        dataArr = [db selectWithQuery:query dataBaseModel:modelClass];
        
    } isAsync:isAsync completion:^{
        if (callBack) {
            callBack(dataArr);
        }
    }];
}

@end
