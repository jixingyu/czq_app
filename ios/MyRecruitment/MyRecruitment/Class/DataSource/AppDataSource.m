//
//  AppDataSource.m
//  EEvent
//
//  Created by developer on 15/6/4.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AppDataSource.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

@implementation AppDataSource

+ (AppDataSource*)instance{
    static AppDataSource* instance = nil;
    
    @synchronized(self) {
        if(instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return(instance);
}
-(void)getAppVersion{
    NSString *urlPath = @"http://itunes.apple.com/lookup?id=999704525";
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject==%@",responseObject);
        
        NSString *count = [responseObject objectForKey:@"resultCount"];
        if ([count intValue] >0) {
            NSArray *list = [responseObject objectForKey:@"results"];
            NSString *version = [[list objectAtIndex:0] objectForKey:@"version"];
            if([self.delegate respondsToSelector:@selector(getAppVersionSuccess:)]) {
                [self.delegate getAppVersionSuccess:version];
            }
        }
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getAppVersionFailed)]) {
            [self.delegate getAppVersionFailed];
        }
        NSLog(@"Error: %@", error);
    }];
}
@end
