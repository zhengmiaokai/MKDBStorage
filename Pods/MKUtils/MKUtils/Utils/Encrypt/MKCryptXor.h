//
//  MKCryptXor.h
//  LeCard
//
//  Created by mikazheng on 2020/3/17.
//  Copyright © 2020 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* 类名重定义（静态类名：MKCryptDeviceEncode），降低反编译代码的可读性 */
#ifndef MKCryptXor
#define MKCryptXor MKCryptDeviceEncode
#endif

@interface MKCryptXor : NSObject

#pragma mark -- 业务方法 --
/** 异或+Base64
 */
+ (NSString *)encryptWithContent:(NSString *)text;
+ (NSString *)decryptWithContent:(NSString *)text;

#pragma mark -- 基础方法 --
+ (NSData *)encryptWithData:(NSData *)data withKey:(NSString *)key;
+ (NSData *)decryptWithData:(NSData *)data withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
