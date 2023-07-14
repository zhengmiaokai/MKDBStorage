//
//  NSFileManager+Additions.h
//  Basic
//
//  Created by zhengmiaokai on 2018/7/6.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Additions)

/* Document目录
 */
NSString* DocumentPath(void);


/** 创建文件夹
 *  folderName 文件夹名
 * directoriesPath 目录路劲
 */
+ (NSString *)folderPathWithFolderName:(NSString*)folderName directoriesPath:(NSString *)directoriesPath;

/** 文件路劲
 *  folderName 文件名
 *  folderPath  文件夹路劲
 */
+ (NSString*)pathWithFileName:(NSString*)fileName foldPath:(NSString*)folderPath;

@end
