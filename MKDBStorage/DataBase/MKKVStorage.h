//
//  MKKVStorage.h
//  Basic
//
//  Created by zhengmiaokai on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"

typedef void(^MKDBCompletionHandler)(id response);

@protocol MKKVStorageDelegate

- (void)saveDataWithValue:(NSString *)value forKey:(NSString *)key;
- (void)saveDataWithValue:(NSString *)value forKey:(NSString *)key tableName:(NSString *)tableName;

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler;
- (void)getValueForKey:(NSString *)key tableName:(NSString *)tableName completion:(MKDBCompletionHandler)completionHandler;

- (void)removeValueForKey:(NSString *)key;
- (void)removeValueForKey:(NSString *)key tableName:(NSString *)tableName;

- (void)removeValuesForKeys:(NSArray *)keys;
- (void)removeValuesForKeys:(NSArray *)keys tableName:(NSString *)tableName;

@end

@interface MKKVStorage : MKDBStorage <MKKVStorageDelegate>

+ (instancetype)sharedInstance;

- (void)creatTableWithName:(NSString *)tableName;

@end
