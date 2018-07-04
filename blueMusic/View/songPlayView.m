//
//  songPlayView.m
//  
//
//  Created by biubiu on 15/12/23.
//  Copyright © 2015年 biubiu. All rights reserved.
//

#import "songPlayView.h"
#import "MusicModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <bluebox/bluebox.h>
#import "MusicPlayerHandle.h"
#import "MusicDataHandle.h"

#import "BlueMusicPlayListModel.h"
#import <AFNetworking/AFNetworking.h>
#import <bluebox/bluebox.h>
#import "SecurityUtil.h"
#import "NSData+Encryption.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <TFHpple/TFHpple.h>
#import "BlueMusicPlayListModel.h"
#import "MBProgressHUD.h"
#import "MusicPlayerViewController.h"

//屏幕宽度
#define kSCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//屏幕高度
#define kSCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

typedef void(^finishURLBlock)(NSString *url);

@interface songPlayView ()<UITableViewDataSource, UITableViewDelegate,MusicPlayerHandleDelegate>
@property (strong, nonatomic)  UILabel *SongName;
@property (strong, nonatomic)  UILabel *SingerName;

@property (strong, nonatomic)  UIImageView *blurIMV;
@property (strong, nonatomic)  UIImageView *coverIMV;
@property (strong, nonatomic)  UITableView *lyricsTable;
@property (strong, nonatomic)  UIScrollView *bgSV;

@property (strong, nonatomic)  UIButton *modeBtn;
@property (strong, nonatomic)  UIButton *lastBtn;
@property (strong, nonatomic)  UIButton *playBtn;
@property (strong, nonatomic)  UIButton *nextBtn;
@property (strong, nonatomic)  UIButton *backBtn;
@property (strong, nonatomic)  UISlider *progressBar;

@property (strong, nonatomic)  UILabel *timeNow;//当前播放时间
@property (strong, nonatomic)  UILabel *timeTotal;//歌曲长度
@property (strong, nonatomic)  UILabel *timeCache;//缓冲长度

@property(nonatomic,strong)MusicPlayerHandle *corePlayer;

@property(nonatomic,strong)MusicModel *musicModel;
@property (nonatomic, assign) NSInteger index;
@end

static songPlayView *MusicPlayeViewCenter = nil;

@implementation songPlayView

+(instancetype)getDefaultMusicPlayView
{
    songPlayView *v = [songPlayView shareMusicPlayView];
    [MusicPlayerHandle shareMusicPlayerHandle].delegate = v;
    CGFloat x,y,w,h;
    x = 0;
    y = 0;
    w = kSCREEN_WIDTH;
    h = kSCREEN_HEIGHT;
    CGRect r_rect = (CGRect){x,y,w,h};
    v.frame = r_rect;
    
    return v;
}

+(instancetype)shareMusicPlayView
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (MusicPlayeViewCenter == nil)
        {
            MusicPlayeViewCenter = [[songPlayView alloc]init];
        }
    });
    
    return MusicPlayeViewCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self p_setupViews];
    }
    return self;
}

-(void)p_setupViews
{
    [self addmysubviews];
    [self addmyconstrains];
}

-(void)addmysubviews
{
    self.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.backBtn];
    [self addSubview:self.SongName];
    [self addSubview:self.SingerName];
    
    [self addSubview:self.bgSV];
    [self.bgSV addSubview:self.blurIMV];
    [self.bgSV addSubview:self.coverIMV];
    [self.bgSV addSubview:self.lyricsTable];
    
    [self addSubview:self.timeNow];
    [self addSubview:self.timeCache];
    [self addSubview:self.timeTotal];
    [self addSubview:self.progressBar];
    
    [self addSubview:self.modeBtn];
    [self addSubview:self.lastBtn];
    [self addSubview:self.playBtn];
    [self addSubview:self.nextBtn];
}

-(void)addmyconstrains
{
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(100);
    }];
    
    [self.SongName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.backBtn.mas_bottom);
    }];
    
    [self.SingerName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.SongName.mas_bottom).with.offset(5);
    }];
    
    [self.bgSV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(0.4*kSCREEN_HEIGHT);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0.2*kSCREEN_HEIGHT);
    }];
    
    [self.blurIMV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.bgSV);
        make.height.mas_equalTo(self.bgSV);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    [self.coverIMV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(240);
        make.height.mas_equalTo(240);
        make.center.mas_equalTo(0);
    }];
    
    [self.lyricsTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.bgSV);
        make.height.mas_equalTo(self.bgSV);
        make.centerY.mas_equalTo(self.bgSV);
        make.left.mas_equalTo(self.blurIMV.mas_right);
    }];
    
    
    [self.timeNow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
        make.top.mas_equalTo(self.bgSV.mas_bottom).with.offset(20);
        make.left.mas_equalTo(20);
        
    }];
    
    [self.timeCache mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(15);
        make.top.mas_equalTo(self.bgSV.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(0);
        
    }];
    
    [self.timeTotal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(15);
        make.centerY.mas_equalTo(self.timeNow.mas_centerY);
        make.right.mas_equalTo(-10);
    }];
    
    [self.progressBar mas_makeConstraints:^(MASConstraintMaker *make) {

        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.bgSV.mas_bottom).with.offset(20);
        make.left.mas_equalTo(self.timeNow.mas_right).with.offset(5);
        make.right.mas_equalTo(self.timeTotal.mas_left).with.offset(-5);
    }];
    
 
    
    [self.timeNow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
        make.top.mas_equalTo(self.bgSV.mas_bottom).with.offset(20);
        make.left.mas_equalTo(20);
        
    }];
    
    [self.modeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(self.progressBar.mas_bottom).with.offset(10);
        make.left.mas_equalTo(20);
    }];
    
    [self.lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.modeBtn.mas_centerY);
        make.left.mas_equalTo(self.modeBtn.mas_right).with.offset(10);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.modeBtn.mas_centerY);
        make.left.mas_equalTo(self.lastBtn.mas_right).with.offset(10);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.modeBtn.mas_centerY);
        make.left.mas_equalTo(self.playBtn.mas_right).with.offset(10);
    }];
    
}

-(UIImageView*)coverIMV
{
    if (!_coverIMV)
    {
        _coverIMV = [[UIImageView alloc]init];
        _coverIMV.layer.masksToBounds=YES;
        _coverIMV.layer.cornerRadius =120;
        _coverIMV.layer.anchorPoint=CGPointMake(0.5, 0.5);
    }
    return _coverIMV;
}

-(UIImageView*)blurIMV
{
    if (!_blurIMV)
    {
        _blurIMV = [[UIImageView alloc]init];
        
    }
    return _blurIMV;
}

-(UIScrollView*)bgSV
{
    if (!_bgSV)
    {
        _bgSV = [[UIScrollView alloc]init];
        _bgSV.bounces = NO;
        _bgSV.pagingEnabled=YES;
        _bgSV.backgroundColor = [UIColor whiteColor];
        _bgSV.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
        _bgSV.contentSize =CGSizeMake(2*kSCREEN_WIDTH, 0);
        _bgSV.showsHorizontalScrollIndicator=NO;
        _bgSV.showsVerticalScrollIndicator=NO;
        _bgSV.alwaysBounceHorizontal = NO;
        _bgSV.alwaysBounceVertical   = NO;
        [_bgSV setContentOffset:CGPointMake(0, 0)];
        
    }
    
    return _bgSV;
}

-(UITableView*)lyricsTable
{
    if (!_lyricsTable)
    {
        _lyricsTable = [[UITableView alloc]init];
        
        [_lyricsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"_lyricsTableUITableViewCell"];
        _lyricsTable.delegate=self;
        _lyricsTable.dataSource=self;
        
        
    }
    
    return _lyricsTable;
}

-(UILabel*)SingerName
{
    if (!_SingerName)
    {
        _SingerName = [[UILabel alloc]init];
        _SingerName.textAlignment = NSTextAlignmentCenter;
        _SingerName.font = [UIFont systemFontOfSize:10];
    }
    
    return _SingerName;
}

-(UILabel*)SongName
{
    if (!_SongName)
    {
        _SongName = [[UILabel alloc]init];
        _SongName.textAlignment = NSTextAlignmentCenter;
        _SongName.font = [UIFont systemFontOfSize:15];
    }
    
    return _SongName;
}

-(UIButton*)backBtn
{
    if (!_backBtn)
    {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_backBtn setBackgroundColor:[UIColor orangeColor]];
        [_backBtn addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UISlider*)progressBar
{
    if (!_progressBar)
    {
        _progressBar = [[UISlider alloc]init];
    }
    return _progressBar;
}

-(UIButton*)modeBtn
{
    if (!_modeBtn)
    {
        _modeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modeBtn setTitle:@"播放模式" forState:UIControlStateNormal];
        [_modeBtn setBackgroundColor:[UIColor orangeColor]];
        [_modeBtn addTarget:self action:@selector(modButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modeBtn;
}

-(UIButton*)lastBtn
{
    if (!_lastBtn)
    {
        _lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lastBtn setTitle:@"上一首" forState:UIControlStateNormal];
        [_lastBtn setBackgroundColor:[UIColor orangeColor]];
        [_lastBtn addTarget:self action:@selector(lastSongClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastBtn;
}

-(UIButton*)playBtn
{
    if (!_playBtn)
    {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_playBtn setBackgroundColor:[UIColor orangeColor]];
        [_playBtn addTarget:self action:@selector(playSongAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

-(UIButton*)nextBtn
{
    if (!_nextBtn)
    {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitle:@"下一首" forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:[UIColor orangeColor]];
        [_nextBtn addTarget:self action:@selector(nextSongClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

-(UILabel*)timeNow
{
    if (!_timeNow)
    {
        _timeNow = [[UILabel alloc]init];
        _timeNow.textAlignment = NSTextAlignmentCenter;
        _timeNow.font = [UIFont systemFontOfSize:12];
        _timeNow.backgroundColor = [UIColor orangeColor];
    }
    
    return _timeNow;
}

-(UILabel*)timeCache
{
    if (!_timeCache)
    {
        _timeCache = [[UILabel alloc]init];
        _timeCache.textAlignment = NSTextAlignmentCenter;
        _timeCache.font = [UIFont systemFontOfSize:12];
        _timeCache.backgroundColor = [UIColor orangeColor];
    }
    
    return _timeCache;
}

-(UILabel*)timeTotal
{
    if (!_timeTotal)
    {
        _timeTotal = [[UILabel alloc]init];
        _timeTotal.textAlignment = NSTextAlignmentCenter;
        _timeTotal.font = [UIFont systemFontOfSize:12];
        _timeTotal.backgroundColor = [UIColor orangeColor];
    }
    
    return _timeTotal;
}

- (MusicPlayerHandle *)corePlayer
{
    if (!_corePlayer)
    {
         _corePlayer = [MusicPlayerHandle shareMusicPlayerHandle];
    }
    
    return _corePlayer;
}

#pragma mark-- 滑动
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x <= 0)
    {
        CGPoint offset = scrollView.contentOffset;
        offset.y = 0;
        scrollView.contentOffset = offset;
    }
}

-(void)showProgress {
    [MBProgressHUD showHUDAddedTo:self animated:YES];
}

-(void)hideProgress {
    [MBProgressHUD hideHUDForView:self animated:YES];
}


#pragma mark-- 更新数据
-(void)updateSongList:(NSArray*)arr andindex:(NSInteger)index
{
    MusicDataHandle *hm = [MusicDataHandle shareMusicDataHandle];
    hm.musicArray = arr.mutableCopy;
    if (index<arr.count)
    {
        MusicModel *m = [hm musicWithIndex:index];
        [self updatesongmodel:m];
    }
}

-(void)updatesongmodel:(MusicModel*)model
{
    if (model)
    {
        self.musicModel = model;
        self.SongName.text   = model.name;
        self.SingerName.text = model.singer;
        
        NSURL *songicon = [NSURL URLWithString:model.picUrl];
        UIImage *pp = [UIImage imageNamed:@"defaultmusic"];
        
        [self.coverIMV sd_setImageWithURL:songicon
                         placeholderImage:pp
                                  options:SDWebImageProgressiveDownload];
        
        NSURL *songback = [NSURL URLWithString:model.picurl_blur];
        
        [self.blurIMV sd_setImageWithURL:songback];
        
         typeof(self) weakSelf = self;
        
        [self showProgress];
        
        [self getNetDataFromWangyiWithsongid:self.musicModel.songid WithFinishBlock:^(NSString *url) {
            if (weakSelf&&url)
            {
                weakSelf.musicModel.mp3Url = url;
                weakSelf.musicModel.MP3file_url = url;
                weakSelf.musicModel.playurl_mp3 = url;
                weakSelf.timeTotal.text = weakSelf.musicModel.durationstring;
                [weakSelf hideProgress];
                [weakSelf changeMusic:weakSelf.musicModel];
            }
           
        }];
    }
}

-(void)downloadmp3
{
    
}

-(void)setupcurrentplaystatus:(NSInteger)playStatus
{
    switch (playStatus)
    {
            
        case 0:
            [self.modeBtn setTitle:@"列表循环" forState:UIControlStateNormal];
            break;
        case 1:
            [self.modeBtn setTitle:@"随机播放" forState:UIControlStateNormal];
            break;
        case 2:
            [self.modeBtn setTitle:@"单曲循环" forState:UIControlStateNormal];
            break;
            
    }
}

#pragma mark tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"_lyricsTableUITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return  cell;
}


#pragma mark 播放按钮
-(void)playSongAction:(UIButton*)sender
{
    UIButton *button = (UIButton *)sender;
    
    if ([self.corePlayer isPlaying])
    {
        [self.corePlayer pause];
        [button setTitle:@"播放" forState:UIControlStateNormal];
    }
    else
    {
        [self.corePlayer play];
        [button setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
}

#pragma mark--换歌曲
-(void)changeMusic:(MusicModel*)model
{
    
    [self setSliderMaxValue];
    
    __weak typeof(self) weakSelf=self;
    self.corePlayer.nowModel = self.musicModel;
    
    
    self.corePlayer.mptblock = ^(float progress, NSString *currenttime, NSString *cachetime) {
        if (weakSelf)
        {
            weakSelf.coverIMV.transform = CGAffineTransformRotate(weakSelf.coverIMV.transform, 0.01);
            weakSelf.progressBar.value=progress;
            
            NSInteger index = [[LyricHandle shareLyricHandle] lyricItemWithTime:progress];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            if (weakSelf.musicModel.lyric)
            {
                [weakSelf.lyricsTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                
            }
            if (weakSelf.progressBar.value==weakSelf.progressBar.maximumValue)
            {
               // [weakSelf nextSongClick:nil];
            }
            
            weakSelf.timeNow.text = currenttime;
           // weakSelf.timeCache.text = cachetime;
        }

    };
    
    [[LyricHandle shareLyricHandle]changeLyricString:model.lyric];
    NSString *last_s = [MusicDataHandle shareMusicDataHandle].lastmp3Url;
    
    if (![last_s isEqualToString:model.MP3file_url]||self.corePlayer.playStatus==2)
    {
        [MusicDataHandle shareMusicDataHandle].lastmp3Url=model.MP3file_url;
        [self.corePlayer playWithURLString:model.MP3file_url];
    }
    [self.lyricsTable reloadData];
    
}

-(void)setSliderMaxValue
{
    self.progressBar.value = 0;
    self.progressBar.minimumValue = 0;
    int musicTime = [self.musicModel.duration floatValue] / 1000;
    self.progressBar.maximumValue = musicTime;
}

- (void)sliderAction:(id)sender
{
    UISlider * slider = (UISlider*) sender;
    [self.corePlayer seekToTime:slider.value];
    
}
#pragma mark-- 按钮事件
-(void)backButtonAction:(UIButton*)sender
{
    [self removeFromSuperview];
}

- (void)modButtonClick:(id)sender
{
    self.corePlayer.playStatus++;
    if (self.corePlayer.playStatus>2)
    {
        self.corePlayer.playStatus=0;
    }
    
    [self setupcurrentplaystatus:self.corePlayer.playStatus];
    
}

- (void)nextSongClick:(UIButton*)sender
{
    MusicDataHandle *hm = [MusicDataHandle shareMusicDataHandle];
    
    switch (self.corePlayer.playStatus)
    {
        case 0://列表循环
            if (self.index == [hm musicDataCount] - 1)
            {
                self.index = 0;
            }
            else
            {
                self.index = self.index+1;
            }
            self.musicModel = [hm musicWithIndex:self.index];
            [self updatesongmodel:self.musicModel];
            break;
            
        case 1://随机播放
            self.index = arc4random() % [hm musicDataCount];
            self.musicModel = [hm musicWithIndex:self.index];
            [self updatesongmodel:self.musicModel];
            break;
            
        case 2://单曲循环
            self.musicModel = [hm musicWithIndex:self.index];
            [self updatesongmodel:self.musicModel];
            break;
            
        default:
            break;
    }
    
}

- (void)lastSongClick:(UIButton*)sender
{
    if (self.index == 0)
    {
        self.index = [[MusicDataHandle shareMusicDataHandle]musicDataCount] - 1;
    }
    else
    {
        self.index -= 1;
    }
    
    self.musicModel = [[MusicDataHandle shareMusicDataHandle] musicWithIndex:self.index];
    [self changeMusic:self.musicModel];
}

#pragma mark-- 获取数据
- (void)getNetDataFromWangyiWithsongid:(NSString *)songid WithFinishBlock:(finishURLBlock)finishblock;
{
    
    typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = [self getDicWithsongid:songid];
    
    
    NSString *url = @"http://music.163.com/weapi/song/enhance/player/url?csrf_token=";
    [manager.requestSerializer
     setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
    
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:url
       parameters:params
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSArray *arr = [responseObject objectForKey:@"data"];
             NSDictionary *data = arr.firstObject;
             if (data)
             {
                 NSString *url = [data objectForKey:@"url"];
                 
                 finishblock(url);
             }
             
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             
         }];
    
}

-(NSDictionary*)getDicWithsongid:(NSString*)songid
{
    if (!songid) {
        return nil;
    }
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"aes" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *jshi = [[NSBundle mainBundle] pathForResource:@"jshi" ofType:@"js"];
    NSString *jshiStr = [NSString stringWithContentsOfFile:jshi encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:jshiStr];
    
    JSValue *function =context[@"go_request"];
    
    
    JSValue *s = [function callWithArguments:@[songid]];
    //NSLog(@"s=%@",[s toDictionary]);
    
    return [s toDictionary];
}

- (void)musicPlayTimecache:(NSString*)time
{
    self.timeCache.text = time;
}

-(void)currentMusicDidFinish
{
     [self nextSongClick:nil];
}

-(void)pause
{
    [self playSongAction:nil];
}
-(void)playnext
{
    [self backButtonAction:nil];
}
-(void)playlast
{
    [self nextSongClick:nil];
}
@end
