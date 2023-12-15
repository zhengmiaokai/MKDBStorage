//
//  MKDBQueue.m
//  Basic
//
//  Created by zhengmiaokai on 16/4/7.
//  Copyright © 2016年 zhengmiaokai. All rights reserved.
//

#import "MKDBQueue.h"
#import "NSDictionary+Additions.h"
#import "NSFileManager+Additions.h"

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

#define kDBFolderName  @"DBStorage"
#define kDBFileName    @"base.db"

@interface MKDBQueue ()

@property (nonatomic, strong) NSMutableDictionary *queueItems;
@property (nonatomic, strong) dispatch_semaphore_t lock;

@end

@implementation MKDBQueue

+ (instancetype)shareInstance {
    static MKDBQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *folderPath = [NSFileManager folderPathWithFolderName:kDBFolderName directoriesPath:DocumentPath()];
        NSString *filePath = [NSFileManager pathWithFileName:kDBFileName foldPath:folderPath];
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:filePath];
        
        _gcdQueue = dispatch_queue_create("com.DBStorage.queue", NULL);
        
        self.queueItems = [NSMutableDictionary dictionaryWithCapacity:2];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addDBQueue:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    MKDBQueueItem* item = [[MKDBQueueItem alloc] initWithDbName:dbName gcdQueue:gcdQueue];
    LOCK([self.queueItems dbSetObject:item forKey:dbName]);
}

- (FMDatabaseQueue *)getDbQueueWithDbName:(NSString *)dbName {
    LOCK(MKDBQueueItem* item = [self.queueItems objectForKey:dbName]);
    return item.dbQueue;
}

- (dispatch_queue_t)getGcdQueueWithDbName:(NSString *)dbName {
    LOCK(MKDBQueueItem* item = [self.queueItems objectForKey:dbName]);
    if (item && item.gcdQueue) {
        return item.gcdQueue;
    }
    return _gcdQueue;
}

- (void)removeDBQueue:(NSString *)dbName {
    LOCK([self.queueItems dbRemoveOjectForKey:dbName]);
}

@end

@implementation MKDBQueueItem

- (instancetype)initWithDbName:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    self = [super init];
    if (self) {
        NSString* folderPath = [NSFileManager folderPathWithFolderName:kDBFolderName directoriesPath:DocumentPath()];
        self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:
                  [NSFileManager pathWithFileName:dbName foldPath:folderPath]];
        self.gcdQueue = gcdQueue;
    }
    return self;
}

@end
