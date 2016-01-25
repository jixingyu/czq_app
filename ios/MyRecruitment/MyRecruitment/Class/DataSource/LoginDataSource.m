//
//  LoginDataSource.m
//  Moore8
//
//  Created by developer on 14-1-20.
//  Copyright (c) 2014年 developer. All rights reserved.
//

#import "LoginDataSource.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

@implementation LoginDataSource

+ (LoginDataSource*)instance{
    static LoginDataSource* instance = nil;
	
	@synchronized(self) {
		if(instance == nil) {
			instance = [[self alloc] init];
		}
	}
	return(instance);
}

-(void)login:(NSString *)email password:(NSString *)password{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	
    if (email !=nil) {
		[params setObject:email forKey:@"email"];
	}
    if (password !=nil) {
		[params setObject:password forKey:@"password"];
	}
    NSString *path= [NSString stringWithFormat:@"app/user_api/login"];
	
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:path requestdomain:kAppMainURL queryParameters:nil secureConnection:false]];
    NSLog(@"===%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"Request Successful, response '%@'", responseObject);
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieJar cookies]) {
            NSLog(@"%@", cookie);
        }
        NSDictionary *result = responseObject;
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code==1) {
            User *user = [User userWithJsonDictionary:result];
            if([self.delegate respondsToSelector:@selector(loginSuccess:)]) {
                [self.delegate loginSuccess:user];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            if([self.delegate respondsToSelector:@selector(loginFailed:)]) {
                [self.delegate loginFailed:error];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(loginFailed:)]) {
            [self.delegate loginFailed:@"网络连接超时"];
        }
        
    }];
}
-(void)registerUser:(NSString *)email password:(NSString *)password{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (email !=nil) {
        [params setObject:email forKey:@"email"];
    }
    if (password !=nil) {
        [params setObject:password forKey:@"password"];
    }
    NSString *path= [NSString stringWithFormat:@"app/user_api/register"];
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:path requestdomain:kAppMainURL queryParameters:nil secureConnection:false]];
    NSLog(@"===%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"Request Successful, response '%@'", responseObject);
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code==1) {
            if([self.delegate respondsToSelector:@selector(registerSuccess)]) {
                [self.delegate registerSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            if([self.delegate respondsToSelector:@selector(registerFailed:)]) {
                [self.delegate registerFailed:error];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(registerFailed:)]) {
            [self.delegate registerFailed:@"网络连接超时"];
        }
        
    }];
}
-(void)logout:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token !=nil) {
        [params setObject:token forKey:@"token"];
    }
    NSString *path= [NSString stringWithFormat:@"app/user_api/logout"];
	
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:path requestdomain:kAppMainURL queryParameters:nil secureConnection:false]];
    NSLog(@"===%@",urlPath);
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"Request Successful, response '%@'", responseObject);
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code==1) {
            if([self.delegate respondsToSelector:@selector(logoutSuccess)]) {
                [self.delegate logoutSuccess];
            }
        }else{
            if([self.delegate respondsToSelector:@selector(logoutFailed)]) {
                [self.delegate logoutFailed];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(logoutFailed)]) {
            [self.delegate logoutFailed];
        }
        
    }];
}
-(void)checkoutToken:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token !=nil) {
        [params setObject:token forKey:@"token"];
    }
    NSString *path= [NSString stringWithFormat:@"app/user_api/verify_token"];
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:path requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"===%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"Request Successful, response '%@'", responseObject);
        NSDictionary *result = responseObject;
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieJar cookies]) {
            NSLog(@"%@", cookie);
        }
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code==1) {
            User *user = [User userWithJsonDictionary:result];
            if([self.delegate respondsToSelector:@selector(loginSuccess:)]) {
                [self.delegate loginSuccess:user];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            if([self.delegate respondsToSelector:@selector(loginFailed:)]) {
                [self.delegate loginFailed:error];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(loginFailed:)]) {
            [self.delegate loginFailed:@"网络连接超时"];
        }
        
    }];
}
-(void)changePerson:(NSString *)realName phone:(NSString *)phone email:(NSString *)email token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (realName !=nil) {
        [params setObject:realName forKey:@"real_name"];
    }
    if (phone !=nil) {
        [params setObject:phone forKey:@"mobile"];
    }
    if (email !=nil) {
        [params setObject:email forKey:@"email"];
    }
    if (token !=nil) {
        [paramToken setObject:token forKey:@"token"];
    }
    NSString *path= [NSString stringWithFormat:@"app/user_api/edit"];
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:path requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"===%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"Request Successful, response '%@'", responseObject);
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code==1) {
            if([self.delegate respondsToSelector:@selector(saveSuccess)]) {
                [self.delegate saveSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if([self.delegate respondsToSelector:@selector(saveFail:type:)]) {
                [self.delegate saveFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(saveFail:type:)]) {
            [self.delegate saveFail:@"保存失败,请查看网络是否正常" type:0];
        }
        
    }];

}
@end
