//
//  MKCryptBase64.h
//  LeCard
//
//  Created by mikazheng on 2020/4/14.
//  Copyright © 2020 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCryptBase64 : NSObject

+ (NSString *)encryptData:(NSData *)data;

+ (NSData *)decryptBase64String:(NSString *)base64String;

@end

NS_ASSUME_NONNULL_END
