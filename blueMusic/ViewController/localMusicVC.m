//
//  localMusicVC.m
//  blueMusic
//
//  Created by lining on 2018/7/13.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

#import "localMusicVC.h"
#import <Masonry/Masonry.h>
#import "MusicPlayerHandle.h"

@interface localMusicVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableview;

@property(nonatomic,strong)NSMutableArray *songnames;
@end

@implementation localMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"已下载音乐";
    self.songnames = [NSMutableArray array];
    // 文件将要移动到的指定目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *s = @"/music";
    // 新文件路径
    NSString *newFilePath = [documentsPath stringByAppendingPathComponent:s];
    
    
    //fileNameList中即为该imagesFolder文件夹下的所有文件的名称数组
    NSArray *fileNameList=[[NSFileManager defaultManager]
                           contentsOfDirectoryAtPath:newFilePath error:nil];
    
    self.songnames = fileNameList.mutableCopy;
    
    [self.view addSubview:self.tableview];
    
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    [self.tableview reloadData];
}

- (UITableView *)tableview
{
    if(!_tableview)
    {
        _tableview = [[UITableView alloc]init];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        
        [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _tableview;
}

#pragma mark --tableview相关

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if(indexPath.row<self.songnames.count)
    {
        NSString *s = [self.songnames objectAtIndex:indexPath.row];
        cell.textLabel.text=s;
    }
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songnames.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *s = [self.songnames objectAtIndex:indexPath.row];
    [self goplaywithname:s];
    
}

-(void)goplaywithname:(NSString*)name
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *createPath = [documentsPath stringByAppendingPathComponent:@"/music"];
    NSString *s = [NSString stringWithFormat:@"/music/%@",name];
        NSString *newFilePath = [documentsPath stringByAppendingPathComponent:s];
    [[MusicPlayerHandle shareMusicPlayerHandle] playWithFileURL:newFilePath];
}

@end
