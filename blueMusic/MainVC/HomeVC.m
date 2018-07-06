//
//  HomeVC.m
//  blueMusic
//
//  Created by biubiublue on 2018/7/5.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "HomeVC.h"
#import "PlaylistCV.h"
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "songPlayView.h"
#import "BlueMusicPlayListModel.h"
#import "PLDetailVC.h"
#import <MJRefresh/MJRefresh.h>
#import "MusicNetWorkCenter.h"
#import "MusicDataCenter.h"
#import "MusicConstants.h"

#define kReuseIdentifier_PlaylistCVCell @"PlaylistCV"



@interface HomeVC ()<UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) UICollectionView *collectionview;

@property(nonatomic,strong) NSString *order;
@property(nonatomic,assign) NSInteger pagenumber;
@property(nonatomic,assign) NSInteger size;
@end

@implementation HomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupparams];
    [self setuprightbutton];
    [self addmyviews];
    [self addmyconstrains];
    [self trygetdata];
    [self setupmjrefresh];
}

-(void)setupparams
{
    self.order = @"hot";
    self.pagenumber = 0;
    self.size = 30;
    
}

-(NSDictionary*)getRequestParams
{
    NSInteger off = self.pagenumber*self.size;
    NSString *offset = (@(off)).stringValue;
    NSString*limit = @(self.size).stringValue;
    return @{@"order":self.order,@"offset":offset,@"limit":limit};
}

-(void)setupmjrefresh
{
    typeof(self) weakSelf = self;
    self.collectionview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf)
        {
            [weakSelf refresh_header];
        }
    }];
    
    self.collectionview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf)
        {
            [weakSelf refresh_footer];
        }
    
    }];
}

-(void)refresh_header
{
    [self.collectionview.mj_header beginRefreshing];
    typeof(self) weakSelf = self;
    self.pagenumber = 0;
    NSDictionary *dic = [self getRequestParams];
    [[MusicNetWorkCenter shareInstance] netease_RequestPlayListDataWithParameters:dic andFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionview reloadData];
            [weakSelf.collectionview.mj_header endRefreshing];
        });
    }];
    
}

-(void)refresh_footer
{
    [self.collectionview.mj_footer beginRefreshing];
    typeof(self) weakSelf = self;
    self.pagenumber++;
    NSDictionary *dic = [self getRequestParams];
    [[MusicNetWorkCenter shareInstance] netease_RequestPlayListDataWithParameters:dic andFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionview reloadData];
            [weakSelf.collectionview.mj_footer endRefreshing];
        });
    }];
    
}

-(void)trygetdata
{
    [self showProgress];
    typeof(self) weakSelf = self;
    NSDictionary *dic = [self getRequestParams];
    [[MusicNetWorkCenter shareInstance] netease_RequestPlayListDataWithParameters:dic andFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionview reloadData];
            [weakSelf hideProgress];
        });
    }];
    
}
-(void)setuprightbutton
{
    [self.navigationItem setTitle:@"推荐歌单"];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"正在播放" style:UIBarButtonItemStylePlain target:self action:@selector(nowPlaying:)];
    self.navigationItem.rightBarButtonItem = right;
    
}

#pragma mark 直接进入播放页面
-(void)nowPlaying:(UIBarButtonItem*)sender
{
    songPlayView *vv = [songPlayView getDefaultMusicPlayView];
    [self.view addSubview:vv];
}

-(void)addmyviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionview];
}

-(void)addmyconstrains
{

    [self.collectionview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(StatusBar_Height);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(-Tabbar_Height);
    }];
    [self.view layoutIfNeeded];

}

-(UICollectionView*)collectionview
{
    if (!_collectionview)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
       
        CGFloat x,y,w,h;
        x = 0;
        y = 0;
        w = IPHONE_WIDTH;
        h = IPHONE_HEIGHT;
        CGRect rr = (CGRect){x,y,w,h};
        _collectionview = [[UICollectionView alloc]initWithFrame:rr collectionViewLayout:layout];
        _collectionview.delegate = self;
        _collectionview.dataSource = self;
        _collectionview.backgroundColor = [UIColor whiteColor];
        [_collectionview registerClass:[PlaylistCV class] forCellWithReuseIdentifier:kReuseIdentifier_PlaylistCVCell];
        _collectionview.contentInset = UIEdgeInsetsMake(2, 6, 2, 6);
    }
    return _collectionview;
}

#pragma mark-- UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[MusicDataCenter shareInstance] musicPLDataCount];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCV *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier_PlaylistCVCell forIndexPath:indexPath];
    if (indexPath.row<[[MusicDataCenter shareInstance] musicPLDataCount]) {
        
       BlueMusicPlayListModel *pp =  [[MusicDataCenter shareInstance] musicPlayListWithIndex:indexPath.row];
         [cell configModel:pp];
    }

    
   
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PLDetailVC *plVC = [[PLDetailVC alloc]init];
    
    BlueMusicPlayListModel *pp = [[MusicDataCenter shareInstance] musicPlayListWithIndex:indexPath.row];
    [plVC updateplModel:pp];
    [self.navigationController pushViewController:plVC animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 100;
    CGFloat height = 130;
    if (IPHONE_WIDTH==320)
    {
         width = 100;
         height = 100+30;
    }
    else if (IPHONE_WIDTH==375)
    {
        width = 119;
        height = 119+30;
    }else if (IPHONE_WIDTH==414)
    {
        width = 132;
        height = 132+30;
    }
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}

#pragma mark --MBProgressHUD菊花
-(void)showProgress
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgress
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
