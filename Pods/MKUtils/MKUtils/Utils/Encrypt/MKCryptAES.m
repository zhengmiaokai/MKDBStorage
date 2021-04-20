//
//  MKCryptAES.m
//  LeCard
//
//  Created by mikazheng on 2020/4/13.
//  Copyright © 2020 LC. All rights reserved.
//

#import "MKCryptAES.h"
#import "MKCryptBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

#define AES_KEY 0xFA
#define aesString(str, key) \
{\
    unsigned char *p = str;\
    while( ((*p) ^=  key) != '\0')  p++;\
}

NSString const *kLCInitVector = @"A-16-Byte-String";

@implementation MKCryptAES

/* 本地数据加密串 16、24、32 */
#define kAESLocalKey ({ \
    unsigned char local_key[] = {(AES_KEY ^ 'l'), (AES_KEY ^ 'e'), (AES_KEY ^ 'x'), (AES_KEY ^ 'i'), (AES_KEY ^ 'n'), \
        (AES_KEY ^ 'l'), (AES_KEY ^ 'e'), (AES_KEY ^ 'k'), (AES_KEY ^ 'a'), \
        (AES_KEY ^ 'b'), (AES_KEY ^ 'y'), (AES_KEY ^ 't'), (AES_KEY ^ 'e'), \
        (AES_KEY ^ '2'), (AES_KEY ^ '2'), (AES_KEY ^ '1'), (AES_KEY ^ '\0')}; \
    aesString(local_key, AES_KEY); \
    unsigned char result[17]; \
    memcpy(result, local_key, 17); \
    [NSString stringWithFormat:@"%s", result]; \
})

+ (NSString *)encryptWithContent:(NSString *)content {
    return [self encryptWithContent:content WithKey:kAESLocalKey ECB:YES];
}

+ (NSString *)decryptWithContent:(NSString *)content {
    return [self decryptWithContent:content WithKey:kAESLocalKey ECB:YES];
}

+ (NSString *)encryptWithContent:(NSString *)content WithKey:(NSString *)key {
    return [self encryptWithContent:content WithKey:key ECB:YES];
}

+ (NSString *)decryptWithContent:(NSString *)content WithKey:(NSString *)key {
    return [self decryptWithContent:content WithKey:key ECB:YES];
}

+ (NSString *)encryptWithContent:(NSString *)content WithKey:(NSString *)key ECB:(BOOL)isECB {
    
    if(!content || !key) return nil;

    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = contentData.length;
    
    void const *initVectorBytes = [kLCInitVector dataUsingEncoding:NSUTF8StringEncoding].bytes;
    
    size_t dataOutAvailable = dataLength + kCCBlockSizeAES128;
    void *dataOut = malloc(dataOutAvailable);
    if (dataOut == NULL) {
        return nil;
    }
    size_t dataOutMoved = 0;
    
    CCOptions options = isECB?(kCCOptionPKCS7Padding | kCCOptionECBMode):kCCOptionPKCS7Padding;
    //CBC模式 kCCOptionPKCS7Padding
    //ECB模式 kCCOptionPKCS7Padding | kCCOptionECBMode ECB模式不需要初始化向量
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          options, // 模式
                                          [keyData bytes],
                                          keyData.length,
                                          isECB ? NULL : initVectorBytes, //初始向量
                                          [contentData bytes],
                                          contentData.length,
                                          dataOut, // 数据输出
                                          dataOutAvailable, // 数据输出最大size
                                          &dataOutMoved); // 实际数据输出size
    
    NSString *cryptString = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *cryptData = [[NSData alloc] initWithBytes:dataOut length:dataOutMoved];
        if(cryptData.length) {
            cryptString = [MKCryptBase64 encryptData:cryptData];
        }
    }
    free(dataOut);
    dataOut = NULL;
    
    return cryptString;
}

+ (NSString *)decryptWithContent:(NSString *)content WithKey:(NSString *)key ECB:(BOOL)isECB {
    
    if(!content || !key) return nil;

    NSData* contentData = [MKCryptBase64 decryptBase64String:content];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];

    NSUInteger dataLength = contentData.length;

    void const *initVectorBytes = [kLCInitVector dataUsingEncoding:NSUTF8StringEncoding].bytes;

    size_t dataOutAvailable = dataLength + kCCBlockSizeAES128;
    void *dataOut = malloc(dataOutAvailable);
    if (dataOut == NULL) {
        return nil;
    }
    size_t dataOutMoved = 0;

    CCOptions options = isECB? (kCCOptionPKCS7Padding | kCCOptionECBMode) : kCCOptionPKCS7Padding;
    //CBC模式 kCCOptionPKCS7Padding
    //ECB模式 kCCOptionPKCS7Padding | kCCOptionECBMode ECB模式不需要初始化向量
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          options, // 模式
                                          [keyData bytes],
                                          keyData.length,
                                          isECB ? NULL : initVectorBytes, //初始向量
                                          [contentData bytes],
                                          contentData.length,
                                          dataOut, // 数据输出
                                          dataOutAvailable, // 数据输出最大size
                                          &dataOutMoved); // 实际数据输出size

    NSData *decryptData = nil;
    if (cryptStatus == kCCSuccess) {
        decryptData = [[NSData alloc] initWithBytes:dataOut length:dataOutMoved];
    }
    free(dataOut);
    dataOut = NULL;
    
    NSString* decryptString = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    return decryptString;
}


@end
