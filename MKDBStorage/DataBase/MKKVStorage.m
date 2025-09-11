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


@interface MKKeyValueDBItem : MKDBModel

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;

+ (instancetype)itemWithValue:(NSString *)value forKey:(NSString *)key;
+ (instancetype)itemWithResult:(FMResultSet *)result;

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

- (NSString *)primaryKey {
    return @"key";
}

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
    if ([[NSThread currentThread] isMainThread]) {
        [self createWithTableName:MKKeyValueDBItem.tableName dataBaseModel:MKKeyValueDBItem.class completion:^(BOOL succss) {
            NSLog(@"%@ table is %@.", MKKeyValueDBItem.tableName, succss?@"usable":@"unusable");
        }];
    } else {
        BOOL succss = [self createWithTableName:MKKeyValueDBItem.tableName dataBaseModel:MKKeyValueDBItem.class];
        NSLog(@"%@ table is %@.", MKKeyValueDBItem.tableName, succss?@"usable":@"unusable");
    }
}

#pragma mark - 键值存取（同步） -
- (BOOL)createWithTableName:(NSString *)tableName {
    return [self createWithTableName:tableName dataBaseModel:MKKeyValueDBItem.class];
}

- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key {
    return [self saveValue:value forKey:key tableName:MKKeyValueDBItem.tableName];
}

- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key tableName:(NSString *)tableName {
    MKKeyValueDBItem *storageItem = [MKKeyValueDBItem itemWithValue:value forKey:key];
    LOCK([_storageItems setObject:storageItem forKey:key]);
    
    return [self replaceWithTableName:tableName dataBaseModel:storageItem];
}

- (NSString *)getValueForKey:(NSString *)key {
    return [self getValueForKey:key tableName:MKKeyValueDBItem.tableName];
}

- (NSString *)getValueForKey:(NSString *)key tableName:(NSString *)tableName {
    LOCK(MKKeyValueDBItem *_storageItem = [_storageItems objectForKey:key]);
    
    if (_storageItem) {
        return _storageItem.value;
    } else {
        NSArray *datas =  [self selectWithTableName:tableName dataBaseModel:MKKeyValueDBItem.class where:@{@"key": key}];
        
        MKKeyValueDBItem *storageItem = [datas dbObjectAtIndex:0];
        if (storageItem) {
            LOCK([self.storageItems setObject:storageItem forKey:key]);
        }
        
        return _storageItem.value;
    }
}

- (BOOL)removeValueForKey:(NSString *)key {
    return [self removeValueForKey:key tableName:MKKeyValueDBItem.tableName];
}

- (BOOL)removeValueForKey:(NSString *)key tableName:(NSString *)tableName {
    LOCK([_storageItems removeObjectForKey:key]);
    
    return [self deleteWithTableName:tableName where:@{@"key": key}];
}

#pragma mark - 键值存取（异步） -
- (void)createWithTableName:(NSString *)tableName completion:(void (^)(BOOL))completionHandler {
    [self createWithTableName:tableName dataBaseModel:MKKeyValueDBItem.class completion:completionHandler];
}

- (void)saveValue:(NSString *)value forKey:(NSString *)key completion:(void (^)(BOOL))completionHandler {
    [self saveValue:value forKey:key tableName:MKKeyValueDBItem.tableName completion:completionHandler];
}

- (void)saveValue:(NSString *)value forKey:(NSString *)key tableName:(NSString *)tableName completion:(void (^)(BOOL))completionHandler {
    MKKeyValueDBItem *storageItem = [MKKeyValueDBItem itemWithValue:value forKey:key];
    LOCK([_storageItems setObject:storageItem forKey:key]);
    
    [self replaceWithTableName:tableName dataBaseModel:storageItem completion:completionHandler];
}

- (void)getValueForKey:(NSString *)key completion:(void(^)(NSString *value))completionHandler {
    [self getValueForKey:key tableName:MKKeyValueDBItem.tableName completion:completionHandler];
}

- (void)getValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(void(^)(NSString *value))completionHandler {
    LOCK(MKKeyValueDBItem *_storageItem = [_storageItems objectForKey:key]);
    
    if (_storageItem) {
        if (completionHandler) {
            completionHandler(_storageItem.value);
        }
    } else {
        __block MKKeyValueDBItem *storageItem = nil;
        [self selectWithTableName:tableName dataBaseModel:MKKeyValueDBItem.class where:@{@"key": key} completion:^(NSArray *datas) {
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

- (void)removeValueForKey:(NSString *)key completion:(void (^)(BOOL))completionHandler {
    [self removeValueForKey:key tableName:MKKeyValueDBItem.tableName completion:completionHandler];
}

- (void)removeValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(void (^)(BOOL))completionHandler {
    LOCK([_storageItems removeObjectForKey:key]);
    
    [self deleteWithTableName:tableName where:@{@"key": key} completion:completionHandler];
}

@end
