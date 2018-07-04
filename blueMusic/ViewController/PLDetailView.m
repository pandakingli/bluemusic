//
//  PLDetailView.m
//  blueMusic
//
//  Created by didi on 2018/7/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "PLDetailView.h"
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

@interface PLDetailView()

@property(nonatomic,strong) UIButton *closeBtn;
@property(nonatomic,strong) UITableView *tableview;

@property(nonatomic,strong) UIButton *bbBtn;
@end

@implementation PLDetailView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupviews];
    }
    return self;
}

-(void)setupviews{
    
    [self addSubview:self.closeBtn];
    [self addSubview:self.bbBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(80);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(10);
    }];
    
    [self.bbBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(80);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.closeBtn.mas_bottom).with.offset(50);
    }];
}

-(UIButton*)closeBtn
{
    if (!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setBackgroundColor:[UIColor orangeColor]];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(goclose) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _closeBtn;
}

-(UIButton*)bbBtn
{
    if (!_bbBtn)
    {
        _bbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bbBtn setBackgroundColor:[UIColor orangeColor]];
        [_bbBtn setTitle:@"获取歌曲" forState:UIControlStateNormal];
        [_bbBtn addTarget:self action:@selector(trytogetsongs) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _bbBtn;
}


-(void)goclose
{
    [self removeFromSuperview];
}
-(void)trytogetsongs
{
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
    JSValue *s = [function callWithArguments:@[ss]];//@"34144485"
    //NSLog(@"s=%@",[s toDictionary]);
    
    return [s toDictionary];
}

- (void)getNetData
{
  
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
             NSLog(@"responseObject = %@",responseObject);
             NSArray *arr = [responseObject objectForKey:@"data"];
             NSDictionary *data = arr.firstObject;
             if (data)
             {
                
                 
             }
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error = %@",error);
             
         }];
    
}
@end
