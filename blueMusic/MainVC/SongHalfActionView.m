//
//  SongHalfActionView.m
//  blueMusic
//
//  Created by biubiublue on 2018/7/8.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "SongHalfActionView.h"
#import <bluebox/bluebox.h>
#import "MusicImage.h"
#import "MusicModel.h"
#import <Masonry/masonry.h>
#import "MusicConstants.h"
#import "DownloadSongOneVC.h"

#define kImg1_download [MusicImage imageNamed:@"icon-download"]
#define kImg2_add      [MusicImage imageNamed:@"icon-add"]
#define kImg3_cds      [MusicImage imageNamed:@"icon-record"]
#define kImg4_singer   [MusicImage imageNamed:@"icon-mic"]



@interface SongHAVCell:UITableViewCell
@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UIView *downline;

@end

@implementation SongHAVCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupviews];
        [self addmyconstrains];
    }
    return self;
}

-(void)setupviews
{
    [self addSubview:self.icon];
    [self addSubview:self.name];
    [self addSubview:self.downline];
}

-(void)addmyconstrains
{
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(15);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.icon.mas_right).with.offset(8);
        make.right.mas_equalTo(-15);
    }];
    
    [self.downline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kSingleLineWidthOrHeight);
        make.bottom.mas_equalTo(-kSingleLineWidthOrHeight);
        make.left.mas_equalTo(self.icon.mas_left);
        make.right.mas_equalTo(self.name.mas_right);
    }];
}

-(void)updateicon:(UIImage*)icon andname:(NSString*)name
{
    self.icon.image = icon;
    self.name.text = name;
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

- (UIImageView *)icon
{
    if (!_icon)
    {
        _icon = [[UIImageView alloc]init];
    }
    return _icon;
}

- (UILabel *)name
{
    if (!_name)
    {
        _name = [[UILabel alloc]init];
    }
    return _name;
}
@end

static SongHalfActionView *MusicSHAViewCenter = nil;

@interface SongHalfActionView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UIView *downView;
@property(nonatomic,strong) UILabel *header;
@property(nonatomic,strong) UIImageView *closeIMV;
@property(nonatomic,strong) UIControl *closebtn;
@property(nonatomic,strong) UITableView *tableview;
@property(nonatomic,strong) MusicModel *mModel;
@property(nonatomic,strong) UIControl *allcontrol;

@property(nonatomic,strong) UIView *midline;

@end

@implementation SongHalfActionView
+(instancetype)shareMusicSHAView
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (MusicSHAViewCenter == nil)
        {
            MusicSHAViewCenter = [[SongHalfActionView alloc]initWithFrame:CGRectZero];
        }
    });
    
    return MusicSHAViewCenter;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupmyviews];
        [self addmyconstraints];
    }
    return self;
}

-(void)setupmyviews
{
    self.backgroundColor = bbx_ColorByStr(@"3FA9A9A9");

    CGFloat x,y,w,h;
    x = 0;
    y = 0;
    w = bbx_IPHONE_WIDTH;
    h = bbx_IPHONE_HEIGHT;
    CGRect r_rect = (CGRect){x,y,w,h};
    self.frame = r_rect;
    [self addSubview:self.allcontrol];
    [self addSubview:self.downView];
    [self.downView addSubview:self.header];
    [self.downView addSubview:self.midline];
    [self.downView addSubview:self.closeIMV];
    [self.downView addSubview:self.closebtn];
    [self.downView addSubview:self.tableview];
}


-(void)addmyconstraints
{
    [self.allcontrol mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(bbx_IPHONE_HEIGHT*0.5);
    }];
    
    [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(self.closebtn.mas_left).with.offset(-15);
    }];
    
    [self.closeIMV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(12);
        make.centerY.mas_equalTo(self.header.mas_centerY);
        make.right.mas_equalTo(-15);
    }];
    
    [self.closebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self.closeIMV.mas_left).with.offset(-15);
        make.bottom.mas_equalTo(self.closeIMV.mas_bottom).with.offset(5);
    }];
    
    [self.midline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kSingleLineWidthOrHeight);
        make.bottom.mas_equalTo(self.tableview.mas_top);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.header.mas_bottom).with.offset(5);
        make.width.mas_equalTo(self.downView.mas_width);
        make.bottom.mas_equalTo(0);
    }];
}

- (UIView *)midline
{
    if (!_midline)
    {
        _midline = [[UIView alloc]init];
        _midline.backgroundColor = bbx_ColorByStr(@"#A9A9A9");
    }
    return _midline;
}

- (UITableView *)tableview
{
    if (!_tableview)
    {
        _tableview = [[UITableView alloc]init];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        [_tableview registerClass:[SongHAVCell class] forCellReuseIdentifier:@"SongHAVCell"];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableview;
}
- (UIView *)downView
{
    if (!_downView)
    {
        CGFloat x,y,w,h;
        x = 0;
        y = bbx_IPHONE_HEIGHT;
        w = bbx_IPHONE_WIDTH;
        h = bbx_IPHONE_HEIGHT*0.5;
        CGRect r_rect = (CGRect){x,y,w,h};
        _downView = [[UIView alloc]initWithFrame:r_rect];
        _downView.backgroundColor = [UIColor whiteColor];
    }
    return _downView;
}

- (UILabel *)header
{
    if (!_header)
    {
        _header = [[UILabel alloc]init];
    }
    return _header;
}

- (UIImageView *)closeIMV
{
    if (!_closeIMV)
    {
        _closeIMV = [[UIImageView alloc]init];
        _closeIMV.image = [MusicImage imageNamed:@"icon-cross"];
    }
    return _closeIMV;
}

- (UIControl *)allcontrol
{
    if (!_allcontrol)
    {
        _allcontrol = [[UIControl alloc]init];
        [_allcontrol addTarget:self action:@selector(clickclose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allcontrol;
}

- (UIControl *)closebtn
{
    if (!_closebtn)
    {
        _closebtn = [[UIControl alloc]init];
        [_closebtn addTarget:self action:@selector(clickclose) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closebtn;
}

-(void)clickclose
{
    [self downviewgodown];
}

-(void)goupwithmodel:(MusicModel*)mModel
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    if (mModel)
    {
        self.mModel = mModel;
        NSString *s = [NSString stringWithFormat:@"歌曲：%@",self.mModel.songname];
        
        self.header.text = s;
        [self downviewgoup];
        [self.tableview reloadData];
    }
}

-(void)downviewgoup
{
    CGFloat x,y,w,h;
    x = 0;
    y = bbx_IPHONE_HEIGHT*0.5;
    w = bbx_IPHONE_WIDTH;
    h = bbx_IPHONE_HEIGHT*0.5;
    CGRect r_rect = (CGRect){x,y,w,h};
    
    [UIView animateWithDuration:0.5f animations:^{
        self.downView.frame = r_rect;
    } completion:^(BOOL finished) {
        self.downView.frame = r_rect;    }];
}

-(void)downviewgodown
{
    CGFloat x,y,w,h;
    x = 0;
    y = bbx_IPHONE_HEIGHT;
    w = bbx_IPHONE_WIDTH;
    h = bbx_IPHONE_HEIGHT*0.5;
    CGRect r_rect = (CGRect){x,y,w,h};
    
    [UIView animateWithDuration:0.5f animations:^{
        self.downView.frame = r_rect;
    } completion:^(BOOL finished) {
        self.downView.frame = r_rect;
        [self removeFromSuperview];

    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongHAVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongHAVCell" forIndexPath:indexPath];
    switch (indexPath.row)
    {
        case 0:
            [cell updateicon:kImg1_download andname:@"下载"];
            break;
            
        case 1:
            [cell updateicon:kImg2_add andname:@"收藏"];
            break;
            
        case 2:
            [cell updateicon:kImg3_cds andname:@"专辑"];
            break;
            
        case 3:
        {
            NSString *s = [NSString stringWithFormat:@"歌手：%@",self.mModel.singer];
            [cell updateicon:kImg4_singer andname:s];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    switch (indexPath.row)
    {
        case 0:
        //下载
        [self gotodownload];
        break;
        
        case 1:
        //收藏
        break;
        
        case 2:
        //专辑
        break;
        
        case 3:
        //歌手
        break;
        default:
        break;
    }
}

-(void)gotodownload
{
    if(self.mModel)
    {
        DownloadSongOneVC *vv = [[DownloadSongOneVC alloc]init];
        [vv godownloadmodel:self.mModel];
        if(self.fVC)
        {
            [self downviewgodown];
            [self.fVC.navigationController pushViewController:vv animated:YES];
        }
    }
}

@end

















