//
//  MKTestDBStorage.h
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBStorage.h"

@interface MKTestDBStorage : MKDBStorage

- (void)insertDatas:(void(^)(BOOL success))callBack;
- (void)selectDatas:(void(^)(NSArray * datas))callBack;
- (void)deleteDatas:(void(^)(BOOL success))callBack;

@end
