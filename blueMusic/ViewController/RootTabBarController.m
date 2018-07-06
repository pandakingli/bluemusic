
#import "RootTabBarController.h"
#import "Headers.h"
#import "HomeVC.h"
#import "MusicImage.h"

#define tapeImage [MusicImage imageNamed:@"icon-tape"]
#define meImage [MusicImage imageNamed:@"icon-head"]
@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HomeVC * sVC = [[HomeVC alloc] init];
    
    UINavigationController * sVCNC = [[UINavigationController alloc] initWithRootViewController:sVC];
    
    UIImage *na_tape = [tapeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    sVCNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现音乐" image:na_tape tag:101];
  
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    UINavigationController * loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    UIImage *na_me = [meImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    loginNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"账号" image:na_me tag:104];
    
  
    
    self.viewControllers = @[sVCNC, loginNC];
    [self setSelectedIndex:0];
}

@end
