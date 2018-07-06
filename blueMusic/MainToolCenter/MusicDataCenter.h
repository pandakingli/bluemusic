//
//  MusicDataCenter.h
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MusicModel;@class BlueMusicPlayListModel;
@interface MusicDataCenter : NSObject
+(instancetype)shareInstance;

-(void)updatepldata:(NSArray*)plarray;
-(void)updateMusicdata:(NSArray*)plarray;

-(NSInteger)musicDataCount;
-(MusicModel *)musicWithIndex:(NSInteger)index;

-(NSInteger)musicPLDataCount;
-(BlueMusicPlayListModel *)musicPlayListWithIndex:(NSInteger)index;

-(NSMutableArray *)currentMusicPlayList;
//记录上次播放的音乐
@property (nonatomic, copy) NSString *lastmp3Url;
@end
