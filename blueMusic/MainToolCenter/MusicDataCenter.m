//
//  MusicDataCenter.m
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "MusicDataCenter.h"
#import "MusicModel.h"
#import "BlueMusicPlayListModel.h"



static MusicDataCenter *musicDataCenter=nil;

@interface MusicDataCenter()
@property(nonatomic,strong)NSMutableArray *musicModelArray;
@property(nonatomic,strong)NSMutableArray *musicPlayListArray;

@end

@implementation MusicDataCenter
+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (musicDataCenter == nil) {
            musicDataCenter = [[MusicDataCenter alloc]init];
            musicDataCenter.musicModelArray =[NSMutableArray array];
            musicDataCenter.musicPlayListArray =[NSMutableArray array];
        }
    });
    
    return musicDataCenter;
}

-(void)updatepldata:(NSArray*)plarray
{
    if (plarray.count>0)
    {
        [self.musicPlayListArray addObjectsFromArray:plarray];
    }
    
}

-(BlueMusicPlayListModel *)musicPlayListWithIndex:(NSInteger)index
{
    
    if (index<self.musicPlayListArray.count)
    {
        return self.musicPlayListArray[index];
    }
    return nil;
}

-(NSInteger)musicPLDataCount
{
    return self.musicPlayListArray.count;
}

-(NSInteger)musicDataCount
{
    return self.musicModelArray.count;
}

-(MusicModel *)musicWithIndex:(NSInteger)index
{
    if (index<self.musicModelArray.count)
    {
        return self.musicModelArray[index];
    }
    return nil;
    
}
@end