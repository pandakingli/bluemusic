//
//  PLDetailView.h
//  blueMusic
//
//  Created by biubiublue on 2018/7/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BlueMusicPlayListModel;
@interface PLDetailView : UIView
@property(nonatomic,strong) BlueMusicPlayListModel*plModel;

-(void)trytogetsongs;
@end
