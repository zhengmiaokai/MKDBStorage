//
//  NSFileManager+Additions.m
//  Basic
//
//  Created by zhengmiaokai on 2018/7/6.
//  Copyright © 2018年 zhengmiaokai. All rights reserved.
//

#import "NSFileManager+Additions.h"

@implementation NSFileManager (Additions)

/* Document目录
 */
NSString* DocumentPath(void) {
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    /*
    [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     */
    return documentPath;
}

/** 创建文件夹
 *  folderName 文件夹名
 * directoriesPath 目录路劲
 */
+ (NSString *)folderPathWithFolderName:(NSString*)folderName directoriesPath:(NSString *)directoriesPath {
    
    NSString* folderPath = [directoriesPath stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Create Audio Directory Failed.");
        }
    }
    return folderPath;
}

/** 文件路劲
 *  folderName 文件名
 *  folderPath  文件夹路劲
 */
+ (NSString*)pathWithFileName:(NSString*)fileName foldPath:(NSString*)folderPath {
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
