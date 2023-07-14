//
//  NSDictionary+Additions.h
//  Basic
//
//  Created by zhengMK on 16/4/2.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Additions)

- (void)dbSetObject:(id)anObject forKey:(id<NSCopying>)aKey;

- (void)dbRemoveOjectForKey:(id)aKey;

@end


@interface NSDictionary (Additions)

- (NSString*)JSONString;

@end
