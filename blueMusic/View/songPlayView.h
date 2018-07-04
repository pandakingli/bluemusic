//
//  songPlayView.h
//  
//
//  Created by biubiu on 15/12/23.
//  Copyright © 2015年 biubiu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MusicModel;

@interface songPlayView : UIView<UIScrollViewDelegate>

+(instancetype)getDefaultMusicPlayView;

+(instancetype)shareMusicPlayView;

-(void)updatesongmodel:(MusicModel*)model;

@end
