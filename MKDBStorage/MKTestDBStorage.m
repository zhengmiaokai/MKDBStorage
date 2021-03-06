//
//  MKTestDBStorage.m
//  Basic
//
//  Created by zhengmiaokai on 16/5/11.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKTestDBStorage.h"

@implementation MKTestDBStorage

- (void)initDatas {
    
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

- (void)saveData {
    
    NSLog(@"startDate:=====%.2f",[[NSDate date] timeIntervalSince1970]);
    
    NSMutableArray* mArr = [NSMutableArray arrayWithCapacity:500];
    
    for (int i=0; i<500; i++) {
        MKTestDBModel* data = [MKTestDBModel new];
        data.age = 25;
        data.height = 170;
        data.weight = 127;
        data.time = [[NSDate date] timeIntervalSince1970];
        data.name = @"郑淼楷";
        data.title = @"全球最大的截击机，速度超过3马赫配备核导弹";
        data.context = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
        data.desc = @"如果这款截击机最终服役，那么它很有可能名声大噪，但奈何环境不允许。建造32架的SR-71黑鸟则为人们所熟悉，而当提到YF-12时，许多人却不知道它是何物，甚至将两者相混淆。。YF-12截击机是用来拦截苏联轰炸机的。";
        [mArr addObject:data];
    }
    
    [self saveDataWithList:[mArr copy] table:self.tableName isAsync:YES callBack:^(BOOL success) {
        NSLog(@"endDate:=====%.2f",[[NSDate date] timeIntervalSince1970]);
    }];
}

- (NSArray*) selectData {
    
    NSArray* dataArr = [self selectWithQuery:[NSString stringWithFormat:@"select * from %@", self.tableName] modelClass:@"MKTestDBModel"];
    
    if (dataArr.count > 2700) {//多于2700条数据后删除
        [self deleteWithQuery:[NSString stringWithFormat:@"delete from %@", self.tableName]];
    }
    
    return dataArr;
}

@end
