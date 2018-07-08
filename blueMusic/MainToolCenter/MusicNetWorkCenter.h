//
//  MusicNetWorkCenter.h
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicConstants.h"

@interface MusicNetWorkCenter : NSObject
+(instancetype)shareInstance;


/**
 获取歌单
 */
- (void)netease_RequestPlayListDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishBlock)finishblock;


/**
 根据歌单id获取歌曲
 */
- (void)netease_RequestMusicDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishBlock)finishblock;


/**
 获取歌曲播放Url
 */
- (void)netease_RequestMusicSongurlDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishURLBlock)finishblock;

/**
 获取歌曲歌词
 */
- (void)netease_RequestMusicLyricDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishURLBlock)finishblock;
@end
