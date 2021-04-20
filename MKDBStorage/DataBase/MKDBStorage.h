//
//  MKDBStorage.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDBhandle.h"

@interface MKDBStorage : NSObject

@property (nonatomic, strong, readonly) FMDatabaseQueue* queue;

@property (nonatomic, strong, readonly) dispatch_queue_t gcd_queue;

@property (nonatomic, strong) NSString* tableName;

/**
数据库执行者初始化
**/
- (id)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

/// 同步操作
- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

/// 异步串行队列
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
