//
//  MKArchivesDoubleModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/7/26.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKArchivesDoubleModel.h"

@implementation MKPropertyModel

@end

@implementation MKArchivesSubModel

@end

@implementation MKArchivesDoubleModel

- (BOOL)saveData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:[cachesDir stringByAppendingPathComponent:@"test.plist"]];
    return success;
}

- (MKArchivesDoubleModel *)selectData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    MKArchivesDoubleModel * archivesDoubleData = [NSKeyedUnarchiver unarchiveObjectWithFile:[cachesDir stringByAppendingPathComponent:@"test.plist"]];
    NSLog(@"MKArchivesDoubleModel: ==== %@", archivesDoubleData.description);
    return archivesDoubleData;
}

@end
