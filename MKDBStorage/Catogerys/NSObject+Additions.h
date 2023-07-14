//
//  NSObject+Additions.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/12.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Additions)

/// 属性获取截止到NSObject-className
- (NSArray*)generatePropertyKeys;
- (NSArray*)generatePropertyTypes;

- (NSDictionary *)objectRecordPropertyDictionary;

@end

@interface NSArray (KeyValue)

- (NSArray *)arrayRecordPropertyArray;

@end

@interface NSDictionary (KeyValue)

- (NSDictionary *)dictionaryRecordPropertyDictionary;

@end
