//
//  AppDelegate.m
//  blueMusic
//
//  Created by lining on 2017/12/14.
//  Copyright © 2017年 biubiublue. All rights reserved.
//

#import "AppDelegate.h"
#import "Headers.h"
#import <AVFoundation/AVFoundation.h>
#import "songPlayView.h"
#import "MusicPlayerHandle.h"

@interface AppDelegate ()
{
    UIBackgroundTaskIdentifier _bgTaskId;
}
@end

@implementation AppDelegate
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUserAgent = [userAgent stringByAppendingString:@" native_iOS"];//自定义需要拼接的字符串
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];

    
    //告诉系统，我们要接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    //如果使用美国站点，请加上这行代码 [AVOSCloud useAVCloudUS];
    [AVOSCloud setApplicationId:@"ei8TJNLnVqOjEtK6JE34lkSO-gzGzoHsz"
                      clientKey:@"dQFjmK1LLUnsEPY5g60h2Seh"];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //注册错误事件报告
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    RootTabBarController * rootTBC = [[RootTabBarController alloc] init];
    self.window.rootViewController = rootTBC;
    
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
               // [[songPlayView getDefaultMusicPlayView] pause];
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
               // [[songPlayView getDefaultMusicPlayView] playnext];
                NSLog(@"RemoteControlEvents: playModeNext");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                //[[songPlayView getDefaultMusicPlayView] playlast];
                NSLog(@"RemoteControlEvents: playPrev");
                break;
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    //开启后台处理多媒体事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
    _bgTaskId=[AppDelegate backgroundPlayerID:_bgTaskId];
    //其中的_bgTaskId是后台任务UIBackgroundTaskIdentifier _bgTaskId;
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId
{
    //设置并激活音频会话类别
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    //允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}

@end
