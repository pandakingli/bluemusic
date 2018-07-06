//
//  MusicConstants.h
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#ifndef MusicConstants_h
#define MusicConstants_h
typedef void(^finishBlock) ();
/**
 *  是否是iphoneX
 */
#define IS_IPHONE_X    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPHONE_NAVIGATIONBAR_HEIGHT  (IS_IPHONE_X ? 88 : 64)
#define IPHONE_STATUSBAR_HEIGHT      (IS_IPHONE_X ? 44 : 20)
#define IPHONE_SAFEBOTTOMAREA_HEIGHT (IS_IPHONE_X ? 34 : 0)
#define IPHONE_TOPSENSOR_HEIGHT      (IS_IPHONE_X ? 32 : 0)

//动态获取设备宽度
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
//iPhone X判断
#define IPHONE_X    ([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 812)
//状态栏高度
#define StatusBar_Height    ([UIApplication sharedApplication].statusBarFrame.size.height + 44)
//底部Tabbar高度
#define Tabbar_Height       (IPHONE_X ? (49 + 34) : 49)
//iPhone X底部高度
#define Tabbar_Bottom_Margin  (IPHONE_X ? 34 : 0)


//字体
#define  kPingFangSCRegular(kk)    ([UIFont fontWithName:@"PingFangSC-Regular" size:kk]?:[UIFont systemFontOfSize:kk])
#define  kPingFangSCBold(kk)    ([UIFont fontWithName:@"PingFangSC-Bold" size:kk]?:[UIFont boldSystemFontOfSize:kk])
#define  kPingFangSemibold(kk)    ([UIFont fontWithName:@"PingFangSC-Semibold" size:kk]?:[UIFont boldSystemFontOfSize:kk])

#define  kPingFangMedium(kk)    ([UIFont fontWithName:@"PingFangSC-Medium" size:kk]?:[UIFont boldSystemFontOfSize:kk])

#endif /* MusicConstants_h */
