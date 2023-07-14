//
//  NSDictionary+Additions.m
//  Basic
//
//  Created by zhengMK on 16/4/2.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSMutableDictionary (Additions)

- (void)dbSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)dbRemoveOjectForKey:(id)aKey {
    if (aKey) {
        [self removeObjectForKey:aKey];
    }
}

@end


@implementation NSDictionary (Additions)

- (NSString*)JSONString {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        @try {
            NSError *parseError = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } @catch (NSException *exception) {
            NSLog(@"对象中出现data数据，生成json数据失败");
        } @finally {
            
        }
    } else {
        return nil;
    }
}

@end
