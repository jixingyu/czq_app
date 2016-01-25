//
//  AppDelegate.m
//  MyRecruitment
//
//  Created by developer on 15/6/23.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AppDelegate.h"
#import "JobSearchViewController.h"
#import "AboutViewController.h"
#import "PersonManageViewController.h"
#import "UMFeedback.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize networkManager,currentAppConfig;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.isFavoriteChanged = YES;
    
    [UMFeedback setAppkey:@"55bb3b2767e58e59ae000c0c"];
    networkManager = [AFHTTPRequestOperationManager manager];
    [AppconfigDataSource instance].delegate = self;
    [self getAppConfig];
    
    [AppDataSource instance].delegate = self;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"APPSTORE_UPDATE_COUNT"] == nil){
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"APPSTORE_UPDATE_COUNT"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    NSMutableDictionary *attributes= [[NSMutableDictionary alloc] init];
    [attributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [attributes setValue:[UIFont boldSystemFontOfSize:18] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    [LoginDataSource instance].delegate = self;
    NSString *token =[[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_TOKEN"];
    if (token != nil||[token isEqualToString:@""]) {
        [[LoginDataSource instance] checkoutToken:token];
    }else{
        [self getRootViewController];
    }
    
    return YES;
}
-(void)getRootViewController{
    JobSearchViewController *jobSearchViewController = [[JobSearchViewController alloc] initWithNibName:@"JobSearchViewController" bundle:nil];
    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:jobSearchViewController];
    navigationController1.tabBarItem.title = @"职位搜索";
    [navigationController1.tabBarItem setImage:[UIImage imageNamed:@"search_item.png"]];
    
    AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
    navigationController2.tabBarItem.title = @"关于";
    [navigationController2.tabBarItem setImage:[UIImage imageNamed:@"about_item.png"]];
    
    
    PersonManageViewController *personManageViewController = [[PersonManageViewController alloc] initWithNibName:@"PersonManageViewController" bundle:nil];
    UINavigationController *navigationController3 = [[UINavigationController alloc] initWithRootViewController:personManageViewController];
    navigationController3.tabBarItem.title = @"个人中心";
    [navigationController3.tabBarItem setImage:[UIImage imageNamed:@"person_item.png"]];
    
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.viewControllers = @[navigationController1,navigationController2,navigationController3];
    tabbarController.tabBar.tintColor = [UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1];
    
    self.window.rootViewController=tabbarController;
    [self.window makeKeyAndVisible];
}
-(void)getAppConfig{
    [[AppconfigDataSource instance] loadAppConfig:@"1.2"];
}
-(void)getAppConfigSuccess:(AppConfig *)appConfig{
    self.currentAppConfig = appConfig;
    NSLog(@"%@",self.currentAppConfig);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"APPSTORE_UPDATE_COUNT"] intValue] == 0) {
        [[AppDataSource instance] getAppVersion];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAppConfigSuccess" object:nil];
}
-(void)getAppConfigtFail:(NSString *)message{
    
}
#pragma mark -
#pragma mark login
- (void)loginSuccess:(User *)user{
    self.loginUser = user;
    
    [[NSUserDefaults standardUserDefaults] setObject:user.token forKey:@"LOGIN_TOKEN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self getRootViewController];
}
- (void)loginFailed:(NSString *)message{
    [self getRootViewController];
}
#pragma mark -
#pragma mark Version
- (void)getAppVersionSuccess:(NSString *)version{
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    if (![currentVersion isEqualToString:version]) {
        if (self.currentAppConfig.isForce) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最新版本为%@,请更新到最新版本",version] delegate:self cancelButtonTitle:@"前往商店" otherButtonTitles: nil];
            alert.tag = 101;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最新版本为%@,是否更新?",version] delegate:self cancelButtonTitle:@"前往商店" otherButtonTitles:@"永久忽略",@"忽略本次", nil];
            alert.tag = 100;
            [alert show];
        }
    }
}
- (void)getAppVersionFailed{
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wo-shou-zhao-pin/id1023641517?mt=8"]];
        }
    }else if (alertView.tag == 100){
        if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"APPSTORE_UPDATE_COUNT"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wo-shou-zhao-pin/id1023641517?mt=8"]];
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
