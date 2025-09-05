//
//  MKDBModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKBaseModel.h"
@class FMResultSet;

#define kFieldTypeString   @"text"
#define kFieldTypeInt      @"integer"
#define kFieldTypeFloat    @"float"
#define kFieldTypeData     @"blob"

@protocol MKDBModel

+ (NSString *)tableName;

- (NSString *)typeStrings;

- (BOOL)needPrimaryKey;

@end

@interface MKDBModel : NSObject <MKDBModel>

- (instancetype)initWithDBRes:(FMResultSet *)res;

@end

