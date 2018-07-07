//
//  BlueMusicPlayListModel.m
//  blueMusic
//
//  Created by biubiu on 2018/7/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "BlueMusicPlayListModel.h"

@implementation BlueMusicPlayListModel
- (NSString<Optional> *)author
{
    NSString *s = @"作者：";
    if (self.personname)
    {
        s = [NSString stringWithFormat:@"by:%@",self.personname];
    }
    return s;
}

- (NSString<Optional> *)playnumstr
{
    NSString *s = @"播放量";
    if (self.personname)
    {
        s = [NSString stringWithFormat:@"%@播放",self.playnum];
    }
    return s;
    
}
@end
