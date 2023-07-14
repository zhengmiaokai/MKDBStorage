//
//  MKBaseModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/1.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKBaseModel.h"
#import <objc/runtime.h>
#import "NSObject+Additions.h"
#import "NSDictionary+Additions.h"

@implementation MKBaseModel

- (id)initWithData:(id)data {
    self = [super init];
    if (self) {
        [self setPropertyValues:data];
    }
    return self;
}

#pragma mark - MKBaseModel -
- (void)setPropertyValues:(id)data {
    // 属性赋值
}

#pragma mark - NSCopying -
- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    NSArray* arrayProperty = [self generatePropertyKeys];
    
    for (NSString *key in arrayProperty) {
        if ([self valueForKey:key] == nil) {
            continue;
        }
        [copy setValue:[self valueForKey:key] forKey:key];
    }
    return copy;
}

- (NSString *)description {
    @try {
        NSDictionary* dic = [self objectRecordPropertyDictionary];
        NSString* JSONString = [dic JSONString];

        return JSONString;
    } @catch (NSException *exception) {
        NSLog(@"出现非object属性变量，解析错误");
    } @finally {

    }
}

- (void)dealloc {
    
}

@end
