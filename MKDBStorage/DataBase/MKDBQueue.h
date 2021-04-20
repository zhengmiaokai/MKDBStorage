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
- (FMDatabaseQueue *)getDbQueue;

/// 默认GCDQueue
- (dispatch_queue_t)get_gcd_queue;

- (void)addDb:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

- (FMDatabaseQueue *)getDbQueueWithDbName:(NSString *)dbName;

- (dispatch_queue_t)getGcdQueueWithDbName:(NSString *)dbName;

- (void)removeDb:(NSString *)dbName;

@end

@interface MKDBQueueItem : NSObject

- (id)initWithDb:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

@property (nonatomic, strong) FMDatabaseQueue* dbQueue;
@property (nonatomic, strong) dispatch_queue_t gcdQueue;

@end
