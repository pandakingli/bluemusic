//
//  MusicDataHandle.h
//
//
//  Created by biubiu on 15/11/3.
//  Copyright © 2015年 lining. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicModel.h"
@class BlueMusicPlayListModel;

typedef void(^finishBlock)();

@interface MusicDataHandle : NSObject
+(instancetype)shareMusicDataHandle;
+(instancetype)shareMusicDataHandleWithFinishBlock:(finishBlock)finishblock;
@property(nonatomic,strong)NSMutableArray *musicArray;
@property(nonatomic,strong)NSMutableArray *musicPLArray;
-(NSInteger)musicDataCount;

-(MusicModel *)musicWithIndex:(NSInteger)index;

//记录上次播放的音乐
@property (nonatomic, copy) NSString *lastmp3Url;
- (void)getNetDataFromWangyi:(NSString *)type WithFinishBlock:(finishBlock)finishblock;


-(BlueMusicPlayListModel *)musicPlayListWithIndex:(NSInteger)index;
-(NSInteger)musicPLDataCount;
@end
