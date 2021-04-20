//
//  MKDBModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBModel.h"
#import <MKUtils/NSArray+Additions.h>
#import <MKUtils/NSDictionary+Additions.h>
#import <MKUtils/NSObject+Additions.h>
#import <fmdb/FMDB.h>


@implementation MKDBModel

- (instancetype)initWithDBRes:(FMResultSet *)res {
    self = [super init];
    if (self) {
        [self setDataWithDBRes:res];
    }
    return self;
}

- (void)setDataWithDBRes:(FMResultSet *)res {
    @autoreleasepool {
        NSArray* keys = [self generatePropertyKeys];
        NSArray* types = [self generatePropertyTypes];
        
        for (int i=0; i<keys.count; i++) {
            NSString* key = [keys safeObjectAtIndex:i];
            NSString* type = [types safeObjectAtIndex:i];
            
            if ([type isEqualToString:@"NSString"]) {
                [self setValue:[res stringForColumn:key] forKey:key];
            } else if ([type isEqualToString:@"i"] || [type isEqualToString:@"q"]) {
                [self setValue:@([res intForColumn:key]) forKey:key];
            } else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
                [self setValue:@([res doubleForColumn:key]) forKey:key];
            } else if ([type isEqualToString:@"NSData"]) {
                [self setValue:[res dataForColumn:key] forKey:key];
            }
        }
    }
}

- (NSString *)typeStringToCreateTable {
    @autoreleasepool {
        NSArray* propertyKeys = [self generatePropertyKeys];
        NSArray* propertyTypes = [self generatePropertyTypes];
        
        NSMutableArray* typeStrings = [NSMutableArray arrayWithCapacity:propertyTypes.count];
        
        if ([self isHavePrimaryKey]) {
            [typeStrings addObject: @"id integer primary key autoincrement"];
        }
        
        for (int i=0; i<propertyTypes.count; i++) {
            if ([propertyTypes[i] isEqualToString:@"NSString"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ text", propertyKeys[i]]];
            } else if ([propertyTypes[i] isEqualToString:@"i"] || [propertyTypes[i] isEqualToString:@"q"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ integer", propertyKeys[i]]];
            } else if ([propertyTypes[i] isEqualToString:@"f"] || [propertyTypes[i] isEqualToString:@"d"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ float", propertyKeys[i]]];
            } else if ([propertyTypes[i] isEqualToString:@"NSData"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ blob", propertyKeys[i]]];
            }
        }
        return [typeStrings componentsJoinedByString:@","];
    }
}

- (BOOL)isHavePrimaryKey {
    return YES;
}

@end


