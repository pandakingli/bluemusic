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

/**
 等待中的任务
 */
@property (nonatomic, strong) NSMutableArray *waitingTasks;

/**
 运行中的任务
 */
@property (nonatomic, strong) NSMutableDictionary *runningTasks;

/**
 同步队列，用来启动新任务
 */
@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;

/**
 响应队列-并发
 */
@property (nonatomic, strong) dispatch_queue_t responseQueue;
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
            
            NSString* uuid = [[NSUUID UUID] UUIDString];
            
            NSString *name = [NSString stringWithFormat:@"com.biubiuBlue.MusicCacheCenter.synchronizationqueue-%@",uuid];
            
            musicCacheCenter.synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
            
            name = [NSString stringWithFormat:@"com.biubiuBlue.MusicCacheCenter.responsequeue-%@", uuid];
            musicCacheCenter.responseQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
            
            musicCacheCenter.waitingTasks = [[NSMutableArray alloc] init];
            musicCacheCenter.runningTasks = [[NSMutableDictionary alloc] init];
            musicCacheCenter.activeRequestCount = 0;
            
        }
    });
    
    return musicCacheCenter;
}

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //TODO set the default HTTP headers
    
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.URLCache = [MusicCacheCenter defaultURLCache];
    
    return configuration;
}

+ (NSURLCache *)defaultURLCache
{
    
    // It's been discovered that a crash will occur on certain versions
    // of iOS if you customize the cache.
    //
    // More info can be found here: https://devforums.apple.com/message/1102182#1102182
    //
    // When iOS 7 support is dropped, this should be modified to use
    // NSProcessInfo methods instead.
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.2" options:NSNumericSearch] == NSOrderedAscending)
    {
        return [NSURLCache sharedURLCache];
    }
    return [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                         diskCapacity:150 * 1024 * 1024
                                             diskPath:@"com.biubiuBlue.MusicCacheCenter"];
}


-(void)tryCacheMusicWithModel:(MusicModel*)mModel
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
    }];

    [self.cacheQueue addOperation:operation];
}
@end
