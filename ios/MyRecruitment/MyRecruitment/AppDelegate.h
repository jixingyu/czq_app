//
//  AppDelegate.h
//  MyRecruitment
//
//  Created by developer on 15/6/23.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "AppconfigDataSource.h"
#import "AppConfig.h"
#import "User.h"
#import "LoginDataSource.h"
#import "AppDataSource.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,AppConfigDelegate,LoginDataSourceDelegate,AppDataSourceDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AFHTTPRequestOperationManager *networkManager;
@property (nonatomic, strong) AppConfig *currentAppConfig;
@property (strong, nonatomic) User *loginUser;
@property (assign, nonatomic) BOOL isFavoriteChanged;
@property (assign, nonatomic) BOOL isLoginChanged;
@property (assign, nonatomic) BOOL isResumeChanged;

-(void)getAppConfig;
@end

