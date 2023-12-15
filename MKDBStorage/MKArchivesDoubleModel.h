//
//  MKArchivesDoubleModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/7/26.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKArchivesModel.h"

@interface MKPropertyModel : MKArchivesModel

@property (strong, nonatomic) NSString* content;

@end

@interface MKArchivesSubModel : MKArchivesModel

@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) int intValue;
@property (assign, nonatomic) float floatValue;

@end

@interface MKArchivesDoubleModel : MKArchivesSubModel

@property (strong, nonatomic) NSString* detail;
@property (strong, nonatomic) MKPropertyModel* property;

- (BOOL)saveData;

- (MKArchivesDoubleModel *)selectData;

@end
