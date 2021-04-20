//
//  MKCryptRSA.h
//  LeCard
//
//  Created by mikazheng on 2020/4/13.
//  Copyright © 2020 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* 类名重定义（静态类名：MKCryptSignEncode），降低反编译代码的可读性 */
#ifndef MKCryptRSA
#define MKCryptRSA MKCryptSignEncode
#endif

#define MKCryptEncrypt(str, key) [MKCryptRSA decryptString:str publicKey:key];

@interface MKCryptRSA : NSObject

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;

+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;

+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)privKey;

@end

NS_ASSUME_NONNULL_END
