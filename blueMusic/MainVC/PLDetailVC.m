//
//  PLDetailVC.m
//  blueMusic
//
//  Created by biubiublue on 2018/7/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "PLDetailVC.h"
#import <Masonry/Masonry.h>
#import "BlueMusicPlayListModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFNetworking.h>
#import <bluebox/bluebox.h>
#import "SecurityUtil.h"
#import "NSData+Encryption.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <TFHpple/TFHpple.h>
#import "BlueMusicPlayListModel.h"
#import "MBProgressHUD.h"
#import "MusicModel.h"
#import "songPlayView.h"
#import "MusicNetWorkCenter.h"
#import "MusicDataCenter.h"
#import "MusicConstants.h"

typedef void(^finishURLBlock)(NSString *url);

@interface PLDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableview;

@property(nonatomic,strong) BlueMusicPlayListModel*plModel;

@property(nonatomic,strong) UIImageView *coverIMV;
@property(nonatomic,strong) UILabel *pltitle;
@property(nonatomic,strong) UILabel *plauthor;
@property(nonatomic,strong) UILabel *plnplayumber;
@property(nonatomic,strong) UILabel *songcount;
@end

@implementation PLDetailVC
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupviews];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)setupviews{
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.coverIMV];
    [self.view addSubview:self.pltitle];
    [self.view addSubview:self.plauthor];
    [self.view addSubview:self.plnplayumber];
    [self.view addSubview:self.songcount];
    
    [self.view addSubview:self.tableview];

    [self.coverIMV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(150);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(StatusBar_Height+20);
    }];
    
    [self.pltitle mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(self.coverIMV);
        make.left.mas_equalTo(self.coverIMV.mas_right).with.offset(5);
        make.right.mas_equalTo(-20);
    }];
    
    [self.plauthor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pltitle.mas_bottom).with.offset(5);
        make.left.mas_equalTo(self.pltitle);
        make.right.mas_equalTo(self.pltitle);
    }];
    
    [self.plnplayumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.plauthor.mas_bottom).with.offset(5);
        make.left.mas_equalTo(self.pltitle);
        make.right.mas_equalTo(self.pltitle);
    }];
    
    [self.songcount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.plnplayumber.mas_bottom).with.offset(5);
        make.left.mas_equalTo(self.pltitle);
        make.right.mas_equalTo(self.pltitle);
    }];
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(-20);
        make.top.mas_equalTo(self.coverIMV.mas_bottom).with.offset(20);
    }];
}

-(void)showProgress {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgress {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(UILabel*)pltitle
{
    if (!_pltitle)
    {
        _pltitle = [[UILabel alloc]init];
        _pltitle.numberOfLines = 0;
        _pltitle.font = bbx_PingFangSCBold(15);
        _pltitle.textColor = [UIColor blackColor];
    }
    return _pltitle;
}

-(UILabel*)plauthor
{
    if (!_plauthor)
    {
        _plauthor = [[UILabel alloc]init];
        _plauthor.font = bbx_PingFangSCRegular(10);
        _plauthor.textColor = [UIColor blackColor];
    }
    return _plauthor;
}

-(UILabel*)plnplayumber
{
    if (!_plnplayumber)
    {
        _plnplayumber = [[UILabel alloc]init];
        _plnplayumber.font = bbx_PingFangSCRegular(10);
        _plnplayumber.textColor = [UIColor blackColor];
    }
    return _plnplayumber;
}

-(UILabel*)songcount
{
    if (!_songcount)
    {
        _songcount = [[UILabel alloc]init];
        _songcount.font = bbx_PingFangSCRegular(10);
        _songcount.textColor = [UIColor blackColor];
    }
    return _songcount;
}

-(UIImageView*)coverIMV
{
    if (!_coverIMV)
    {
        _coverIMV = [[UIImageView alloc]init];
    }
    return _coverIMV;
}

-(UITableView*)tableview
{
    if (!_tableview)
    {
        _tableview = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableview.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-104);
        _tableview.delegate=self;
        _tableview.dataSource=self;
        
        [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
       
    }
    
    return _tableview;
}

-(void)trytogetsongs
{
    [self showProgress];
    [self getNetData];
}

-(NSDictionary*)testjs
{
    NSString *aespath = [[NSBundle mainBundle] pathForResource:@"aes" ofType:@"js"];
    NSString *aespathstr= [NSString stringWithContentsOfFile:aespath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *bigint = [[NSBundle mainBundle] pathForResource:@"bigint" ofType:@"js"];
    NSString *bigintstr = [NSString stringWithContentsOfFile:bigint encoding:NSUTF8StringEncoding error:nil];
    
    NSString *jshi = [[NSBundle mainBundle] pathForResource:@"jshi" ofType:@"js"];
    NSString *jshiStr = [NSString stringWithContentsOfFile:jshi encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:aespathstr];
    [context evaluateScript:bigintstr];
    [context evaluateScript:jshiStr];
    
    JSValue *function =context[@"go_requestpldetail"];
    
    NSString *ss = self.plModel.pl_id;
    if (!ss)
    {
        ss=@"123";
    }
    JSValue *s = [function callWithArguments:@[ss]];//@"34144485"
    //NSLog(@"s=%@",[s toDictionary]);
    
    return [s toDictionary];
}

- (void)getNetData
{
        typeof(self) weakSelf = self;
    [[MusicNetWorkCenter shareInstance] netease_RequestMusicDataWithParameters:@{@"plid":self.plModel.pl_id?:@""} andFinishBlock:^{
        [weakSelf.tableview reloadData];
        [weakSelf hideProgress];
        NSString *s = [NSString stringWithFormat:@"共%@首歌曲",@([[MusicDataCenter shareInstance] musicDataCount]).stringValue];
        weakSelf.songcount.text = s;
    }];

}
#pragma mark --tableview相关

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (indexPath.row<[[MusicDataCenter shareInstance] musicDataCount])
    {
        MusicModel *mm = [[MusicDataCenter shareInstance] musicWithIndex:indexPath.row];
        cell.textLabel.text = mm.name;
    }
    
    return cell;
 
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[MusicDataCenter shareInstance] musicDataCount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row<[[MusicDataCenter shareInstance] musicDataCount])
    {
        songPlayView *vv = [songPlayView getDefaultMusicPlayView];
        [vv gotoplayIndex:indexPath.row];
        [self.view addSubview:vv];
    }
}

-(void)updateplModel:(BlueMusicPlayListModel*)plmodel
{
    if (plmodel)
    {
        self.plModel = plmodel;
        [self.navigationItem setTitle:plmodel.title];
        NSURL *picurl = [NSURL URLWithString:plmodel.cover_img_url];
        [self.coverIMV sd_setImageWithURL:picurl placeholderImage:nil];
        self.pltitle.text = plmodel.title;
        self.plauthor.text = plmodel.author;
        self.plnplayumber.text = plmodel.playnumstr;
        
        [self trytogetsongs];
    }
}
@end
