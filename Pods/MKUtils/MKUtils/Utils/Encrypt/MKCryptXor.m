//
//  MKCryptXor.m
//  LeCard
//
//  Created by mikazheng on 2020/3/17.
//  Copyright © 2020 LC. All rights reserved.
//

#import "MKCryptXor.h"
#import "MKCryptBase64.h"

@implementation MKCryptXor

#define XOR_KEY 0xFA
#define xorString(str, key) \
{\
    unsigned char *p = str;\
    while( ((*p) ^=  key) != '\0')  p++;\
}

/* 本地数据加密串 */
#define kXorLocalKey ({ \
    unsigned char local_key[] = {(XOR_KEY ^ 'L'), (XOR_KEY ^ 'e'), (XOR_KEY ^ 'K'), \
        (XOR_KEY ^ 'a'), (XOR_KEY ^ 'A'), (XOR_KEY ^ 'p'), (XOR_KEY ^ 'p'), (XOR_KEY ^ '\0')}; \
    xorString(local_key, XOR_KEY);\
    unsigned char result[8]; \
    memcpy(result, local_key, 8); \
    [NSString stringWithFormat:@"%s", result]; \
})

#pragma mark -- 业务方法 --
/** 异或+Base64
*/
+ (NSString *)encryptWithContent:(NSString *)text {
    NSData* data = [text dataUsingEncoding:NSASCIIStringEncoding];
    NSData* encodeData = [self encryptWithData:data withKey:kXorLocalKey];
    NSString* result = [MKCryptBase64 encryptData:encodeData];
    return result;
}

+ (NSString *)decryptWithContent:(NSString *)text {
    NSData* data =  [MKCryptBase64 decryptBase64String:text];
    NSData* decodeData = [self decryptWithData:data withKey:kXorLocalKey];
    NSString* result = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    return result;
}

#pragma mark -- 基础方法 --
+ (NSData *)encryptWithData:(NSData *)data withKey:(NSString *)key {
    // 获取key的长度
    NSInteger length = key.length;

    // 将OC字符串转换为C字符串
    const char *keys = [key cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cKey[length];
    memcpy(cKey, keys, length);

    // 数据初始化，空间未分配 配合使用 appendBytes
    NSMutableData *encryptData = [[NSMutableData alloc] initWithCapacity:length];

    // 获取字节指针
    const Byte *point = data.bytes;

    for (int i = 0; i < data.length; i++) {
        int l = i % length;                     // 算出当前位置字节，要和密钥的异或运算的密钥字节
        char c = cKey[l];
        Byte b = (Byte) ((point[i]) ^ c);       // 异或运算
        [encryptData appendBytes:&b length:1];  // 追加字节
    }
    return encryptData.copy;
}

+ (NSData *)decryptWithData:(NSData *)data withKey:(NSString *)key {
   return [self encryptWithData:data withKey:key];
}

@end
