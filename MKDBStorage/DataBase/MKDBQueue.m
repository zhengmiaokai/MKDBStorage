//
//  MKDBQueue.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/7.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBQueue.h"
#import <MKUtils/NSFileManager+Addition.h>
#import <MKUtils/NSString+Sign.h>
#import <MKUtils/NSDictionary+Additions.h>

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

//Users/lexin/Library/Developer/CoreSimulator/Devices/4B984E3D-F67C-41FE-B198-E329FE726D55/data/Containers/Data/Application/77F23825-BE3F-42F1-AA68-7E5A1D9BF99D/Documents/DBStorage/base.db

#define kDBFileName    @"base.db"
#define kDBFolderName  @"DBStorage"


@interface MKDBQueue ()

@property (nonatomic, strong) NSMutableDictionary *queueItems;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation MKDBQueue

+ (instancetype)shareInstance {
    static MKDBQueue *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *folderPath = [NSFileManager forderPathWithFolderName:kDBFolderName directoriesPath:DocumentPath()];
        NSString *filePath = [NSFileManager pathWithFileName:kDBFileName foldPath:folderPath];
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:filePath];
        
        _gcdQueue = dispatch_queue_create("com.MKDBStorage.queue", NULL);
        
        self.queueItems = [NSMutableDictionary dictionaryWithCapacity:2];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addDbQueue:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    MKDBQueueItem* item = [[MKDBQueueItem alloc] initWithDbName:dbName gcdQueue:gcdQueue];
    LOCK([self.queueItems setSafeObject:item forKey:[dbName MD5]]);
}

- (FMDatabaseQueue *)getDbQueueWithDbName:(NSString *)dbName {
    LOCK(MKDBQueueItem* item = [self.queueItems objectForKey:[dbName MD5]]);
    return item.dbQueue;
}

- (dispatch_queue_t)getGcdQueueWithDbName:(NSString *)dbName {
    LOCK(MKDBQueueItem* item = [self.queueItems objectForKey:[dbName MD5]]);
    if (item && item.gcdQueue) {
        return item.gcdQueue;
    }
    return _gcdQueue;
}

- (void)removeDbQueue:(NSString *)dbName {
    LOCK([self.queueItems removeSafeOjectForKey:[dbName MD5]]);
}

@end

@implementation MKDBQueueItem

- (id)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    self = [super init];
    if (self) {
        NSString* folderPath = [NSFileManager forderPathWithFolderName:kDBFolderName directoriesPath:DocumentPath()];
        self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:
                  [NSFileManager pathWithFileName:dbName foldPath:folderPath]];
        self.gcdQueue = gcdQueue;
    }
    return self;
}

@end
