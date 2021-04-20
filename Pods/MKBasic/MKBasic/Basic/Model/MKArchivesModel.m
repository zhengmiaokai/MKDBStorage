//
//  MKArchivesModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/8.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKArchivesModel.h"
#import <MKUtils/NSObject+Additions.h>

@implementation MKArchivesModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray* property = [self generatePropertyKeys];
    for (NSString *key in property) {
        [self DataBase_encodeData:aCoder data:[self valueForKey:key] dataKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSArray* property = [self generatePropertyKeys];
        for (NSString *key in property) {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

-(void)DataBase_encodeData:(NSCoder *)aCoder data:(id)data dataKey:(NSString*)dataKey
{
    if ([data isKindOfClass:[NSObject class]]) {
        [aCoder encodeObject:data forKey:dataKey];
    } else {
        [aCoder encodeInteger:(NSInteger)data forKey:dataKey];
    }
}

@end
