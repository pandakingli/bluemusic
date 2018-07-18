//
//  UIImageView+bbx_blurImage.m
//  blueMusic
//
//  Created by lining on 2018/7/18.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "UIImageView+bbx_blurImage.h"

@implementation UIImageView (bbx_blurImage)
-(void)goBlurByCoreImageWithImage:(UIImage*)img
{
 
    [self goBlurByCoreImageWithImage:img andBlurValue:40];
    
}

-(void)goBlurByCoreImageWithImage:(UIImage*)img andBlurValue:(NSInteger)blurvalue
{
    NSNumber *bValue = @30;
    
    if (blurvalue>0)
    {
        bValue = @(blurvalue);
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *ciImage = [CIImage imageWithCGImage:img.CGImage];
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        
        [filter setValue:ciImage forKey:kCIInputImageKey];
        [filter setValue:bValue forKey: @"inputRadius"];
        
        CIImage *result = [filter valueForKey:kCIOutputImageKey];
        
        CGImageRef outImage = [context createCGImage: result fromRect:ciImage.extent];
        UIImage * blurImage = [UIImage imageWithCGImage:outImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = blurImage;
        });
    });
}
@end
