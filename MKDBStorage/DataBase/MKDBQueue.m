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

//Users/zhengmiaokai/Library/Developer/CoreSimulator/Devices/37426058-90EB-41A6-85C0-5983E838E395/data/Containers/Data/Application/7E202DA9-6B54-420C-AF18-CFC82F7DA745/Library/Caches/baseDB/base.db

static NSString * const kDBFileName = @"base.db";
static NSString * const kDBFolderName = @"baseDB";


@interface MKDBQueue ()

@property (nonatomic, strong) FMDatabaseQueue* queue;

@property (nonatomic, strong) dispatch_queue_t gcd_queue;

@property (nonatomic, strong) NSMutableDictionary* queues;

@property (nonatomic, strong) NSRecursiveLock* lock;

@end

@implementation MKDBQueue

- (FMDatabaseQueue *)getDbQueue {
    return _queue;
}

- (dispatch_queue_t)get_gcd_queue {
    return  _gcd_queue;
}

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
        NSString* folderPath = [NSFileManager forderPathWithFolderName:kDBFolderName directoriesPath:DocumentPath()];
        self.queue = [[FMDatabaseQueue alloc] initWithPath:
                  [NSFileManager pathWithFileName:kDBFileName foldPath:folderPath]];
        self.gcd_queue = dispatch_queue_create("SerialQueue", NULL);
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (NSMutableDictionary *)queues {
    if (_queues == nil) {
        _queues = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _queues;
}

- (void)addDb:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
    MKDBQueueItem* item = [[MKDBQueueItem alloc] initWithDb:dbName gcdQueue:gcdQueue];
    
    [_lock lock];
    [self.queues setSafeObject:item forKey:[dbName MD5]];
    [_lock unlock];
}

- (FMDatabaseQueue *)getDbQueueWithDbName:(NSString *)dbName {
    [_lock lock];
    MKDBQueueItem* item = [self.queues objectForKey:[dbName MD5]];
    [_lock unlock];
    
    if (item && item.dbQueue) {
        return item.dbQueue;
    }
    return nil;
}

- (dispatch_queue_t)getGcdQueueWithDbName:(NSString *)dbName {
    [_lock lock];
    MKDBQueueItem* item = [self.queues objectForKey:[dbName MD5]];
    [_lock unlock];
    
    if (item && item.gcdQueue) {
        return item.gcdQueue;
    }
    return _gcd_queue;
}

- (void)removeDb:(NSString *)dbName {
    [_lock lock];
    [self.queues removeSafeOjectForKey:[dbName MD5]];
    [_lock unlock];
}

@end

@implementation MKDBQueueItem

- (id)initWithDb:(NSString *)dbName gcdQueue:(dispatch_queue_t)gcdQueue {
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
