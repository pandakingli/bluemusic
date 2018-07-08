//
//  SongHalfActionView.m
//  blueMusic
//
//  Created by didi on 2018/7/8.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "SongHalfActionView.h"
#import <bluebox/bluebox.h>
#import "MusicImage.h"
#import "MusicModel.h"
#import <Masonry/masonry.h>
@interface SongHAVCell:UITableViewCell
@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,strong) UILabel *name;
@end

@implementation SongHAVCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

-(void)setupviews
{
    [self addSubview:self.icon];
    [self addSubview:self.name];
}

-(void)addmyconstrains
{
    
}

-(void)updateicon:(UIImage*)icon andname:(NSString*)name
{
    self.icon.image = icon;
    self.name.text = name;
}
@end

@interface SongHalfActionView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UIView *downView;
@property(nonatomic,strong) UILabel *header;
@property(nonatomic,strong) UIImageView *closeIMV;
@property(nonatomic,strong) UIControl *closebtn;
@property(nonatomic,strong) UITableView *tableview;
@property(nonatomic,strong) MusicModel *mModel;
@end

@implementation SongHalfActionView
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
    self.backgroundColor = bbx_ColorByStr(@"0CA9A9A9");
    CGFloat x,y,w,h;
    x = 0;
    y = 0;
    w = bbx_IPHONE_WIDTH;
    h = bbx_IPHONE_HEIGHT;
    CGRect r_rect = (CGRect){x,y,w,h};
    self.frame = r_rect;
    
    [self addSubview:self.downView];
    [self.downView addSubview:self.header];
    [self.downView addSubview:self.closeIMV];
    [self.downView addSubview:self.closebtn];
    [self.downView addSubview:self.tableview];
}


-(void)addmyconstraints
{
    [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.closebtn.mas_left).with.offset(-15);
    }];
    
    [self.closeIMV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(20);
        make.centerY.mas_equalTo(self.header.mas_centerY);
        make.right.mas_equalTo(-15);
    }];
    
    [self.closebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self.closeIMV.mas_left).with.offset(-15);
        make.bottom.mas_equalTo(self.closeIMV.mas_bottom).with.offset(5);
    }];
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.header.mas_bottom).with.offset(5);
        make.width.mas_equalTo(self.downView.mas_width);
        make.bottom.mas_equalTo(0);
    }];
}

- (UITableView *)tableview
{
    if (!_tableview)
    {
        _tableview = [[UITableView alloc]init];
        _tableview.delegate =self;
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
    NSLog(@"clickclose");
}

-(void)goupwithmodel:(MusicModel*)mModel
{
    if (mModel)
    {
        self.mModel = mModel;
        self.header.text = self.mModel.name;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongHAVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongHAVCell" forIndexPath:indexPath];
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
@end

















