//
//  ResponseModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/1.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKBasicModel.h"
#import <objc/runtime.h>
#import <MKUtils/NSObject+Additions.h>
#import <MKUtils/NSDictionary+Additions.h>

@implementation MKBasicModel

- (id)initWithData:(id)data {
    
    if (self = [super init]) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            [self setDataWithDic:data];
        } else if ([data isKindOfClass:[NSArray class]]) {
            [self setDataWithArr:data];
        }
    }
    return self;
}

- (void)setDataWithDic:(NSDictionary *)dic {
    
}

- (void)setDataWithArr:(NSArray *)arr {
    
}

- (NSString *)description {
    @try {
        NSDictionary* dic = [self objectRecordPropertyDictionary];
        
        NSString* jsonString = [dic jsonString];
        
        return jsonString;
    } @catch (NSException *exception) {
        NSLog(@"出现非object属性变量，解析错误");
    } @finally {
        
    }
}


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

- (void)dealloc {
    
}

@end
