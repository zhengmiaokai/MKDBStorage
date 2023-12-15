//
//  MKDBHandle.h
//  Basic
//
//  Created by zhengmiaokai on 16/4/21.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>
#import "MKDBModel.h"

#define kFieldTypeString   @"text"
#define kFieldTypeInt      @"integer"
#define kFieldTypeData     @"blob"

@interface FMDatabase (Additions)

/** 插入数据
 *   @param tableName 表名
 *   @param dataBaseModel 数据格式 基于DataBaseModel
 */
- (BOOL)insertWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel;

/** 更新数据
*   @param tableName 表名
*   @param dataBaseModel 数据格式 基于DataBaseModel
*   @param wKeyValues where条件
*/
- (BOOL)updateWithTableName:(NSString *)tableName dataBaseModel:(MKDBModel *)dataBaseModel where:(NSDictionary *)wKeyValues;

/** 查询数据
 *   @param query 查询语句
 *   @param className 数据格式 基于DataBaseModel的类名
 */
- (NSArray *)selectWithQuery:(NSString*)query dataBaseModel:(NSString *)className;

/** 查询数据
 *   @param query 查询语句
 *   @param resultBlock block放回result，在while中调用
 *    返回NO，即为没数据或者没有该返回字段
 */
- (BOOL)selectWithQuery:(NSString*)query resultBlock:(void(^)(FMResultSet *result))resultBlock;

/**  删除数据
 *    @param query 查询语句
 */
- (BOOL)deleteWithQuery:(NSString*)query;

/** 创建表
 *   @param dataBaseClass 数据格式 基于DataBaseModel
 */
- (BOOL)creatWithTableName:(NSString *)tableName dataBaseModel:(Class)dataBaseClass;

/** 添加表字段
 *   @param fieldName 字段名
 */
- (BOOL)addFieldTableName:(NSString *)tableName fieldName:(NSString *)fieldName fieldType:(NSString *)fieldType;

@end
