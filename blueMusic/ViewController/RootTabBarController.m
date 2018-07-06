
#import "RootTabBarController.h"
#import "Headers.h"
#import "HomeVC.h"
#import "MusicImage.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HomeVC * sVC = [[HomeVC alloc] init];
    
    UINavigationController * sVCNC = [[UINavigationController alloc] initWithRootViewController:sVC];
    
    UIImage *nvc = [MusicImage imageNamed:@"icon-tape"];
    sVCNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现音乐" image:nvc tag:101];
  
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    UINavigationController * loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    loginNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"账号" image:[MusicImage imageNamed:@"icon-head"] tag:104];
    
  
    
    self.viewControllers = @[sVCNC, loginNC];
    
}

@end
