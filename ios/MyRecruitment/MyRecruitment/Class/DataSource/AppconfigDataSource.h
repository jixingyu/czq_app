//
//  AppconfigDataSource.h
//  MyRecruitment
//
//  Created by developer on 15/7/10.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtil.h"
#import "AppConfig.h"
#import "About.h"

@protocol AppConfigDelegate <NSObject>

@optional
-(void)getAppConfigSuccess:(AppConfig *)appConfig;
-(void)getAppConfigtFail:(NSString *)message;

-(void)getAppAboutSuccess:(About *)about;
-(void)getAppAboutFail:(NSString *)message;

@end

@interface AppconfigDataSource : NSObject

@property(nonatomic,assign) id<AppConfigDelegate> delegate;

+ (AppconfigDataSource*)instance;

- (void)loadAppConfig:(NSString *)version;
- (void)loadAppAbout;

@end
