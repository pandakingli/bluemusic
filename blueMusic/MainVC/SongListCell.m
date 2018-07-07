//
//  SongListCell.m
//  blueMusic
//
//  Created by didi on 2018/7/7.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "SongListCell.h"
#import <Masonry/Masonry.h>
#import "MusicModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <bluebox/bluebox.h>
#import "MusicImage.h"
#import "MusicModel.h"
#import "MusicConstants.h"

@interface SongListCell()
@property(nonatomic,strong) MusicModel *mModel;
@property(nonatomic,strong) UILabel *songname;
@property(nonatomic,strong) UILabel *singer;
@property(nonatomic,strong) UIView *containerOne;

@property(nonatomic,strong) UILabel *songindex;
@property(nonatomic,strong) UIImageView *songindex_bg;
@property(nonatomic,strong) UIImageView *songicon;

@property(nonatomic,strong) UIView *downline;
@end

@implementation SongListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self p_setupViews];
    }
    return self;
}

-(void)p_setupViews
{
    [self addSubview:self.songindex_bg];
    [self addSubview:self.songindex];
    [self addSubview:self.songicon];
    
    [self addSubview:self.containerOne];
    [self.containerOne addSubview:self.songname];
    [self.containerOne addSubview:self.singer];
    [self addSubview:self.downline];
    
    [self.songindex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(35);
    }];
    
    [self.songindex_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.center.mas_equalTo(self.songindex);
        make.right.mas_equalTo(self.songindex.mas_right).with.offset(3);
        make.height.mas_equalTo(25);
    }];
    
    [self.songicon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.songindex_bg.mas_right).with.offset(10);
        make.centerY.mas_equalTo(self.songindex.mas_centerY);
        make.height.width.mas_equalTo(18);
        
    }];
    
    [self.containerOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.songicon.mas_right).with.offset(10);
        make.centerY.mas_equalTo(self.songindex.mas_centerY);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(8);
    }];
    
    [self.songname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        
    }];
    
    [self.singer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        
    }];
    
    [self.downline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.songindex_bg.mas_left);
        make.bottom.mas_equalTo(-kSingleLineWidthOrHeight);
        make.right.mas_equalTo(self.songname.mas_right);
        make.height.mas_equalTo(kSingleLineWidthOrHeight);
        
    }];
    
}

-(UILabel*)songname
{
    if (!_songname)
    {
        _songname = [[UILabel alloc]init];
        _songname.textAlignment = NSTextAlignmentLeft;
        _songname.font = [UIFont systemFontOfSize:12];
        _songname.textColor = [UIColor blackColor];
    }
    
    return _songname;
}

-(UILabel*)singer
{
    if (!_singer)
    {
        _singer = [[UILabel alloc]init];
        _singer.textAlignment = NSTextAlignmentLeft;
        _singer.font = [UIFont systemFontOfSize:9];
        _singer.textColor = [UIColor blackColor];
    }
    
    return _singer;
}

-(UIImageView*)songindex_bg
{
    if (!_songindex_bg)
    {
        _songindex_bg = [[UIImageView alloc]init];
        _songindex_bg.backgroundColor = bbx_ColorByStr(@"#CCFFB6C1");
        _songindex_bg.layer.cornerRadius = 3;
    }
    return _songindex_bg;
}

-(UILabel*)songindex
{
    if (!_songindex)
    {
        _songindex = [[UILabel alloc]init];
        _songindex.textAlignment = NSTextAlignmentCenter;
        _songindex.font = bbx_PingFangSCBold(10);
        _songindex.textColor = [UIColor blackColor];
    }
    
    return _songindex;
}

-(UIImageView*)songicon
{
    if (!_songicon)
    {
        _songicon = [[UIImageView alloc]init];
        _songicon.image = [MusicImage imageNamed:@"icon-song"];
    }
    
    return _songicon;
}

- (UIView *)containerOne
{
    if (!_containerOne)
    {
        _containerOne = [[UIView alloc]init];
        _containerOne.backgroundColor = self.backgroundColor;
    }
    return _containerOne;
}

- (UIView *)downline
{
    if (!_downline)
    {
        _downline = [[UIView alloc]init];
        _downline.backgroundColor = bbx_ColorByStr(@"#A9A9A9");
    }
    return _downline;
}
-(void)configModel:(MusicModel*)mModel andindex:(NSInteger)index
{
    if (mModel)
    {
        self.mModel = mModel;
        self.songindex.text = @(index).stringValue;
        self.songname.text =self.mModel.name;
        self.singer.text = self.mModel.artists_name;
        [self layoutIfNeeded];
    }
    
}
@end
