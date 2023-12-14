//
//  MKDBQueue.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/7.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>

@interface MKDBQueue : NSObject

+ (instancetype)shareInstance;

/// 默认DBQueue
@property (nonatomic, strong, readonly) FMDatabaseQueue *dbQueue;

/// 默认GCDQueue
@property (nonatomic, strong, readonly) dispatch_queue_t gcdQueue;

- (void)addDBQueue:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

- (FMDatabaseQueue *)getDbQueueWithDbName:(NSString *)dbName;

- (dispatch_queue_t)getGcdQueueWithDbName:(NSString *)dbName;

- (void)removeDBQueue:(NSString *)dbName;

@end

@interface MKDBQueueItem : NSObject

- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) dispatch_queue_t gcdQueue;

@end
