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

- (void)addDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue;

- (FMDatabaseQueue *)getDatabaseQueueWithDBName:(NSString *)DBName;

- (dispatch_queue_t)getSerailQueueWithDBName:(NSString *)DBName;

- (void)removeDBName:(NSString *)DBName;

@end

@interface MKDBQueueItem : NSObject

- (instancetype)initWithDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue;

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) dispatch_queue_t serailQueue;

@end
