//
//  UIImageView+bbx_blurImage.h
//  blueMusic
//
//  Created by lining on 2018/7/18.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (bbx_blurImage)
-(void)goBlurByCoreImageWithImage:(UIImage*)img;
-(void)goBlurByCoreImageWithImage:(UIImage*)img andBlurValue:(NSInteger)blurvalue;
@end
