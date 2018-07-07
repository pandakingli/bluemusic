//
//  SongListCell.h
//  blueMusic
//
//  Created by didi on 2018/7/7.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MusicModel;
@interface SongListCell : UITableViewCell
-(void)configModel:(MusicModel*)mModel andindex:(NSInteger)index;
@end
