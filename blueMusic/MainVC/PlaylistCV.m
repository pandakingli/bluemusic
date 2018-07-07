//
//  PlaylistCV.m
//  blueMusic
//
//  Created by biubiublue on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "PlaylistCV.h"
#import "BlueMusicPlayListModel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <bluebox/bluebox.h>
@interface PlaylistCV()
@property(nonatomic,strong) BlueMusicPlayListModel*plModel;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIImageView *plPic;
@end

@implementation PlaylistCV
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupViews];
    }
    return self;
}

-(void)p_setupViews
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.plPic];
    [self addSubview:self.titleLabel];
    
    [self.plPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(self.mas_width);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.plPic.mas_bottom).with.offset(2);
        make.left.mas_equalTo(self.plPic.mas_left);
        make.right.mas_equalTo(self.plPic.mas_right);
        make.bottom.mas_lessThanOrEqualTo(-2);
    }];
    [self layoutIfNeeded];
}

-(UILabel*)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"歌单名称";
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
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
    [self.plPic hideAllMarks];
    if (self.plModel.personname)
    {
        bbxcolormodel *ld = [bbxcolormodel createDefaultModel];
        ld.display_name = self.plModel.author;
        ld.background_color = bbx_ColorByStr(@"#CCFFB6C1");
        ld.text_color = [UIColor blackColor];//bbx_ColorByStr(@"#90CEDE");
        ld.tFont = [UIFont systemFontOfSize:10];
        [self.plPic showleftdownmarkWithModel:ld];
    }
    
    if (self.plModel.playnumstr)
    {
        bbxcolormodel *ru = [bbxcolormodel createDefaultModel];
        ru.display_name = self.plModel.playnumstr;
        ru.background_color = bbx_ColorByStr(@"#66DCDCDC");
        ru.text_color = [UIColor blackColor];
        [self.plPic showrightupmarkWithModel:ru];
    }
  
}
@end
