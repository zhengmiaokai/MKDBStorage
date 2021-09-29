//
//  NSObject+Additions.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/12.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Additions)

/// Hook-IMP
+ (void)swizzMethodOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
- (void)swizzMethodOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

/// GCD相关
- (void)asyncMain:(void(^)(void))block;
- (void)delay:(NSTimeInterval)time block:(void(^)(void))block;

/// 属性获取截止到NSObject-className
- (NSArray*)generatePropertyKeys;
- (NSArray*)generatePropertyTypes;
- (NSDictionary *)objectRecordPropertyDictionary;

/// 检测后端数据有效性
BOOL checkSetAvailable(id components);

@end

@interface NSArray (KeyValue)

- (NSArray *)arrayRecordPropertyArray;

@end

@interface NSDictionary (KeyValue)

- (NSDictionary *)dictionaryRecordPropertyDictionary;

@end
