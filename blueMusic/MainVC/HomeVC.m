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
#import "MusicDataHandle.h"
#import "BlueMusicPlayListModel.h"
#import "PLDetailVC.h"

#define kReuseIdentifier_PlaylistCVCell @"PlaylistCV"

/**
 *  是否是iphoneX
 */
#define IS_IPHONE_X    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPHONE_NAVIGATIONBAR_HEIGHT  (IS_IPHONE_X ? 88 : 64)
#define IPHONE_STATUSBAR_HEIGHT      (IS_IPHONE_X ? 44 : 20)
#define IPHONE_SAFEBOTTOMAREA_HEIGHT (IS_IPHONE_X ? 34 : 0)
#define IPHONE_TOPSENSOR_HEIGHT      (IS_IPHONE_X ? 32 : 0)

//动态获取设备宽度
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
//iPhone X判断
#define IPHONE_X    ([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 812)
//状态栏高度
#define StatusBar_Height    ([UIApplication sharedApplication].statusBarFrame.size.height + 44)
//底部Tabbar高度
#define Tabbar_Height       (IPHONE_X ? (49 + 34) : 49)
//iPhone X底部高度
#define Tabbar_Bottom_Margin  (IPHONE_X ? 34 : 0)

@interface HomeVC ()<UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) UICollectionView *collectionview;
@end

@implementation HomeVC
- (instancetype)init
{
    self = [super init];
    if (self) {
      
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setuprightbutton];
    [self addmyviews];
    [self addmyconstrains];
    [self trygetdata];
}

-(void)trygetdata
{
    [self showProgress];
    typeof(self) weakSelf = self;
    [MusicDataHandle shareMusicDataHandleWithFinishBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionview reloadData];
            [weakSelf hideProgress];
        });
    }];
}
-(void)setuprightbutton
{
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
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.collectionview];
}

-(void)addmyconstrains
{
    
//    [self.collectionview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(StatusBar_Height);
//        make.left.mas_equalTo(0);
//        make.width.mas_equalTo(IPHONE_WIDTH);
//        make.height.mas_equalTo(IPHONE_HEIGHT);
//    }];
//    [self.view layoutIfNeeded];
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
        _collectionview.backgroundColor = [UIColor orangeColor];
        [_collectionview registerClass:[PlaylistCV class] forCellWithReuseIdentifier:kReuseIdentifier_PlaylistCVCell];
        _collectionview.contentInset = UIEdgeInsetsMake(2, 6, 2, 6);
    }
    return _collectionview;
}

#pragma mark-- UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [[MusicDataHandle shareMusicDataHandle] musicPLDataCount];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCV *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier_PlaylistCVCell forIndexPath:indexPath];
    if (indexPath.row<[[MusicDataHandle shareMusicDataHandle] musicPLDataCount]) {
            BlueMusicPlayListModel *pp = [[MusicDataHandle shareMusicDataHandle] musicPlayListWithIndex:indexPath.row];
         [cell configModel:pp];
    }

    
   
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PLDetailVC *plVC = [[PLDetailVC alloc]init];
    BlueMusicPlayListModel *pp = [[MusicDataHandle shareMusicDataHandle] musicPlayListWithIndex:indexPath.row];
    plVC.plModel = pp;
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