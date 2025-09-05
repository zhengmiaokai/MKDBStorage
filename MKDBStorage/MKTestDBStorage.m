//
//  MKTestDBStorage.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKTestDBStorage.h"
#import "MKTestDBModel.h"

@implementation MKTestDBStorage

- (void)onLoad {
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db tableExists:MKTestDBModel.tableName] == NO) {
            [db creatWithTableName:MKTestDBModel.tableName dataBaseModel:MKTestDBModel.class];
        }
        
        if ( [db columnExists:@"data" inTableWithName:MKTestDBModel.tableName] == NO) {
            [db addFieldTableName:MKTestDBModel.tableName fieldName:@"data" fieldType:kFieldTypeData];
        }
    } completion:nil];
}

- (void)saveData:(void(^)(BOOL success))callBack {
    NSLog(@"saveData-startTime: %.3f",[[NSDate date] timeIntervalSince1970]);
    
    NSMutableArray* datas = [NSMutableArray arrayWithCapacity:500];
    for (int i=0; i<500; i++) {
        MKTestDBModel* data = [[MKTestDBModel alloc] init];
        data.age = 25;
        data.height = 175;
        data.weight = 142;
        data.name = @"Peter";
        data.time = [[NSDate date] timeIntervalSince1970];
        data.title = @"标题";
        data.content = @"文本内容";
        data.desc = @"这是一段描述。";
        [datas addObject:data];
    }
    
    [self insertWithTableName:MKTestDBModel.tableName dataBaseModels:[datas copy] completion:^(BOOL success) {
        NSLog(@"saveData-endTime: %.3f",[[NSDate date] timeIntervalSince1970]);
        if (callBack) {
            callBack(success);
        }
    }];
}

- (void)selectData:(void(^)(NSArray *datas))callBack {
    [self selectWithTableName:MKTestDBModel.tableName dataBaseModel:MKTestDBModel.class completion:^(NSArray *datas) {
        if (datas.count > 2700) {//多于2700条数据后删除
            [self deleteWithTableName:MKTestDBModel.tableName];
        }
        
        if (callBack) {
            callBack(datas);
        }
    }];
}

@end
