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

- (void)saveValue:(NSString *)value forKey:(NSString *)key;

- (void)getValueForKey:(NSString *)key completion:(MKDBCompletionHandler)completionHandler;

- (void)removeValueForKey:(NSString *)key;

- (void)removeValuesForKeys:(NSArray *)keys;

@end

@interface MKKVStorage : MKDBStorage <MKKVStorageDelegate>

+ (instancetype)sharedInstance;

@end
