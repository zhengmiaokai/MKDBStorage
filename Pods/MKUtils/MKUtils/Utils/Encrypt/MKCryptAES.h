//
//  MKCryptAES.h
//  LeCard
//
//  Created by mikazheng on 2020/4/13.
//  Copyright © 2020 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 类名重定义（静态类名：MKCryptKeyEncode），降低反编译代码的可读性 */
#ifndef MKCryptAES
#define MKCryptAES MKCryptKeyEncode
#endif

@interface MKCryptAES : NSObject

+ (NSString *)encryptWithContent:(NSString *)content;
+ (NSString *)decryptWithContent:(NSString *)content;

+ (NSString *)encryptWithContent:(NSString *)content WithKey:(NSString *)key;
+ (NSString *)decryptWithContent:(NSString *)content WithKey:(NSString *)key;

@end
