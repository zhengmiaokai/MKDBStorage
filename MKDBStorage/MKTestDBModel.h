//
//  TestBAseModel1.h
//  Basic
//
//  Created by zhengmiaokai on 16/7/28.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBModel.h"

@interface MKTestDBModel : MKDBModel

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) double time;

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* content;
@property (nonatomic, copy) NSString* desc;

@end
