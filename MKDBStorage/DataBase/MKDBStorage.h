//
//  MKDBStorage.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDBHandle.h"

@protocol MKDBStorage

- (void)onLoad;

@end

@interface MKDBStorage : NSObject <MKDBStorage>

/// 实例初始化
- (instancetype)initWithDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue;

#pragma mark - 非事务操作 -
- (void)inDatabase:(void (^)(FMDatabase *db))block;
- (void)inDatabase:(void (^)(FMDatabase *db))block completion:(void(^)(void))completionHandler;

#pragma mark - 事务操作 -
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block completion:(void(^)(void))completionHandler;

#pragma mark - 增删改查（同步） -
- (BOOL)createWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass;

- (BOOL)createWithTableNames:(NSArray *)tableNames dataBaseModel:(NSArray *)dataBaseClassses;

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel;

- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModels:(NSArray <MKDBModel *>*)dataBaseModels;

- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues;

- (BOOL)updateWithTableName:(NSString *)tableName set:(NSDictionary *)sKeyValues where:(NSDictionary *)wKeyValues;

- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass;

- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass where:(NSDictionary *)wKeyValues;

- (int)selectCountWithTableName:(NSString *)tableName;

- (int)selectCountWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues;

- (BOOL)deleteWithTableName:(NSString *)tableName;

- (BOOL)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues;

#pragma mark - 增删改查（异步） -
- (void)createWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass completion:(void (^)(BOOL))completionHandler;

- (void)createWithTableNames:(NSArray *)tableNames dataBaseModel:(NSArray *)dataBaseClassses completion:(void (^)(BOOL))completionHandler;

- (void)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel completion:(void (^)(BOOL))completionHandler;

- (void)insertWithTableName:(NSString *)tableName dataBaseModels:(NSArray <MKDBModel *>*)dataBaseModels completion:(void (^)(BOOL))completionHandler;

- (void)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues completion:(void (^)(BOOL))completionHandler;

- (void)updateWithTableName:(NSString *)tableName set:(NSDictionary *)sKeyValues where:(NSDictionary *)wKeyValues completion:(void (^)(BOOL))completionHandler;

- (void)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass completion:(void (^)(NSArray *))completionHandler;

- (void)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass where:(NSDictionary *)wKeyValues completion:(void (^)(NSArray *))completionHandler;

- (void)selectCountWithTableName:(NSString *)tableName completion:(void (^)(int))completionHandler;

- (void)selectCountWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues completion:(void (^)(int))completionHandler;

- (void)deleteWithTableName:(NSString *)tableName completion:(void (^)(BOOL))completionHandler;

- (void)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues completion:(void (^)(BOOL))completionHandler;

@end
