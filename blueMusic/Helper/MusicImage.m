//
//  MusicImage.m
//  blueMusic
//
//  Created by didi on 2018/7/6.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "MusicImage.h"

@implementation MusicImage
+ (UIImage *)imageNamed: (NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@/%@", @"icons.bundle", name];
    return [UIImage imageNamed: path];
}
@end
