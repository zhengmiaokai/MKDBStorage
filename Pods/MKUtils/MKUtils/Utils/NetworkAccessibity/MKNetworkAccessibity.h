//
//  MKNetworkAccessibity.h
//  Basic
//
//  Created by mikazheng on 2019/6/10.
//  Copyright © 2019 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const LCNetworkAccessibityChangedNotification;

typedef NS_ENUM(NSUInteger, MKNetworkAccessibleState) {
    MKNetworkChecking   = 0,
    MKNetworkUnknown    = 1,
    MKNetworkAccessible = 2,
    MKNetworkRestricted = 3,
};

typedef void (^NetworkAccessibleStateNotifier)(MKNetworkAccessibleState state);

@interface MKNetworkAccessibity : NSObject

/** 通过block方式监控网络权限变化。
 */
+ (void)setStateDidUpdateNotifier:(void (^)(MKNetworkAccessibleState))block;

/** 开启-NetworkAccessibity
 */
+ (void)start;

/** 停止-NetworkAccessibity
 */
+ (void)stop;

/** 返回的是最近一次的网络状态检查结果，若距离上一次检测结果短时间内网络授权状态发生变化，该值可能会不准确。
 */
+ (MKNetworkAccessibleState)currentState;

@end

/* 示例
   [MKNetworkAccessibity setStateDidUpdateNotifier:^(MKNetworkAccessibleState state) {
      if (state == LCNetworkRestricted) {
         // 网络权限引导弹窗
      }
   }];
   [MKNetworkAccessibity start];
 */
