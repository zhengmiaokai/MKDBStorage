//
//  MKNetworkAccessibity.m
//  Basic
//
//  Created by mikazheng on 2019/6/10.
//  Copyright © 2019 LC. All rights reserved.
//

#import "MKNetworkAccessibity.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCellularData.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#import "NSString+Addition.h"

NSString * const MKNetworkAccessibityNotification = @"networkAccessibityNotification";

typedef NS_ENUM(NSInteger, MKNetworkType) {
    MKNetworkTypeUnknown      = 0,
    MKNetworkTypeOffline      = 1,
    MKNetworkTypeWiFi         = 2,
    MKNetworkTypeCellularData = 3,
};

API_AVAILABLE(ios(9.0))
@interface MKNetworkAccessibity(){
    SCNetworkReachabilityRef _reachabilityRef;
    CTCellularData *_cellularData;
    
    MKNetworkAccessibleState _previousState;
    NetworkAccessibleStateNotifier _networkAccessibleStateNotifier;
    
    NSMutableArray *_becomeActiveCallbacks;
    
    BOOL _checkActiveLaterWhenDidBecomeActive;
    BOOL _checkingActiveLater;
}

@end

@interface MKNetworkAccessibity()

@end


@implementation MKNetworkAccessibity

#pragma mark - Public
+ (void)start {
    [[self sharedInstance] setupNetworkAccessibity];
}

+ (void)stop {
    [[self sharedInstance] cleanNetworkAccessibity];
}

+ (void)setStateDidUpdateNotifier:(void (^)(MKNetworkAccessibleState))block {
    [[self sharedInstance] monitorNetworkAccessibleStateWithCompletionBlock:block];
}

+ (MKNetworkAccessibleState)currentState {
    return [[self sharedInstance] currentState];
}

#pragma mark - Public entity method
+ (MKNetworkAccessibity *)sharedInstance {
    static MKNetworkAccessibity * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setNetworkAccessibleStateDidUpdateNotifier:(NetworkAccessibleStateNotifier)networkAccessibleStateDidUpdateNotifier {
    _networkAccessibleStateNotifier = [networkAccessibleStateDidUpdateNotifier copy];
    [self startCheck];
}

- (void)monitorNetworkAccessibleStateWithCompletionBlock:(void (^)(MKNetworkAccessibleState))block {
    _networkAccessibleStateNotifier = [block copy];
}

- (MKNetworkAccessibleState)currentState {
    return _previousState;
}

#pragma mark - Life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setup
- (void)setupNetworkAccessibity {
    if (_reachabilityRef || _cellularData) {
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    _reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, "223.5.5.5");
    // 此句会触发系统弹出权限询问框
    SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

    _becomeActiveCallbacks = [NSMutableArray array];

    BOOL firstRun = ({
        static NSString * RUN_FLAG = @"LCNetworkAccessibityRunFlag";
        BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:RUN_FLAG];
        if (!value) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RUN_FLAG];
        }
        !value;
    });

    dispatch_block_t startNotifier = ^{
        [self startReachabilityNotifier];

        [self startCellularDataNotifier];
    };

    if (firstRun) {
        // 第一次运行系统会弹框，需要延迟一下在判断，否则会拿到不准确的结果
        // 表现为：ReachabilityNotifier 有一定概率拿到的结果是可以访问, CellularDataNotifier 拿到的是拒绝
        // 这里延时 3 秒再检测是因为某些情况下，弹框存在较长的延时。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitActive:^{
                startNotifier();
            }];
        });
    } else {
        startNotifier();
    }
}

- (void)cleanNetworkAccessibity {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (@available(iOS 9.0, *)) {
        _cellularData.cellularDataRestrictionDidUpdateNotifier = nil;
    } else {
        // Fallback on earlier versions
    }
    _cellularData = nil;
    
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    _reachabilityRef = nil;
    
    [self cancelEnsureActive];
    
    [_becomeActiveCallbacks removeAllObjects];
    _becomeActiveCallbacks = nil;
    
    _previousState = MKNetworkChecking;
    
    _checkActiveLaterWhenDidBecomeActive = NO;
    _checkingActiveLater = NO;
}

- (void)applicationWillResignActive {
    if (_checkingActiveLater) {
        [self cancelEnsureActive];
        _checkActiveLaterWhenDidBecomeActive = YES;
    }
}

- (void)applicationDidBecomeActive {
    if (_checkActiveLaterWhenDidBecomeActive) {
        [self checkActiveLater];
        _checkActiveLaterWhenDidBecomeActive = NO;
    }
}

#pragma mark - Active Checker
/* 如果当前 app 是非可响应状态（一般是启动的时候），则等到 app 激活且保持一秒以上，再回调
   因为启动完成后，2 秒内可能会再次弹出「是否允许 XXX 使用网络」，此时的 applicationState 是 UIApplicationStateInactive）*/
- (void)waitActive:(dispatch_block_t)block {
    [_becomeActiveCallbacks addObject:[block copy]];
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        _checkActiveLaterWhenDidBecomeActive = YES;
    } else {
        [self checkActiveLater];
    }
}

- (void)checkActiveLater {
    _checkingActiveLater = YES;
    [self performSelector:@selector(ensureActive) withObject:nil afterDelay:2 inModes:@[NSRunLoopCommonModes]];
}

- (void)ensureActive {
    _checkingActiveLater = NO;
    for (dispatch_block_t block in _becomeActiveCallbacks) {
        block();
    }
    [_becomeActiveCallbacks removeAllObjects];
}

- (void)cancelEnsureActive {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ensureActive) object:nil];
}

#pragma mark - Reachability
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    MKNetworkAccessibity *networkAccessibity = (__bridge MKNetworkAccessibity *)info;
    if (![networkAccessibity isKindOfClass: [MKNetworkAccessibity class]]) {
        return;
    }
    [networkAccessibity startCheck];
}

// 监听用户从 Wi-Fi 切换到 蜂窝数据，或者从蜂窝数据切换到 Wi-Fi，另外当从授权到未授权，或者未授权到授权也会调用该方法
- (void)startReachabilityNotifier {
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
        SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)startCellularDataNotifier {
    __weak __typeof(self)weakSelf = self;
    if (@available(iOS 9.0, *)) {
        self->_cellularData = [[CTCellularData alloc] init];
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 9.0, *)) {
        self->_cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf startCheck];
            });
        };
    } else {
        // Fallback on earlier versions
    }
}

- (BOOL)currentReachable {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self->_reachabilityRef, &flags)) {
        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Check Accessibity
- (void)startCheck {
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0 || [self currentReachable]) {
        /* iOS 10以下没有网络权限相关的 || currentReachable == YES
         1. 用户选择了 「WALN 与蜂窝移动网」并处于其中一种网络环境下。
         2. 用户选择了 「WALN」并处于 WALN 网络环境下。
         */

        [self notiWithAccessibleState:MKNetworkAccessible];
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        CTCellularDataRestrictedState state = _cellularData.restrictedState;
        
        switch (state) {
            case kCTCellularDataRestricted: {
                // 系统 API 返回 无蜂窝数据访问权限
                [self getCurrentNetworkType:^(MKNetworkType type) {
                    /*  若用户是通过蜂窝数据 或 WLAN 上网，走到这里来 说明权限被关闭**/

                    if (type == MKNetworkTypeCellularData || type == MKNetworkTypeWiFi) {
                        [self notiWithAccessibleState:MKNetworkRestricted];
                    } else {  // 可能开了飞行模式，无法判断
                        [self notiWithAccessibleState:MKNetworkUnknown];
                    }
                }];
                break;
            }
            case kCTCellularDataNotRestricted: // 系统 API 访问有有蜂窝数据访问权限，那就必定有 Wi-Fi 数据访问权限
                [self notiWithAccessibleState:MKNetworkAccessible];
                break;
            case kCTCellularDataRestrictedStateUnknown: {
                // CTCellularData 刚开始初始化的时候，可能会拿到 kCTCellularDataRestrictedStateUnknown 延迟一下再试就好了
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self startCheck];
                });
                break;
            }
            default:
                break;
        };
    } else {
        // Fallback on earlier versions
    }
}

- (void)getCurrentNetworkType:(void(^)(MKNetworkType))block {
    // 根据wifi ip判断是否链接wifi
    if ([self isWiFiEnable]) {
        return block(MKNetworkTypeWiFi);
    }
    MKNetworkType type = [self getNetworkTypeFromStatusBar];
    block(type);
}

- (MKNetworkType)getNetworkTypeFromStatusBar {
    CTTelephonyNetworkInfo* networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    if (networkInfo.currentRadioAccessTechnology) {
        return MKNetworkTypeCellularData;
    } else {
        if ([networkInfo.subscriberCellularProvider.mobileNetworkCode isNotEmpty]) {
            return MKNetworkTypeOffline;
        } else {
            return MKNetworkTypeUnknown;
        }
    }
}

/** 判断用户是否连接到 Wi-Fi
 */
- (BOOL)isWiFiEnable {
    return [self wiFiIPAddress].length > 0;
}

- (NSString *)wiFiIPAddress {
    @try {
        NSString *ipAddress;
        struct ifaddrs *interfaces;
        struct ifaddrs *temp;
        int Status = 0;
        Status = getifaddrs(&interfaces);
        if (Status == 0) {
            temp = interfaces;
            while(temp != NULL) {
                if(temp->ifa_addr->sa_family == AF_INET) {
                    if([[NSString stringWithUTF8String:temp->ifa_name] isEqualToString:@"en0"]) {
                        ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp->ifa_addr)->sin_addr)];
                    }
                }
                temp = temp->ifa_next;
            }
        }
        freeifaddrs(interfaces);
        
        if (ipAddress == nil || ipAddress.length <= 0) {
            return nil;
        }
        return ipAddress;
    } @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark - Callback
- (void)notiWithAccessibleState:(MKNetworkAccessibleState)state {
    if (state != _previousState) {
        _previousState = state;
        
        if (_networkAccessibleStateNotifier) {
            _networkAccessibleStateNotifier(state);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNetworkAccessibityNotification object:nil];
    }
}

@end
