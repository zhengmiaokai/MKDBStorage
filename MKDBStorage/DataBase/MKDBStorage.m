//
//  MKDBStorage.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"
#import "MKDBQueue.h"

@interface MKDBStorage ()

@property (nonatomic, strong) FMDatabaseQueue* databaseQueue;
@property (nonatomic, strong) dispatch_queue_t serailQueue;

@end

@implementation MKDBStorage

- (id)init {
    self = [super init];
    if (self) {
        self.databaseQueue = [[MKDBQueue shareInstance] getDatabaseQueueWithDBName:nil];
        self.serailQueue = [[MKDBQueue shareInstance] getSerailQueueWithDBName:nil];
        
        [self onLoad];
    }
    return self;
}

- (instancetype)initWithDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue {
    self = [super init];
    if (self) {
        [[MKDBQueue shareInstance] addDBName:DBName serailQueue:serailQueue];
        self.databaseQueue = [[MKDBQueue shareInstance] getDatabaseQueueWithDBName:DBName];
        self.serailQueue = [[MKDBQueue shareInstance] getSerailQueueWithDBName:DBName];
        
        [self onLoad];
    }
    return self;
}

- (void)onLoad {
    // 创建|更新表信息
}

#pragma mark - 非事务操作 -
- (void)inDatabase:(void (^)(FMDatabase *db))block {
    [self.databaseQueue inDatabase:block];
    [self.databaseQueue close];
}

- (void)inDatabase:(void (^)(FMDatabase *db))block completion:(void (^)(void))completionHandler {
    dispatch_async(self.serailQueue, ^{
        [self.databaseQueue inDatabase:block];
        [self.databaseQueue close];
        
        if (completionHandler) {
            completionHandler();
        }
    });
}

#pragma mark - 事务操作 -
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self.databaseQueue inTransaction:block];
    [self.databaseQueue close];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block completion:(void (^)(void))completionHandler {
    dispatch_async(self.serailQueue, ^{
        [self.databaseQueue inTransaction:block];
        [self.databaseQueue close];
        
        if (completionHandler) {
            completionHandler();
        }
    });
}

#pragma mark - 增删改查（同步） -
- (BOOL)createWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db creatWithTableName:tableName dataBaseModel:dataBaseClass];
    }];
    return success;
}

- (BOOL)createWithTableNames:(NSArray *)tableNames dataBaseModel:(NSArray *)dataBaseClassses {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i=0; i<tableNames.count; i++){
            NSString *tableName  = [tableNames objectAtIndex:i];
            Class dataBaseClasss  = [dataBaseClassses objectAtIndex:i];
            success = [db creatWithTableName:tableName dataBaseModel:dataBaseClasss];
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

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db insertWithTableName:tableName dataBaseModel:dataBaseModel];
    }];
    return success;
}

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModels:(NSArray <MKDBModel *>*)dataBaseModels {
    __block BOOL success = YES;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = NO;
        for (int i=0; i<dataBaseModels.count; i++){
            MKDBModel* dataBaseModel = [dataBaseModels objectAtIndex:i];
            success = [db insertWithTableName:tableName dataBaseModel:dataBaseModel];
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

- (BOOL)replaceWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db replaceWithTableName:tableName dataBaseModel:dataBaseModel];
    }];
    return success;
}

- (BOOL)replaceWithTableName:(NSString *)tableName dataBaseModels:(NSArray <MKDBModel *>*)dataBaseModels {
    __block BOOL success = YES;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        success = NO;
        for (int i=0; i<dataBaseModels.count; i++){
            MKDBModel* dataBaseModel = [dataBaseModels objectAtIndex:i];
            success = [db replaceWithTableName:tableName dataBaseModel:dataBaseModel];
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

- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db updateWithTableName:tableName dataBaseModel:dataBaseModel where:wKeyValues];
    }];
    return success;
}

- (BOOL)updateWithTableName:(NSString *)tableName set:(NSDictionary *)sKeyValues where:(NSDictionary *)wKeyValues {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db updateWithTableName:tableName set:sKeyValues where:wKeyValues];
    }];
    return success;
}

- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass {
    __block NSArray* dataArr;
    [self inDatabase:^(FMDatabase *db) {
        dataArr = [db selectWithTableName:tableName dataBaseModel:dataBaseClass];
    }];
    return dataArr;
}

- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass where:(NSDictionary *)wKeyValues {
    __block NSArray* dataArr;
    [self inDatabase:^(FMDatabase *db) {
        dataArr = [db selectWithTableName:tableName dataBaseModel:dataBaseClass where:wKeyValues];
    }];
    return dataArr;
}

- (int)selectCountWithTableName:(NSString *)tableName {
    __block int count;
    [self inDatabase:^(FMDatabase *db) {
        count = [db selectCountWithTableName:tableName];
    }];
    return count;
}

- (int)selectCountWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues {
    __block int count;
    [self inDatabase:^(FMDatabase *db) {
        count = [db selectCountWithTableName:tableName where:wKeyValues];
    }];
    return count;
}

- (BOOL)deleteWithTableName:(NSString *)tableName {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db deleteWithTableName:tableName];
    }];
    return success;
}

- (BOOL)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db deleteWithTableName:tableName where:wKeyValues];
    }];
    return success;
}

#pragma mark - 增删改查（异步） -
- (void)createWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db creatWithTableName:tableName dataBaseModel:dataBaseClass];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)createWithTableNames:(NSArray *)tableNames dataBaseModel:(NSArray *)dataBaseClassses completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i=0; i<tableNames.count; i++){
            NSString *tableName  = [tableNames objectAtIndex:i];
            Class dataBaseClasss  = [dataBaseClassses objectAtIndex:i];
            success = [db creatWithTableName:tableName dataBaseModel:dataBaseClasss];
            if (success == NO) {
                break;
            }
        }
        
        if (success == NO) {
            *rollback = YES;
        }
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db insertWithTableName:tableName dataBaseModel:dataBaseModel];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)insertWithTableName:(NSString *)tableName dataBaseModels:(NSArray <MKDBModel *>*)dataBaseModels completion:(void (^)(BOOL))completionHandler {
    __block BOOL success = YES;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i=0; i<dataBaseModels.count; i++){
            MKDBModel* dataBaseModel = [dataBaseModels objectAtIndex:i];
            success = [db insertWithTableName:tableName dataBaseModel:dataBaseModel];
            if (success == NO) {
                break;
            }
        }
        
        if (success == NO) {
            *rollback = YES;
        }
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)replaceWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db replaceWithTableName:tableName dataBaseModel:dataBaseModel];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)replaceWithTableName:(NSString *)tableName dataBaseModels:(NSArray <MKDBModel *>*)dataBaseModels completion:(void (^)(BOOL))completionHandler {
    __block BOOL success = YES;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i=0; i<dataBaseModels.count; i++){
            MKDBModel* dataBaseModel = [dataBaseModels objectAtIndex:i];
            success = [db replaceWithTableName:tableName dataBaseModel:dataBaseModel];
            if (success == NO) {
                break;
            }
        }
        
        if (success == NO) {
            *rollback = YES;
        }
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db updateWithTableName:tableName dataBaseModel:dataBaseModel where:wKeyValues];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)updateWithTableName:(NSString *)tableName set:(NSDictionary *)sKeyValues where:(NSDictionary *)wKeyValues completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db updateWithTableName:tableName set:sKeyValues where:wKeyValues];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass completion:(void (^)(NSArray *))completionHandler {
    __block NSArray* dataArr;
    [self inDatabase:^(FMDatabase *db) {
        dataArr = [db selectWithTableName:tableName dataBaseModel:dataBaseClass];
    } completion:^{
        if (completionHandler) {
            completionHandler(dataArr);
        }
    }];
}

- (void)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass where:(NSDictionary *)wKeyValues completion:(void (^)(NSArray *))completionHandler {
    __block NSArray* dataArr;
    [self inDatabase:^(FMDatabase *db) {
        dataArr = [db selectWithTableName:tableName dataBaseModel:dataBaseClass where:wKeyValues];
    } completion:^{
        if (completionHandler) {
            completionHandler(dataArr);
        }
    }];
}

- (void)selectCountWithTableName:(NSString *)tableName completion:(void (^)(int))completionHandler {
    __block int count;
    [self inDatabase:^(FMDatabase *db) {
        count = [db selectCountWithTableName:tableName];
    } completion:^{
        if (completionHandler) {
            completionHandler(count);
        }
    }];
}

- (void)selectCountWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues completion:(void (^)(int))completionHandler {
    __block int count;
    [self inDatabase:^(FMDatabase *db) {
        count = [db selectCountWithTableName:tableName where:wKeyValues];
    } completion:^{
        if (completionHandler) {
            completionHandler(count);
        }
    }];
}

- (void)deleteWithTableName:(NSString *)tableName completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db deleteWithTableName:tableName];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

- (void)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues completion:(void (^)(BOOL))completionHandler {
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db deleteWithTableName:tableName where:wKeyValues];
    } completion:^{
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}

@end
