//
//  LoginViewController.m
//
//  Created by biubiu on 15/12/20.
//  Copyright © 2015年 biubiu. All rights reserved.
//

#import "LoginViewController.h"
#import <Masonry/Masonry.h>
#import "localMusicVC.h"

@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableview;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"我的";
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
   
    switch (indexPath.row)
    {
        case 0:
        cell.textLabel.text = @"未登录";
        break;
      
        case 1:
        cell.textLabel.text = @"已下载音乐";
        break;
        
        case 2:
        cell.textLabel.text = @"其他";
        break;
        default:
        break;
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   
    switch (indexPath.row)
    {
        case 0:
        
        break;
        
        case 1:
        {
            localMusicVC *oneVC = [[localMusicVC alloc]init];
            [self.navigationController pushViewController:oneVC animated:YES];
        }
        break;
        
        case 2:
        
        break;
        default:
        break;
    }
}
@end
