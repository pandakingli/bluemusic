//
//  SecurityUtil.h
//  blueMusic
//
//  Created by lining on 2018/7/1.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject
#pragma mark - AES加密
//将string转成带密码的data
+ (NSString*)encryptAESData:(NSString*)string Withkey:(NSString * )key ivkey:(NSString * )ivkey;
//将带密码的data转成string
+(NSString*)decryptAESData:(NSString*)data Withkey:(NSString *)key ivkey:(NSString * )ivkey;


@end
