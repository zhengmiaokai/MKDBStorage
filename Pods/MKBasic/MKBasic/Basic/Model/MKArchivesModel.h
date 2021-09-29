//
//  MKArchivesModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/8.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKBasicModel.h"

/**
 *======================================================================================*
 *coding与copy协议的基类(目前valueForKey:只能提取了class与superClass的属性，所以属性继承不要超过两层)
 *======================================================================================*
 **/

@interface MKArchivesModel : MKBasicModel

@property (nonatomic, copy) NSString* abc;

@end
