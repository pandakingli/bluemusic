//
//  MusicPLCell.h
//  blueMusic
//
//  Created by biubiublue on 2018/7/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//#3

#import <UIKit/UIKit.h>

@class BlueMusicPlayListModel;
@interface MusicPLCell : UITableViewCell
-(void)configModel:(BlueMusicPlayListModel*)plModel;
@end
