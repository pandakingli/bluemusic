

#import "RootTabBarController.h"
#import "Headers.h"
#import "HomeVC.h"

#define searchSelected @"blue_music_blue.png"
#define searchUnSelected @"blue_music_white.png"

#define musicSelected @"blue_music_blue.png"
#define musicUnSelected @"blue_music_white.png"

#define shareSelected @"blue_share_blue.png"
#define shareUnSelected @"blue_share_white.png"

#define userSelected @"blue_user_blue.png"
#define userUnSelected @"blue_user_white.png"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 发现音乐
    //SearchMusicViewController * searchMusicVC = [[SearchMusicViewController alloc] init];
    
    
    
    HomeVC * searchMusicVC = [[HomeVC alloc] init];
    
    UINavigationController * searchMusicNC = [[UINavigationController alloc] initWithRootViewController:searchMusicVC];
    
    
    
    searchMusicNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现音乐" image:[UIImage imageNamed:searchUnSelected] tag:101];
    UIImage * select1 = [UIImage imageNamed:searchSelected];
    
    searchMusicNC.tabBarItem.selectedImage = [select1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    // 我的音乐
    MyMusicViewController * myMusicVC = [[MyMusicViewController alloc] init];
    UINavigationController * myMusicVCNC = [[UINavigationController alloc] initWithRootViewController:myMusicVC];
    
    
    myMusicVCNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的音乐" image:[UIImage imageNamed:musicUnSelected] tag:102];
    UIImage * select2 = [UIImage imageNamed:musicSelected];
    
    myMusicVCNC.tabBarItem.selectedImage = [select2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 心情分享
    ShareMusicViewController * shareVC = [[ShareMusicViewController alloc] init];
    UINavigationController * shareNC =[[UINavigationController alloc] initWithRootViewController:shareVC];
    
    
    
    shareNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"分享" image:[UIImage imageNamed:shareUnSelected] tag:103];
    UIImage * select3 = [UIImage imageNamed:shareSelected];
    
    shareNC.tabBarItem.selectedImage = [select3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 我的账号
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    UINavigationController * loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    
    
    
    loginNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"账号" image:[UIImage imageNamed:userUnSelected] tag:104];
    
    UIImage * select4 = [UIImage imageNamed:userSelected];
    
    loginNC.tabBarItem.selectedImage = [select4 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    
    self.viewControllers = @[searchMusicNC, myMusicVCNC, shareNC, loginNC];
    
    
   
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
