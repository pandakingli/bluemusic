//
//  MusicPlayerViewController.m
//  
//
//  Created by biubiu on 15/11/2.
//  Copyright © 2015年 lining. All rights reserved.
//

#import "Headers.h"

@interface MusicPlayerViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,strong)MusicModel *model;//获取到的model
@property(nonatomic,strong)MusicPlayerHandle *mpHandle;
@property(nonatomic,strong)MusicDataHandle *dataHandle;
@property(nonatomic,strong)songPlayView *songV;

@end

@implementation MusicPlayerViewController

#pragma mark--viewDidLoad
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.mpHandle=[MusicPlayerHandle shareMusicPlayerHandle];
    
    self.songV = [[songPlayView alloc]initWithFrame:self.view.frame];
    self.view =self.songV;
    
    self.dataHandle=[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] ;
    
    if (!self.direct)
    {
        self.model = [ self.dataHandle musicWithIndex:self.index];
    }
    else
    {
        if(self.mpHandle.nowModel)
        self.model = self.mpHandle.nowModel;
        else self.model = [ self.dataHandle musicWithIndex:0];
    }
    
    self.direct=NO;
    
    
    
    [self setupcurrentplaystatus];
    [self setupsongviewbuttons];
    [self changeMusic:self.model];
}

-(void)setupcurrentplaystatus
{
    
}

-(void)setupsongviewbuttons
{
}


#pragma mark 播放按钮
-(void)playSongAction:(UIButton*)sender
{
    UIButton *button = (UIButton *)sender;
    
    
    
    if ([self.mpHandle isPlaying]) {
        [self.mpHandle pause];
        [button setTitle:@"播放" forState:UIControlStateNormal];
        [self.myTimer invalidate];
        self.myTimer=nil;
    } else {
        [self.mpHandle play];
        [button setTitle:@"暂停" forState:UIControlStateNormal];
        
    }
    
    
    
}

#pragma mark--换歌曲
-(void)changeMusic:(MusicModel*)model
{
  
    
    //设置进度条最大值
    [self setSliderMaxValue];

    
    //获取上次播放的歌曲的网址
    __weak typeof(self) weakSelf=self;
    
    self.mpHandle=[MusicPlayerHandle shareMusicPlayerHandle];
    
    self.mpHandle.nowModel = model;
    
    self.mpHandle.mptblock=^void(float progress){
        
        
        //如果返回目录页，这个对象就不存在了，所以要判断一下
        if (weakSelf) {
            
            
        }//if (weakSelf)
        
        
    };//^void(float progress)
    
    
    [[LyricHandle shareLyricHandle]changeLyricString:model.lyric];
    
    
    NSString *last_s=self.dataHandle.lastmp3Url;
    
    //歌曲地址不同，或者是单曲循环模式
    if (![last_s isEqualToString:model.MP3file_url]||self.mpHandle.playStatus==2)
    {
        
        
        self.dataHandle.lastmp3Url=model.MP3file_url;
        //播放音乐
        
        [self.mpHandle playWithURLString:model.MP3file_url];
        
    }
    
    
}

#pragma mark 返回按钮
-(void)backButtonAction:(UIButton*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger m = [[LyricHandle shareLyricHandle] lyricItemCount];
    return m;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[LyricHandle shareLyricHandle] lyricStringWithIndex:indexPath.row];
    
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return  cell;
    
    
}


#pragma mark--进度条
//设置进度条最大值
-(void)setSliderMaxValue
{
    
}

#pragma mark--拖动进度条
- (void)sliderAction:(id)sender
{
    
    UISlider * slider = (UISlider*) sender;
    //获取进度条当前的位置，然后将音乐前进到这个位置
    [self.mpHandle seekToTime:slider.value];
  
}


#pragma mark--拖动进度条播放模式控制按钮
- (void)modButtonClick:(id)sender
{
    
  
}



#pragma mark 下一首歌按钮
- (void)nextSongClick:(UIButton*)sender {
    
    
    switch (self.mpHandle.playStatus) {
        case 0://列表循环
            if (self.index == [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] musicDataCount] - 1) {
                self.index = 0;
            } else {
                self.index += 1;
            }
            self.model = [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] musicWithIndex:self.index];
            [self changeMusic:self.model];
            break;
        case 1://随机播放
            self.index = arc4random() % [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] musicDataCount];
            self.model = [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] musicWithIndex:self.index];
            [self changeMusic:self.model];
            break;
        case 2://单曲循环
            self.model = [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] musicWithIndex:self.index];
            [self changeMusic:self.model];
            break;
        default:
            break;
    }
    
    
    
    
    
}


#pragma mark 上一首歌按钮
- (void)lastSongClick:(UIButton*)sender {
    
    
    
    if (self.index == 0) {
        self.index = [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil]musicDataCount] - 1;
    } else {
        self.index -= 1;
    }
    
    self.model = [[MusicDataHandle shareMusicDataHandleWithFinishBlock:nil] musicWithIndex:self.index];
    
    [self changeMusic:self.model];
}

@end
