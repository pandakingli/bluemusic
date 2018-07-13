//
//  DownloadSongOneVC.m
//  blueMusic
//
//  Created by lining on 2018/7/12.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "DownloadSongOneVC.h"
#import "MusicModel.h"
#import "MusicNetWorkCenter.h"
#import <Masonry/Masonry.h>
#import "MusicDataCenter.h"

@interface DownloadSongOneVC ()<NSURLSessionDownloadDelegate>
@property(nonatomic,strong) MusicModel*musicModel;
@property (nonatomic,strong) UIProgressView *progress;
@property (nonatomic,strong) UILabel *plabel;
@end

@implementation DownloadSongOneVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.progress];
    [self.view addSubview:self.plabel];
    
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(self.view);
    }];
    
    [self.plabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.progress.mas_bottom).with.offset(10);
        make.width.mas_equalTo(self.view);
    }];
}

- (UIProgressView *)progress
{
    if(!_progress)
    {
        _progress = [[UIProgressView alloc]init];
    }
    return _progress;
}

- (UILabel *)plabel
{
    if(!_plabel)
    {
        _plabel = [[UILabel alloc]init];
    }
    
    return _plabel;
}

-(void)godownloadmodel:(MusicModel*)mmodel
{
    
     typeof(self) weakSelf = self;
    
    self.musicModel = mmodel;
    
    NSDictionary*dic = @{@"songid":self.musicModel.songid?:@""};
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    
    [[MusicNetWorkCenter shareInstance] netease_RequestMusicSongurlDataWithParameters:dic andFinishBlock:^(NSString *url) {
        if (weakSelf&&url&&![url isKindOfClass:[NSNull class]])
        {
            weakSelf.musicModel.mp3Url = url;
            weakSelf.musicModel.MP3file_url = url;
            weakSelf.musicModel.playurl_mp3 = url;
            [weakSelf godownloadwithurl:url];
        }
      
    }];
    
}

-(void)godownloadwithurl:(NSString*)url
{
    if(url)
    {
        // 创建下载路径
        NSURL *durl = [NSURL URLWithString:url];
        
        // 创建NSURLSession对象，并设计代理方法。其中NSURLSessionConfiguration为默认配置
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        // 创建任务
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:durl];
        
        // 开始任务
        [downloadTask resume];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSString *createPath = [[MusicDataCenter shareInstance] localMusicPathWithName:self.musicModel.name];
   
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath])
    {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:createPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:createPath error:nil];
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    // 下载进度
    self.progress.progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    self.plabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * totalBytesWritten / totalBytesExpectedToWrite];
}

/**
 *  恢复下载后调用
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}


@end
