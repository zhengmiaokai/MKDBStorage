//
//  MKDBHandle.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <fmdb/FMDB.h>
#import "MKDBModel.h"

@interface FMDatabase (Additions)

/** 创建表
 *  @param tableName     表名
 *  @param dataBaseClass 数据模型
 */
- (BOOL)creatWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass;

/** 添加表字段
 *  @param tableName 表名
 *  @param fieldName 字段名
 *  @param fieldType 字段类型
 */
- (BOOL)addFieldTableName:(NSString *)tableName fieldName:(NSString *)fieldName fieldType:(NSString *)fieldType;

/** 插入数据
 *  @param tableName     表名
 *  @param dataBaseModel 数据模型
 */
- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel;

/** 更新数据
*   @param tableName     表名
*   @param dataBaseModel 数据模型
*   @param wKeyValues    条件
*/
- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues;

/** 查询数据
*   @param tableName     表名
*   @param dataBaseClass 数据模型
*/
- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass;

/** 查询数据
*   @param tableName     表名
*   @param dataBaseClass 数据模型
*   @param wKeyValues    条件
*/
- (NSArray *)selectWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass where:(NSDictionary *)wKeyValues;

/** 查询数量
*   @param tableName 表名
*/
- (int)selectCountWithTableName:(NSString *)tableName;

/** 查询数量
*   @param tableName  表名
*   @param wKeyValues 条件
*/
- (int)selectCountWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues;

/** 删除数据
*   @param tableName 表名
*/
- (BOOL)deleteWithTableName:(NSString *)tableName;

/** 删除数据
*   @param tableName  表名
*   @param wKeyValues 条件
*/
- (BOOL)deleteWithTableName:(NSString *)tableName where:(NSDictionary *)wKeyValues;

@end
