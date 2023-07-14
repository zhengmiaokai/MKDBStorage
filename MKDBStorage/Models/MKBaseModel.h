//
//  MKBaseModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/1.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MKBaseModel

- (void)setPropertyValues:(id)data;

@end

@interface MKBaseModel : NSObject <MKBaseModel, NSCopying>

- (id)initWithData:(id)data;

@end
