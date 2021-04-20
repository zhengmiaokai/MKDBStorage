//
//  MKCryptDES.m
//  Basic
//
//  Created by zhengMK on 2020/4/15.
//  Copyright © 2020 zhengmiaokai. All rights reserved.
//

#import "MKCryptDES.h"
#import "MKCryptBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

#define DES_KEY 0xFA
#define desString(str, key) \
{\
    unsigned char *p = str;\
    while( ((*p) ^=  key) != '\0')  p++;\
}

static Byte kCryptDESIV[] = {1,2,3,4,5,6,7,8};

@implementation MKCryptDES

/* 本地数据加密串 8 */
#define kDESLocalKey ({ \
    unsigned char local_key[] = {(DES_KEY ^ 'l'), (DES_KEY ^ 'e'), (DES_KEY ^ 'x'), (DES_KEY ^ 'i'), (DES_KEY ^ 'n'), \
        (DES_KEY ^ 'l'), (DES_KEY ^ 'e'), (DES_KEY ^ 'k'), (DES_KEY ^ '\0')}; \
    desString(local_key, DES_KEY); \
    unsigned char result[9]; \
    memcpy(result, local_key, 9); \
    [NSString stringWithFormat:@"%s", result]; \
})

+ (NSString *)encryptWithContent:(NSString *)content {
   return [self encryptWithContent:content WithKey:kDESLocalKey];
}

+ (NSString *)decryptWithContent:(NSString *)content {
    return [self decryptWithContent:content WithKey:kDESLocalKey];
}

+ (NSString *)encryptWithContent:(NSString *)content WithKey:(NSString *)key {
    
    if (key.length <= 0 || content.length <= 0) {
        return @"";
    }
    
    NSString *decodeString = nil;
    const char *textBytes = [content UTF8String];
    
    NSUInteger dataLength = strlen(textBytes);
    NSUInteger dataOutAvailible = dataLength + kCCBlockSizeDES;
    
    void *buffer = malloc(dataOutAvailible);
    if (buffer == NULL) {
        return nil;
    }
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          kCryptDESIV,
                                          textBytes,
                                          dataLength,
                                          buffer,
                                          dataOutAvailible,
                                          &numBytesEncrypted);
    
    if (kCCSuccess == cryptStatus) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        decodeString = [MKCryptBase64 encryptData:data];
    }
    
    if (buffer) {
        free(buffer);
        buffer = NULL;
    }
    return decodeString;
}

+ (NSString *)decryptWithContent:(NSString *)content WithKey:(NSString *)key {
    
    if (key.length <= 0 || content.length <= 0) {
        return @"";
    }
    
    NSData* cryptData = [MKCryptBase64 decryptBase64String:content];
    
    NSUInteger dataLength = cryptData.length;
    NSUInteger dataOutAvailible = dataLength + kCCBlockSizeDES;
    
    void *buffer = malloc(dataOutAvailible);
    if (buffer == NULL) {
        return nil;
    }
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          kCryptDESIV,
                                          [cryptData bytes],
                                          [cryptData length],
                                          buffer,
                                          dataOutAvailible,
                                          &numBytesDecrypted);
    
    NSString* encodeString = nil;
    if (kCCSuccess == cryptStatus) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        encodeString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    if (buffer) {
        free(buffer);
        buffer = NULL;
    }
    return encodeString;
}

@end
