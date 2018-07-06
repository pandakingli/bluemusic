//
//  MusicNetWorkCenter.h
//  blueMusic
//
//  Created by lining on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicConstants.h"

@interface MusicNetWorkCenter : NSObject
+(instancetype)shareInstance;

- (void)netease_RequestPlayListDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishBlock)finishblock;

- (void)netease_RequestMusicDataWithParameters:(NSDictionary*)parameters andFinishBlock:(finishBlock)finishblock;
@end
