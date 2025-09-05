//
//  MKDBModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBModel.h"
#import <fmdb/FMDB.h>
#import "NSObject+Additions.h"
#import "NSArray+Additions.h"

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
            NSString* key = [keys dbObjectAtIndex:i];
            NSString* type = [types dbObjectAtIndex:i];
            
            if ([type isEqualToString:@"NSString"]) {
                [self setValue:[res stringForColumn:key] forKey:key];
            } else if ([type isEqualToString:@"i"]) {
                [self setValue:@([res intForColumn:key]) forKey:key];
            } else if ([type isEqualToString:@"q"] || [type isEqualToString:@"Q"]) {
                [self setValue:@([res longForColumn:key]) forKey:key];
            } else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
                [self setValue:@([res doubleForColumn:key]) forKey:key];
            } else if ([type isEqualToString:@"NSData"]) {
                [self setValue:[res dataForColumn:key] forKey:key];
            }
        }
    }
}

+ (NSString *)tableName {
    return NSStringFromClass([self class]);
}

- (BOOL)needPrimaryKey {
    return YES;
}

- (NSString *)typeStrings {
    @autoreleasepool {
        NSArray* propertyKeys = [self generatePropertyKeys];
        NSArray* propertyTypes = [self generatePropertyTypes];
        
        NSMutableArray* typeStrings = [NSMutableArray arrayWithCapacity:propertyTypes.count];
        
        if ([self needPrimaryKey]) {
            [typeStrings addObject: @"id integer primary key autoincrement"];
        }
        
        for (int i=0; i<propertyTypes.count; i++) {
            if ([propertyTypes[i] isEqualToString:@"NSString"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ %@", propertyKeys[i], kFieldTypeString]];
            } else if ([propertyTypes[i] isEqualToString:@"i"] || [propertyTypes[i] isEqualToString:@"q"] || [propertyTypes[i] isEqualToString:@"Q"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ %@", propertyKeys[i], kFieldTypeInt]];
            } else if ([propertyTypes[i] isEqualToString:@"f"] || [propertyTypes[i] isEqualToString:@"d"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ %@", propertyKeys[i], kFieldTypeFloat]];
            } else if ([propertyTypes[i] isEqualToString:@"NSData"]) {
                [typeStrings addObject:[NSString stringWithFormat:@"%@ %@", propertyKeys[i], kFieldTypeData]];
            }
        }
        return [typeStrings componentsJoinedByString:@","];
    }
}

@end


