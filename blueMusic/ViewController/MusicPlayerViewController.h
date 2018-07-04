//
//  MusicPlayerViewController.h
//  
//
//  Created by biubiu on 15/11/2.
//  Copyright © 2015年 lining. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayerViewController : UIViewController

@property (nonatomic, assign) NSInteger index;
@property(nonatomic,strong)NSTimer *myTimer;
@property(nonatomic,assign)BOOL direct;

@end
