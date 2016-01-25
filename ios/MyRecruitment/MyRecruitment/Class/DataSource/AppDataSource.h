//
//  AppDataSource.h
//  EEvent
//
//  Created by developer on 15/6/4.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtil.h"

@protocol AppDataSourceDelegate <NSObject>
@optional
- (void)getAppVersionSuccess:(NSString *)version;
- (void)getAppVersionFailed;
@end


@interface AppDataSource : NSObject

@property (nonatomic, assign) id<AppDataSourceDelegate> delegate;

+ (AppDataSource*)instance;
-(void)getAppVersion;
@end
