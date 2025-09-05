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

#define kDBFolderName  @"sqlite_database"
#define kDBFileName    @"DBStorage.db"


@interface MKDBQueueItem : NSObject

- (instancetype)initWithDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue;

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) dispatch_queue_t serailQueue;

@end

@implementation MKDBQueueItem

- (instancetype)initWithDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue {
    self = [super init];
    if (self) {
        NSString* folderPath = [NSFileManager folderPathWithFolderName:kDBFolderName directoriesPath:DocumentPath()];
        self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:
                  [NSFileManager pathWithFileName:DBName foldPath:folderPath]];
        self.serailQueue = serailQueue;
    }
    return self;
}

@end


@interface MKDBQueue ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@property (nonatomic, strong) dispatch_queue_t serailQueue;

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
        self.databaseQueue = [[FMDatabaseQueue alloc] initWithPath:filePath];
        
        self.serailQueue = dispatch_queue_create("com.DBStorage.serailQueue", NULL);
        
        self.queueItems = [NSMutableDictionary dictionaryWithCapacity:2];
        self.lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addDBName:(NSString *)DBName serailQueue:(dispatch_queue_t)serailQueue {
    if (!DBName) return;
    
    MKDBQueueItem* item = [[MKDBQueueItem alloc] initWithDBName:DBName serailQueue:serailQueue];
    LOCK([self.queueItems setObject:item forKey:DBName]);
}

- (FMDatabaseQueue *)getDatabaseQueueWithDBName:(NSString *)DBName {
    if (!DBName) return self.databaseQueue;
    
    LOCK(MKDBQueueItem* item = [self.queueItems objectForKey:DBName]);
    if (item && item.databaseQueue) {
        return item.databaseQueue;
    }
    return self.databaseQueue;
}

- (dispatch_queue_t)getSerailQueueWithDBName:(NSString *)DBName {
    if (!DBName) return self.serailQueue;
    
    LOCK(MKDBQueueItem* item = [self.queueItems objectForKey:DBName]);
    if (item && item.serailQueue) {
        return item.serailQueue;
    }
    return self.serailQueue;
}

- (void)removeDBName:(NSString *)DBName {
    if (!DBName) return;

    LOCK([self.queueItems removeObjectForKey:DBName]);
}

@end
