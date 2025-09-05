//
//  MKKVStorage.m
//  Basic
//
//  Created by zhengmiaokai on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKKVStorage.h"
#import "NSArray+Additions.h"

#define kKVDBName  @"KVStorage.db"

#define LOCK(...) dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self.lock);

/* KV-Model */
@interface MKKeyValueDBItem : MKDBModel

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *value;

+ (instancetype)itemWithValue:(NSString *)value forKey:(NSString *)key;

+ (instancetype)itemWithResult:(FMResultSet *)result;

@end

@interface MKKVStorage ()

@property (nonatomic, strong) NSMutableDictionary *storageItems;

@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation MKKVStorage

+ (instancetype)sharedInstance {
    static MKKVStorage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        dispatch_queue_t serailQueue = dispatch_queue_create("com.KVStorage.serailQueue", NULL);
        sharedInstance = [[self alloc] initWithDBName:kKVDBName serailQueue:serailQueue];
    });
    return sharedInstance;
}

- (instancetype)initWithDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue {
    self = [super initWithDBName:DBName serailQueue:serailQueue];
    if (self) {
        self.storageItems = [[NSMutableDictionary alloc] init];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)onLoad {
    [self createWithTableName:MKKeyValueDBItem.tableName dataBaseModel:[MKKeyValueDBItem class] completion:nil];
}

- (void)saveDataWithValue:(id)value forKey:(NSString *)key {
    [self saveDataWithValue:value forKey:key tableName:nil];
}

- (void)saveDataWithValue:(id)value forKey:(NSString *)key tableName:(NSString *)tableName {
    MKKeyValueDBItem *storageItem = [MKKeyValueDBItem itemWithValue:value forKey:key];
    LOCK([_storageItems setObject:storageItem forKey:key]);
    
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        int count = [db selectCountWithTableName:MKKeyValueDBItem.tableName where:@{@"key": key}];
        if (count == 0) {
            // 新增
            [db insertWithTableName:MKKeyValueDBItem.tableName dataBaseModel:storageItem];
        } else {
            // 更新
            [db updateWithTableName:MKKeyValueDBItem.tableName dataBaseModel:storageItem where:@{@"key": key}];
        }
    } completion:nil];
}

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler {
    [self getValueForKey:key tableName:nil completion:completionHandler];
}

- (void)getValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(MKDBCompletionHandler)completionHandler {
    LOCK(MKKeyValueDBItem *_storageItem = [_storageItems objectForKey:key]);
    
    if (_storageItem) {
        if (completionHandler) {
            completionHandler(_storageItem.value);
        }
    } else {
        __block MKKeyValueDBItem *storageItem = nil;
        [self selectWithTableName:MKKeyValueDBItem.tableName dataBaseModel:MKKeyValueDBItem.class where:@{@"key": key} completion:^(NSArray *datas) {
            storageItem = [datas dbObjectAtIndex:0];
            if (storageItem) {
                LOCK([self.storageItems setObject:storageItem forKey:key]);
            }
            
            if (completionHandler) {
                completionHandler(storageItem.value);
            }
        }];
    }
}

- (void)removeValueForKey:(NSString *)key {
    [self removeValueForKey:key tableName:nil];
}

- (void)removeValueForKey:(NSString *)key tableName:(NSString *)tableName {
    LOCK([_storageItems removeObjectForKey:key]);
    
    [self deleteWithTableName:MKKeyValueDBItem.tableName where:@{@"key": key} completion:nil];
}

- (void)removeValuesForKeys:(NSArray *)keys {
    [self removeValuesForKeys:keys tableName:nil];
}

- (void)removeValuesForKeys:(NSArray *)keys tableName:(NSString *)tableName {
    LOCK([_storageItems removeObjectsForKeys:keys]);
    
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString* key in keys) {
            [db deleteWithTableName:MKKeyValueDBItem.tableName where:@{@"key": key}];
        }
    } completion:nil];
}

@end

@implementation MKKeyValueDBItem

+ (instancetype)itemWithValue:(NSString *)value forKey:(NSString *)key {
    MKKeyValueDBItem* model = [[MKKeyValueDBItem alloc] init];
    model.key = key;
    model.value = value;
    return model;
}

+ (instancetype)itemWithResult:(FMResultSet *)result {
    MKKeyValueDBItem* item = [[MKKeyValueDBItem alloc] init];
    item.key = [result stringForColumn:@"key"];
    item.value = [result stringForColumn:@"value"];
    return item;
}

#pragma mark - MKDBModel -
+ (NSString *)tableName {
    return @"kv_database";
}

- (BOOL)needPrimaryKey {
    return NO;
}

@end
