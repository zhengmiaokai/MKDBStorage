//
//  MKDBModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKBaseModel.h"
@class FMResultSet;

@interface MKDBModel : MKBaseModel

- (instancetype)initWithDBRes:(FMResultSet *)res;

- (NSString *)typeStringToCreateTable;

- (BOOL)isHavePrimaryKey;

@end

