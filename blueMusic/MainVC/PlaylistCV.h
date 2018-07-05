//
//  PlaylistCV.h
//  blueMusic
//
//  Created by biubiublue on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BlueMusicPlayListModel;
@interface PlaylistCV : UICollectionViewCell
-(void)configModel:(BlueMusicPlayListModel*)plModel;
@end
