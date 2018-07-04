//
//  MusicPlayer.h
//  
//
//  Created by biubiu on 15/11/3.
//  Copyright © 2015年 lining. All rights reserved.
//
#import "Headers.h"
#import <Foundation/Foundation.h>

typedef void(^finishBlock) ();

//实时的音乐播放位置
typedef void(^musicPlayTimeBlock) (float);

typedef void(^musicPlayTBlock) (float progress,float currenttime,float cachetime);

typedef void(^musicPlaySBlock) (float progress,NSString* currenttime,NSString* cachetime);

@protocol MusicPlayerHandleDelegate <NSObject>

// 当前音乐播放的时间
- (void)musicPlayTime:(float)time;

// 当前音乐结束播放的代理方法
//- (void)currentMusicDidFinish;

- (void)musicPlayTimecache:(NSString*)time;
@end


@interface MusicPlayerHandle : NSObject

+(instancetype)shareMusicPlayerHandle;

@property(nonatomic,assign) id<MusicPlayerHandleDelegate> delegate;

@property(nonatomic,assign) NSInteger playStatus;

@property(nonatomic,assign) NSInteger index;

//当前播放的歌曲
@property(nonatomic,strong) MusicModel *nowModel;

@property(nonatomic,copy) musicPlaySBlock mptblock;
//开始播放
-(void)playWithURLString:(NSString*)urlString;

//播放
-(void)play;

//暂停
-(void)pause;

//停止
-(void)stop;

//是否在播放
-(BOOL)isPlaying;

//获取播放到的时间
- (void)seekToTime:(float)time;

@end
