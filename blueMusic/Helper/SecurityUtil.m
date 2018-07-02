//
//  SecurityUtil.m
//  blueMusic
//
//  Created by lining on 2018/7/1.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "SecurityUtil.h"
#import "NSData+Encryption.h"
@implementation SecurityUtil
#pragma mark - AES加密
//将string转成带密码的data
+(NSString*)encryptAESData:(NSString*)string Withkey:(NSString *)key ivkey:(NSString *)ivkey
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:key ivKey:ivkey];
    //加密之后编码
    return [self dataTobase64String:encryptedData];;
}
#pragma mark - AES解密
//将带密码的data转成string
+(NSString*)decryptAESData:(NSString*)string Withkey:(NSString *)key ivkey:(NSString *)ivkey
{
    //对数据进行解密
    NSData* result = [[self hexStringToData:string] AES128DecryptWithKey:key ivkey:ivkey];
    if (result && result.length > 0) {
        //加密之后进行编码
        return [[NSString alloc] initWithData:result  encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark - base64位编码 -加密
+ (NSString *)dataTobase64String:(NSData*)data
{
    
    return [data base64EncodedStringWithOptions:0];
    
    
    
}

#pragma mark - 16位编码 -加密
+ (NSString *)dataTohexString:(NSData*)data
{
    
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];//16进制数
        if([newHexStr length]==1)
            hexStr = [NSString        stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString       stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
#pragma mark - 16位编码 -解密
+ (NSData*)hexStringToData:(NSString*)hexString
{
    int j=0;
    Byte bytes[hexString.length];  ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        int_ch = int_ch1+int_ch2;
        //NSLog(@"int_ch=%x",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    //    NSData *newData = [[NSData alloc] initWithBytes:bytes length:j];
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:j];
    //NSLog(@"newData=%@",newData);
    return newData;
}


@end
