//
//  MKKVStorage.m
//  Basic
//
//  Created by mikazheng on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKKVStorage.h"
#import <MKUtils/MarcoConstant.h>

#define kMKKVDbName  @"KVStorage.db"

#define LOCK(...) dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self.lock);

/* Storege-Item */
@interface MKStorageItem : NSObject

@property (nonatomic, copy) MKDBCompletionHandler completion;

@property (nonatomic, copy) NSString* value;

+ (instancetype)itemWithCompletion:(MKDBCompletionHandler)completion;

@end

/* KV-Model */
@interface MKKVDBModel : MKDBModel

@property (nonatomic, copy) NSString* key;

@property (nonatomic, copy) NSString* value;

- (instancetype)initWithValue:(NSString *)value forKey:(NSString *)key;

@end

@interface MKKVStorage ()

@property (nonatomic, strong) NSMutableDictionary* storageItems;

@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation MKKVStorage

+ (instancetype)sharedInstance {
    static MKKVStorage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        dispatch_queue_t gcd_queue = dispatch_queue_create("com.MKKVStorage.queue", NULL);
        sharedInstance = [[self alloc] initWithDbName:kMKKVDbName gcdQueue:gcd_queue];
    });
    return sharedInstance;
}

- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    self = [super initWithDbName:dbName gcdQueue:gcdQueue];
    if (self) {
        self.storageItems = [[NSMutableDictionary alloc] init];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)initDatas {
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db tableExists:self.tableName] == NO) {
            [db creatWithTableName:self.tableName dataBaseModel:[MKKVDBModel class]];
        }
    } isAsync:YES completion:nil];
}

- (void)creatTableWithName:(NSString *)tableName {
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db tableExists:tableName] == NO) {
            [db creatWithTableName:tableName dataBaseModel:[MKKVDBModel class]];
        }
    } isAsync:YES completion:nil];
}

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler {
    [self getValueForKey:key tableName:nil completion:completionHandler];
}

- (void)getValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(MKDBCompletionHandler)completionHandler {
    LOCK(MKStorageItem *storegeItem = [_storageItems objectForKey:key]);
    
    if (storegeItem.value) {
        completionHandler(storegeItem.value);
    } else {
        MKStorageItem* storegeItem = [MKStorageItem itemWithCompletion:completionHandler];
        LOCK([_storageItems setObject:storegeItem forKey:key]);
        
        @weakify(self);
        __block BOOL success;
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @strongify(self);
            NSString* query = [NSString stringWithFormat:@"select * from %@ where key = '%@'", (tableName ? tableName : self.tableName), key];
            success = [db selectWithQuery:query resultBlock:^(FMResultSet * _Nonnull result) {
                if (completionHandler) {
                    LOCK(MKStorageItem* _storegeItem = [self.storageItems objectForKey:key]);
                    
                    NSString* valueJson = [result stringForColumn:@"value"];
                    _storegeItem.value = valueJson;
                    
                    [self performSelectorOnMainThread:@selector(p_selectorOnMainThread:) withObject:_storegeItem waitUntilDone:NO];
                }
            }];
        } isAsync:YES completion:^{
            if (!success) {
                LOCK(MKStorageItem* _storegeItem = [self.storageItems objectForKey:key]);
                [self performSelectorOnMainThread:@selector(p_selectorOnMainThread:) withObject:_storegeItem waitUntilDone:NO];
            }
        }];
    }
}

- (void)saveDataWithValue:(id)value forKey:(NSString *)key{
    [self saveDataWithValue:value forKey:key tableName:nil];
}

- (void)saveDataWithValue:(id)value forKey:(NSString *)key tableName:(NSString *)tableName {
    LOCK(MKStorageItem* storegeItem = [_storageItems objectForKey:key]);
    if (storegeItem) {
        storegeItem.value = value;
    }
    
    MKKVDBModel* model = [[MKKVDBModel alloc] initWithValue:value forKey:key];
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* query = [NSString stringWithFormat:@"select * from %@ where key = '%@'", (tableName ? tableName : self.tableName), key];
        if ([db selectWithQuery:query resultBlock:^(FMResultSet * _Nonnull result) {}]) {
            [db updateWithTableName:(tableName ? tableName : self.tableName) dataBaseModel:model where:@{@"key": key}];
        }
        else {
            [db saveWithTableName:(tableName ? tableName : self.tableName) dataBaseModel:model];
        }
    } isAsync:YES completion:nil];
}

- (void)removeForKey:(NSString *)key {
    [self removeForKey:key tableName:nil];
}

- (void)removeForKey:(NSString *)key tableName:(NSString *)tableName {
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* query = [NSString stringWithFormat:@"delete from %@ where key = %@", (tableName ? tableName : self.tableName), key];
        [db deleteWithQuery:query];
    } isAsync:YES completion:nil];
}

- (void)p_selectorOnMainThread:(MKStorageItem *)storegeItem {
    if (storegeItem.completion) {
         storegeItem.completion(storegeItem.value);
    }
}

@end

@implementation MKStorageItem

+ (instancetype)itemWithCompletion:(MKDBCompletionHandler)completion {
    MKStorageItem* item = [[MKStorageItem alloc] init];
    item.completion = completion;
    return item;
}

@end

@implementation MKKVDBModel

- (instancetype)initWithValue:(NSString *)value forKey:(NSString *)key {
    MKKVDBModel* model = [[MKKVDBModel alloc] init];
    model.value = value;
    model.key = key;
    return model;
}

@end
