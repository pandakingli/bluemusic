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

-(NSInteger)musicDataCount;
-(MusicModel *)musicWithIndex:(NSInteger)index;

-(NSInteger)musicPLDataCount;
-(BlueMusicPlayListModel *)musicPlayListWithIndex:(NSInteger)index;

@end
