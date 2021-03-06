//
//  MKArchivesDoubleModel.m
//  Basic
//
//  Created by zhengmiaokai on 16/7/26.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKArchivesDoubleModel.h"

@implementation MKPropertyA

@end

@implementation MKArchivesSubModel

@end

@implementation MKArchivesSubModelA

@end

@implementation MKArchivesDoubleModel

- (void)save_and_find {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:[cachesDir stringByAppendingPathComponent:@"test.plist"]];
    
    if (success) {
        MKArchivesDoubleModel * archivesDoubleData = [NSKeyedUnarchiver unarchiveObjectWithFile:[cachesDir stringByAppendingPathComponent:@"test.plist"]];
        
        NSLog(@"MKArchivesDoubleModel: ==== %@", archivesDoubleData.description);
    }
}

@end
