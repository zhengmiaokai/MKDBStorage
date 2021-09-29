//
//  MKArchivesDoubleModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/7/26.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <MKBasic/MKArchivesModel.h>

@interface MKArchivesSubModel : MKArchivesModel

@property (strong, nonatomic) NSString* nihao;
@property (strong, nonatomic) NSString* dajiahao;

@end

@interface MKArchivesSubModelA: MKArchivesSubModel

@property (strong, nonatomic) NSString* nihaoA;
@property (strong, nonatomic) NSString* dajiahaoA;

@end

@interface MKArchivesDoubleModel : MKArchivesSubModelA

@property (strong, nonatomic) NSString* wohao;
@property (strong, nonatomic) NSString* tahao;

- (void)save_and_find;

@end
