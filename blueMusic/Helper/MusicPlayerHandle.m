//
//  MusicPlayer.m
//
//
//  Created by biubiu on 15/11/3.
//  Copyright © 2015年 lining. All rights reserved.
//

#import "MusicPlayerHandle.h"
#import <AVFoundation/AVFoundation.h>

static MusicPlayerHandle *myMusicPlayer=nil;

@interface MusicPlayerHandle()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) NSTimeInterval cacheBuffer;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation MusicPlayerHandle

+(instancetype)shareMusicPlayerHandle
{
    if (myMusicPlayer==nil)
    {
        myMusicPlayer =[[MusicPlayerHandle alloc]init];
        myMusicPlayer.player =[AVPlayer new];
        myMusicPlayer.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    return myMusicPlayer;
}

#pragma mark- 播放操作
-(void)playWithURLString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (self.player.currentItem)
    {
       // AVPlayerItem *item = self.player.currentItem;
       // [item removeObserver:self forKeyPath:@" loadedTimeRanges"];
       
    }
    
    AVPlayerItem *songItem = [[AVPlayerItem alloc] initWithURL:url];
    [songItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];

    [self.player replaceCurrentItemWithPlayerItem:songItem];
   
    [self play];
}



-(void)pause
{
    [self.player pause];
    self.isPlaying = NO;
    [self.timer invalidate];
    self.timer = nil;
}
-(void)stop
{
    [self pause];
    
}

-(BOOL)isPlaying
{
    return _isPlaying;
}

-(void)play
{
    [self.player play];
    self.isPlaying = YES;
    
    if (self.timer == nil)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                      target:self
                                                    selector:@selector(timerAction)
                                                    userInfo:nil
                                                     repeats:YES];
        [self.timer fire];
    }
}

#pragma mark- timerAction
- (void)timerAction
{
    // time.value / time.timescale计算出来当前播放到多少秒了。
    CMTimeValue current = self.player.currentTime.value;
    CMTimeValue total   = self.player.currentTime.timescale;
    float progress = current / total;
    NSString * currentstr = [NSString stringWithFormat:@"%.1fs",progress];
    NSString * cachestr = [NSString stringWithFormat:@"缓冲>>%.1fs",self.cacheBuffer];
    if (self.mptblock)
    {
        self.mptblock(progress, currentstr,cachestr);
    }
}

#pragma mark- 定位到某个时间点
- (void)seekToTime:(float)time
{
    CMTime musicTime = CMTimeMakeWithSeconds(time, self.player.currentTime.timescale);
    
    [self pause];//先暂停
    
    [self.player seekToTime:musicTime completionHandler:^(BOOL finished){
        if (finished)
        {
            [self play];
        }
    }];
}

#pragma mark- 监测
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem * songItem = object;
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        self.cacheBuffer = totalBuffer;
        NSLog(@"共缓冲：%.2f",totalBuffer);
         NSString * cachestr = [NSString stringWithFormat:@"缓冲>>%.1fs",self.cacheBuffer];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(musicPlayTimecache:)])
        {
            [self.delegate musicPlayTimecache:cachestr];
        }
    }
}

-(void)playbackFinished:(id)sender
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(currentMusicDidFinish)])
    {
        [self.delegate currentMusicDidFinish];
    }
}

-(void)playWithFileURL:(NSString*)fileurl
{
    NSURL *movieURL = [NSURL fileURLWithPath:fileurl];
    
    AVPlayerItem *songItem = [AVPlayerItem playerItemWithURL:movieURL];
    
    [self.player replaceCurrentItemWithPlayerItem:songItem];
    
    [self play];
    
}
@end
