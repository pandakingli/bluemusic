//
//  MusicCacheCenter.m
//  blueMusic
//
//  Created by biubiublue on 2018/7/8.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "MusicCacheCenter.h"
#import "MusicModel.h"
#import <AFNetworking/AFNetworking.h>
static MusicCacheCenter *musicCacheCenter=nil;

@interface MusicCacheCenter()
@property(nonatomic,strong)NSOperationQueue *cacheQueue;

/**
 最大同时下载线程数目
 */
@property (nonatomic, assign) NSInteger maximumActiveDownloads;


/**
 当前活动的下载线程数目
 */
@property (nonatomic, assign) NSInteger activeRequestCount;
@end

@implementation MusicCacheCenter
+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (musicCacheCenter == nil)
        {
            musicCacheCenter = [[MusicCacheCenter alloc]init];
            musicCacheCenter.cacheQueue = [[NSOperationQueue alloc]init];
            musicCacheCenter.cacheQueue.maxConcurrentOperationCount = 1;
        }
    });
    
    return musicCacheCenter;
}

-(void)tryCacheMusicWithModel:(MusicModel*)mModel
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
    }];

    [self.cacheQueue addOperation:operation];
}
@end
