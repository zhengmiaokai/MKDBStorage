//
//  MKCryptSha2.m
//  LeCard
//
//  Created by mikazheng on 2021/3/26.
//  Copyright © 2021 LC. All rights reserved.
//

#import "MKCryptHash.h"
#include <CommonCrypto/CommonCrypto.h>
#import "sm3.h"

@implementation MKCryptSha2

+ (NSString *)hashWithString:(NSString *)content {
    NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

@end


@implementation MKCryptSM3

+ (NSString *)hashWithString:(NSString *)content {
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *input = (Byte *)[data bytes];
    int ilen = (int)[data length];
    
    unsigned char output[32];
    sm3_hash(input, ilen, output);//调用sm3算法环节
    
    NSData *aData = [[NSData alloc] initWithBytes:(Byte *)output length:32];
    
    NSData *base64Data = [aData base64EncodedDataWithOptions:0];
    NSString *encodStr = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    return encodStr;
}

@end

@implementation MKCryptMd5

+ (NSString *)hashWithString:(NSString *)content {
    if (content.length == 0) {
        return @"";
    }
    const char *cStr = [content UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *ret = [NSMutableString string];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]]; //X为大写
    }
    return [ret lowercaseString];
}

@end
