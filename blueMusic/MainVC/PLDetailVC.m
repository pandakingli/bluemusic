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
#import "MusicPlayerViewController.h"
#import "MusicDataHandle.h"
#import "songPlayView.h"

typedef void(^finishURLBlock)(NSString *url);

@interface PLDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableview;

@property(nonatomic,strong) NSMutableArray *dataarr;

@property(nonatomic,strong) BlueMusicPlayListModel*plModel;

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

    [self.view addSubview:self.tableview];

    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(-20);
        make.top.mas_equalTo(100);
    }];
}

-(void)showProgress {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgress {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(NSMutableArray *)dataarr
{
    if (!_dataarr)
    {
        _dataarr = [NSMutableArray array];
    }
    return _dataarr;
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
    [self.dataarr removeAllObjects];
    typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    NSDictionary *params = [self testjs];
    
    NSString *url = @"http://music.163.com/weapi/v3/playlist/detail";
    [manager.requestSerializer
     setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    
    [manager POST:url
       parameters:params
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // NSLog(@"responseObject = %@",responseObject);
            NSDictionary *playlist = [responseObject objectForKey:@"playlist"];
             NSArray *tracks = [playlist objectForKey:@"tracks"];
             if (tracks.count>0)
             {
                 
                 for (NSDictionary *ddd in tracks)
                 {
                     MusicModel *m = [[MusicModel alloc]init];
                     m.name = [ddd objectForKey:@"name"];
                     NSNumber *num = [ddd objectForKey:@"dt"];
                     m.duration = num.stringValue;
                     m.songid = [ddd objectForKey:@"id"];
                     [weakSelf.dataarr addObject:m];
                 }
                 
             }
             [weakSelf.tableview reloadData];
             [weakSelf hideProgress];
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error = %@",error);
              [weakSelf hideProgress];
         }];
    
}
#pragma mark --tableview相关

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    MusicModel *mm = [self.dataarr objectAtIndex:indexPath.row];
    cell.textLabel.text = mm.name;
    return cell;
    
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataarr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        typeof(self) weakSelf = self;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MusicModel *mm = [self.dataarr objectAtIndex:indexPath.row];
    
    
    songPlayView *vv = [songPlayView getDefaultMusicPlayView];
    [vv updateSongList:self.dataarr andindex:indexPath.row];
    [self.view addSubview:vv];
    
    
    /*
    [self getNetDataFromWangyiWithsongid:mm.songid WithFinishBlock:^(NSString *url) {
        mm.mp3Url = url;
        mm.MP3file_url = url;
        mm.playurl_mp3 = url;
        [MusicDataHandle shareMusicDataHandleWithFinishBlock:nil].musicArray = @[mm].mutableCopy;
        
        MusicPlayerViewController *songPVC = [[MusicPlayerViewController alloc]init];
        songPVC.index = 0;
        [weakSelf presentViewController:songPVC animated:YES completion:nil];
    }];
    
 */
    
}


-(NSDictionary*)getDicWithsongid:(NSString*)songid
{
    if (!songid) {
        return nil;
    }
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
    
    JSValue *function =context[@"go_request"];
    
    
    JSValue *s = [function callWithArguments:@[songid]];
    //NSLog(@"s=%@",[s toDictionary]);
    
    return [s toDictionary];
}

- (void)getNetDataFromWangyiWithsongid:(NSString *)songid WithFinishBlock:(finishURLBlock)finishblock;
{
    
    typeof(self) weakSelf = self;
  
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = [self getDicWithsongid:songid];
 
    
    NSString *url = @"http://music.163.com/weapi/song/enhance/player/url?csrf_token=";
    [manager.requestSerializer
     setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
    
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:url
       parameters:params
         progress:^(NSProgress * _Nonnull uploadProgress) {
             
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
             NSArray *arr = [responseObject objectForKey:@"data"];
             NSDictionary *data = arr.firstObject;
             if (data)
             {
                 NSString *url = [data objectForKey:@"url"];
                 
                 finishblock(url);
             }
             
  
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
             
         }];
    
}

-(void)updateplModel:(BlueMusicPlayListModel*)plmodel
{
    if (plmodel)
    {
        self.plModel = plmodel;
        [self.navigationItem setTitle:plmodel.title];
        [self trytogetsongs];
    }
}
@end
