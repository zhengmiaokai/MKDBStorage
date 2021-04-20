//
//  MKKVOStorage.h
//  Basic
//
//  Created by mikazheng on 2019/11/29.
//  Copyright © 2019 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MKDBCompletionHandler)(id response);

@protocol MKKVOStorageDelegate <NSObject>

- (void)saveDataWithValue:(id)value forKey:(NSString *)key;

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler;

- (void)removeForKey:(NSString *)key;

@end

@interface MKKVOStorage : MKDBStorage <MKKVOStorageDelegate>

+ (MKKVOStorage *)sharedInstance;

- (void)creatTableWithName:(NSString *)tableName;

@end

NS_ASSUME_NONNULL_END
