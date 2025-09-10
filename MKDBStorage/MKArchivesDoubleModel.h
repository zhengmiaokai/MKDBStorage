//
//  MKArchivesDoubleModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/7/26.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKArchivesModel.h"

@interface MKPropertyModel : MKArchivesModel

@property (nonatomic, copy) NSString* content;

@end

@interface MKArchivesSubModel : MKArchivesModel

@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) int intValue;
@property (nonatomic, assign) float floatValue;

@end

@interface MKArchivesDoubleModel : MKArchivesSubModel

@property (nonatomic, copy) NSString* detail;
@property (nonatomic, strong) MKPropertyModel* property;

- (BOOL)saveData;
- (MKArchivesDoubleModel *)selectData;

@end
