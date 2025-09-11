//
//  MKKVStorage.h
//  Basic
//
//  Created by zhengmiaokai on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"

@protocol MKKVStorageDelegate <NSObject>

#pragma mark - 键值存取（同步） -
- (BOOL)createWithTableName:(NSString *)tableName;

- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key;
- (BOOL)saveValue:(NSString *)value forKey:(NSString *)key tableName:(NSString *)tableName;

- (NSString *)getValueForKey:(NSString *)key;
- (NSString *)getValueForKey:(NSString *)key tableName:(NSString *)tableName;

- (BOOL)removeValueForKey:(NSString *)key;
- (BOOL)removeValueForKey:(NSString *)key tableName:(NSString *)tableName;

#pragma mark - 键值存取（异步） -
- (void)createWithTableName:(NSString *)tableName completion:(void(^)(BOOL success))completionHandler;

- (void)saveValue:(NSString *)value forKey:(NSString *)key completion:(void(^)(BOOL success))completionHandler;
- (void)saveValue:(NSString *)value forKey:(NSString *)key tableName:(NSString *)tableName completion:(void(^)(BOOL success))completionHandler;

- (void)getValueForKey:(NSString *)key completion:(void(^)(NSString *value))completionHandler;
- (void)getValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(void(^)(NSString *value))completionHandler;

- (void)removeValueForKey:(NSString *)key completion:(void(^)(BOOL success))completionHandler;
- (void)removeValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(void(^)(BOOL success))completionHandler;

@end

@interface MKKVStorage : MKDBStorage <MKKVStorageDelegate>

+ (instancetype)sharedInstance;

@end
