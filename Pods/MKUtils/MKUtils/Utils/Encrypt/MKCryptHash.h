//
//  MKCryptSha2.h
//  LeCard
//
//  Created by mikazheng on 2021/3/26.
//  Copyright © 2021 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MKCryptSM3
#define MKCryptSM3 MKCryptValueData
#endif

#ifndef MKCryptSha2
#define MKCryptSha2 MKCryptValueEncode
#endif

#ifndef MKCryptMd5
#define MKCryptMd5 MKCryptKeyValueEncode
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MKCryptSha2 : NSObject

+ (NSString *)hashWithString:(NSString *)content;

@end

@interface MKCryptSM3 : NSObject

+ (NSString *)hashWithString:(NSString *)content;

@end

@interface MKCryptMd5 : NSObject

+ (NSString *)hashWithString:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
