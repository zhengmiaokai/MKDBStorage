//
//  MKTestDBStorage.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"
#import "MKTestDBModel.h"

@interface MKTestDBStorage : MKDBStorage

- (NSArray*)selectData;

- (void)saveData;

@end
