//
//  MusicPLCell.m
//  blueMusic
//
//  Created by didi on 2018/7/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "MusicPLCell.h"
#import <Masonry/Masonry.h>
#import "BlueMusicPlayListModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MusicPLCell()
@property(nonatomic,strong) BlueMusicPlayListModel*plModel;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIImageView *plPic;
@end

@implementation MusicPLCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self p_setupViews];
    }
    return self;
}

-(void)p_setupViews
{
    [self addSubview:self.plPic];
    [self addSubview:self.titleLabel];
    
    [self.plPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(80);
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(10);
        
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.mas_equalTo(self);
        make.top.mas_equalTo(self.plPic.mas_top);
        make.bottom.mas_equalTo(self.plPic.mas_bottom);
        make.left.mas_equalTo(self.plPic.mas_right).with.offset(10);
        make.right.mas_equalTo(-10);
    }];
}

-(UILabel*)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blueColor];
        _titleLabel.text = @"歌单名称";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

-(UIImageView*)plPic
{
    if (!_plPic)
    {
        _plPic = [[UIImageView alloc]init];
    }
    return _plPic;
}

-(void)configModel:(BlueMusicPlayListModel*)plModel
{
    self.plModel = plModel;
    self.titleLabel.text = self.plModel.title;
    NSURL *picURL = [NSURL URLWithString:self.plModel.cover_img_url];
    [self.plPic sd_setImageWithURL:picURL
                  placeholderImage:[UIImage imageNamed:@"placeholderImage.png"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}
@end
