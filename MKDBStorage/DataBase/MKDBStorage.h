//
//  MKDBStorage.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDBhandle.h"

@protocol MKDBStorage

@required
- (void)onLoad;

@end

@interface MKDBStorage : NSObject <MKDBStorage>

@property (nonatomic, strong, readonly) FMDatabaseQueue* dbQueue;

@property (nonatomic, strong, readonly) dispatch_queue_t gcdQueue;

@property (nonatomic, strong) NSString* tableName;


/// 实例初始化
- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

/// 非事务操作
- (void)inDatabase:(void (^)(FMDatabase *db))block;
- (void)inDatabase:(void (^)(FMDatabase *db))block isAsync:(BOOL)async completion:(void(^)(void))completion;

/// 事务操作
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block isAsync:(BOOL)async completion:(void(^)(void))completion;

#pragma mark - 同步 -
- (BOOL)saveDataWithList:(NSArray <MKDBModel*>*)list table:(NSString *)table;

- (BOOL)saveDataWithData:(MKDBModel *)data table:(NSString *)table;

- (BOOL)deleteWithQuery:(NSString *)query;

- (NSArray *)selectWithQuery:(NSString *)query modelClass:(NSString *)modelClass;

#pragma mark - 异步 -
- (void)saveDataWithList:(NSArray <MKDBModel *>*)list table:(NSString *)table isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack;

- (void)saveDataWithData:(MKDBModel *)data table:(NSString *)table isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack;

- (void)deleteWithQuery:(NSString *)query isAsync:(BOOL)isAsync callBack:(void(^)(BOOL))callBack;

- (void)selectWithQuery:(NSString *)query modelClass:(NSString *)modelClass isAsync:(BOOL)isAsync callBack:(void(^)(NSArray *))callBack;

@end
