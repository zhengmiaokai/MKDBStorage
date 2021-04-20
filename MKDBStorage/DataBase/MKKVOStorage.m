//
//  MKKVOStorage.m
//  Basic
//
//  Created by mikazheng on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKKVOStorage.h"
#import <MKUtils/MarcoConstant.h>

/* Storege-Item */
@interface MKStoregeItem : NSObject

@property (nonatomic, copy) MKDBCompletionHandler completion;

@property (nonatomic, copy) NSString* value;

+ (instancetype)itemWithCompletion:(MKDBCompletionHandler)completion;

@end

/* KVO-Model */
@interface MKKVODBModel : MKDBModel

@property (nonatomic, copy) NSString* key;

@property (nonatomic, copy) NSString* value;

- (instancetype)initWithValue:(NSString *)value forKey:(NSString *)key;

@end

static NSString * const kMKKVODbName = @"mk_kvo.db";

@interface MKKVOStorage ()

@property (nonatomic, strong) NSMutableDictionary* storegeItems;

@end

@implementation MKKVOStorage

+ (MKKVOStorage *)sharedInstance {
    static MKKVOStorage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        dispatch_queue_t gcd_queue = dispatch_queue_create("kvo_storage_queue", NULL);
        sharedInstance = [[self alloc] initWithDbName:kMKKVODbName gcdQueue:gcd_queue];
    });
    return sharedInstance;
}

- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    self = [super initWithDbName:dbName gcdQueue:gcdQueue];
    if (self) {
        self.storegeItems = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)initDatas {
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db tableExists:self.tableName] == NO) {
            [db creatWithTableName:self.tableName dataBaseModel:[MKKVODBModel class]];
        }
    } isAsync:YES completion:nil];
}

- (void)creatTableWithName:(NSString *)tableName {
    if (tableName) {
        self.tableName = tableName;
    }
    
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db tableExists:self.tableName] == NO) {
            [db creatWithTableName:self.tableName dataBaseModel:[MKKVODBModel class]];
        }
    } isAsync:YES completion:nil];
}

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler {
    MKStoregeItem* storegeItem = nil;
    @synchronized (self) {
        storegeItem = [self.storegeItems objectForKey:key];
    }
    
    if (storegeItem.value) {
        completionHandler(storegeItem.value);
    } else {
        MKStoregeItem* storegeItem = [MKStoregeItem itemWithCompletion:completionHandler];
        @synchronized (self) {
            [self.storegeItems setObject:storegeItem forKey:key];
        }
        @weakify(self);
        __block BOOL isSuccess;
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @strongify(self);
            NSString* query = [NSString stringWithFormat:@"select * from %@ where key = '%@'", self.tableName, key];
            isSuccess = [db selectWithQuery:query resultBlock:^(FMResultSet * _Nonnull result) {
                if (completionHandler) {
                    NSString* valueJson = [result stringForColumn:@"value"];
                    
                    MKStoregeItem* _storegeItem = [self.storegeItems objectForKey:key];
                    _storegeItem.value = valueJson;
                    
                    [self performSelectorOnMainThread:@selector(p_selectorOnMainThread:) withObject:_storegeItem waitUntilDone:NO];
                }
            }];
            
        } isAsync:YES completion:^{
            if (!isSuccess) {
                 MKStoregeItem* _storegeItem = [self.storegeItems objectForKey:key];
                [self performSelectorOnMainThread:@selector(p_selectorOnMainThread:) withObject:_storegeItem waitUntilDone:NO];
            }
        }];
    }
}

- (void)saveDataWithValue:(id)value forKey:(NSString *)key {
    MKKVODBModel* model = [[MKKVODBModel alloc] initWithValue:value forKey:key];
    
    MKStoregeItem* storegeItem = [self.storegeItems objectForKey:key];
    if (storegeItem) {
        storegeItem.value = value;
    }
    
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* query = [NSString stringWithFormat:@"select * from %@ where key = '%@'", self.tableName, key];
        if ([db selectWithQuery:query resultBlock:^(FMResultSet * _Nonnull result) {}]) {
            [db updateWithTableName:self.tableName dataBaseModel:model where:@{@"key": key}];
        }
        else {
            [db saveWithTableName:self.tableName dataBaseModel:model];
        }
    } isAsync:YES completion:nil];
}

- (void)removeForKey:(NSString *)key {
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* query = [NSString stringWithFormat:@"delete from %@ where key = %@", self.tableName, key];
        [db deleteWithQuery:query];
    } isAsync:YES completion:nil];
}

- (void)p_selectorOnMainThread:(MKStoregeItem *)storegeItem {
    if (storegeItem.completion) {
         storegeItem.completion(storegeItem.value);
    }
}

@end

@implementation MKStoregeItem

+ (instancetype)itemWithCompletion:(MKDBCompletionHandler)completion {
    MKStoregeItem* item = [[MKStoregeItem alloc] init];
    item.completion = completion;
    return item;
}

@end

@implementation MKKVODBModel

- (instancetype)initWithValue:(NSString *)value forKey:(NSString *)key {
    MKKVODBModel* model = [[MKKVODBModel alloc] init];
    model.value = value;
    model.key = key;
    return model;
}

@end
