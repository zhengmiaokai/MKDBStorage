//
//  TestBAseModel1.h
//  Basic
//
//  Created by zhengmiaokai on 16/7/28.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBModel.h"

@interface MKTestDBModel : MKDBModel

@property (nonatomic) NSInteger age;
@property (nonatomic) int height;
@property (nonatomic) float weight;
@property (nonatomic) double time;

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* desc;

@end
