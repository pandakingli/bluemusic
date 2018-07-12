//
//  DownloadSongOneVC.m
//  blueMusic
//
//  Created by lining on 2018/7/12.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "DownloadSongOneVC.h"
#import "MusicModel.h"

@interface DownloadSongOneVC ()

@end

@implementation DownloadSongOneVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)godownloadmodel:(MusicModel*)mmodel
{
    if(mmodel.playurl_mp3)
    {
        // 创建下载路径
        NSURL *url = [NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"];
        
        // 创建NSURLSession对象，并设计代理方法。其中NSURLSessionConfiguration为默认配置
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // 创建任务
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
        
        // 开始任务
        [downloadTask resume];
    }
   
    
}

@end
