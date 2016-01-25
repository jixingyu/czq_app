//
//  AppconfigDataSource.m
//  MyRecruitment
//
//  Created by developer on 15/7/10.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AppconfigDataSource.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

@implementation AppconfigDataSource

+ (AppconfigDataSource*)instance{
    static AppconfigDataSource* instance = nil;
    
    @synchronized(self) {
        if(instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return(instance);
}

- (void)loadAppConfig:(NSString *)version{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (version!=nil) {
        [params setObject:version forKey:@"version"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/appconfig" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *appDic = [responseObject objectForKey:@"data"];
            AppConfig *appConfig = [AppConfig appConfigWithJsonDictionary:appDic];
            if([self.delegate respondsToSelector:@selector(getAppConfigSuccess:)]) {
                [self.delegate getAppConfigSuccess:appConfig];
            }
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getAppConfigtFail:)]) {
            [self.delegate getAppConfigtFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];
     
}
- (void)loadAppAbout{
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/about" requestdomain:kAppMainURL queryParameters:nil secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *appDic = [responseObject objectForKey:@"data"];
            About *about = [About aboutWithJsonDictionary:appDic];
            if([self.delegate respondsToSelector:@selector(getAppAboutSuccess:)]) {
                [self.delegate getAppAboutSuccess:about];
            }
        } 
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getAppAboutFail:)]) {
            [self.delegate getAppAboutFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];
}
@end
