//
//  MKArchivesDoubleModel.h
//  Basic
//
//  Created by zhengmiaokai on 16/7/26.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <MKBasic/MKArchivesModel.h>

@interface MKPropertyA : MKArchivesModel

@property (strong, nonatomic) NSString* a;
@property (strong, nonatomic) NSString* b;

@end

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
@property (strong, nonatomic) MKPropertyA* propertyA;

- (void)save_and_find;

@end
