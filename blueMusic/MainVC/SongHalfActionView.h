//
//  SongHalfActionView.h
//  blueMusic
//
//  Created by biubiublue on 2018/7/8.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MusicModel;
@interface SongHalfActionView : UIView
+(instancetype)shareMusicSHAView;
-(void)goupwithmodel:(MusicModel*)mModel;
@end
