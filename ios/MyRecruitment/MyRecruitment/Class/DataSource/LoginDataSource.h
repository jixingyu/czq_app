//
//  LoginDataSource.h
//  Moore8
//
//  Created by developer on 14-1-20.
//  Copyright (c) 2014年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtil.h"
#import "User.h"

@protocol LoginDataSourceDelegate <NSObject>
@optional
- (void)loginSuccess:(User *)user;
- (void)loginFailed:(NSString *)message;

- (void)registerSuccess;
- (void)registerFailed:(NSString *)message;

-(void)logoutSuccess;
-(void)logoutFailed;

-(void)saveSuccess;
-(void)saveFail:(NSString *)message type:(int)type;

@end

@interface LoginDataSource : NSObject{

}

@property (nonatomic, assign) id<LoginDataSourceDelegate> delegate;

+ (LoginDataSource*)instance;
-(void)login:(NSString *)email password:(NSString *)password;
-(void)registerUser:(NSString *)email password:(NSString *)password;
-(void)logout:(NSString *)token;
-(void)checkoutToken:(NSString *)token;
-(void)changePerson:(NSString *)realName phone:(NSString *)phone email:(NSString *)email token:(NSString *)token;

@end
