//
//  MKTestDBModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/7/28.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKTestDBModel.h"

@implementation MKTestDBModel

#pragma mark - MKDBModel -
+ (NSString *)tableName {
    return @"test_database";
}

- (NSString *)primaryKey {
    return nil;
}

@end
