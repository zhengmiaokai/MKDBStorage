//
//  MKKVStorage.h
//  Basic
//
//  Created by mikazheng on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"

typedef void(^MKDBCompletionHandler)(id response);

@protocol MKKVStorageDelegate

- (void)saveDataWithValue:(id)value forKey:(NSString *)key;
- (void)saveDataWithValue:(id)value forKey:(NSString *)key tableName:(NSString *)tableName;

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler;
- (void)getValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(MKDBCompletionHandler)completionHandler;

- (void)removeForKey:(NSString *)key;
- (void)removeForKey:(NSString *)key tableName:(NSString *)tableName;

@end

@interface MKKVStorage : MKDBStorage <MKKVStorageDelegate>

+ (instancetype)sharedInstance;

- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue;

- (void)creatTableWithName:(NSString *)tableName;

@end
