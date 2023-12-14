//
//  MKTestDBStorage.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKTestDBStorage.h"

@implementation MKTestDBStorage

- (void)onLoad {
    self.tableName = @"test_db_table";
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db tableExists:self.tableName] == NO) {
            [db creatWithTableName:self.tableName dataBaseModel:[MKTestDBModel class]];
        }
        
        if ( [db columnExists:@"data" inTableWithName:self.tableName] == NO) {
            [db addFieldTableName:self.tableName fieldName:@"data" fieldType:kFieldTypeData];
        }
    } isAsync:YES completion:nil];
}

- (void)saveData:(void(^)(BOOL success))callBack {
    NSLog(@"startDate:=====%.3f",[[NSDate date] timeIntervalSince1970]);
    
    NSMutableArray* mArr = [NSMutableArray arrayWithCapacity:500];
    for (int i=0; i<500; i++) {
        MKTestDBModel* data = [[MKTestDBModel alloc] init];
        data.age = 25;
        data.height = 170;
        data.weight = 128;
        data.name = @"zhengmiaokai";
        data.time = [[NSDate date] timeIntervalSince1970];
        data.title = @"全球最大的截击机，速度超过3马赫配备核导弹";
        data.context = @"YF-12截击机是用来拦截苏联轰炸机的。";
        data.desc = @"如果这款截击机最终服役，那么它很有可能名声大噪，但奈何环境不允许。建造32架的SR-71黑鸟则为人们所熟悉，而当提到YF-12时，许多人却不知道它是何物，甚至将两者相混淆。。YF-12截击机是用来拦截苏联轰炸机的。";
        [mArr addObject:data];
    }
    
    [self saveDataWithList:[mArr copy] table:self.tableName isAsync:YES callBack:^(BOOL success) {
        NSLog(@"endDate:=====%.3f",[[NSDate date] timeIntervalSince1970]);
        if (callBack) {
            callBack(success);
        }
    }];
}

- (void)selectData:(void(^)(NSArray *datas))callBack {
    [self selectWithQuery:[NSString stringWithFormat:@"select * from %@", self.tableName] modelClass:@"MKTestDBModel" isAsync:YES callBack:^(NSArray *datas) {
        if (datas.count > 2700) {//多于2700条数据后删除
            [self deleteWithQuery:[NSString stringWithFormat:@"delete from %@", self.tableName]];
        }
        
        if (callBack) {
            callBack(datas);
        }
    }];
}

@end
