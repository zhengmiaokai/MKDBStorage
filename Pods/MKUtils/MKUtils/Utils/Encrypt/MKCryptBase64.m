//
//  MKCryptBase64.m
//  LeCard
//
//  Created by mikazheng on 2020/4/14.
//  Copyright © 2020 LC. All rights reserved.
//

#import "MKCryptBase64.h"

@implementation MKCryptBase64

+ (NSString *)encryptData:(NSData *)data {
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    NSString *baseString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    return baseString;
}

+ (NSData *)decryptBase64String:(NSString *)base64String {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

@end
