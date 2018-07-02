//
//  NSData+Encryption.h
//  blueMusic
//
//  Created by lining on 2018/7/1.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSString;
@interface NSData (Encryption)
- (NSData *)AES128EncryptWithKey:(NSString *) key ivKey:(NSString *)ivkey;//加密
- (NSData *)AES128DecryptWithKey:(NSString *) key ivkey:(NSString * )ivkey;//解密


@end
