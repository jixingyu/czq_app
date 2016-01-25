//
//  User.m
//  MyRecruitment
//
//  Created by developer on 15/7/14.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize realName,imageName,token,userId,phone,email;

- (User *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        NSDictionary *userDic = [dic objectForKey:@"user"];
        realName = [userDic getStringValueForKey: @"real_name" defaultValue: @""];
        imageName = [userDic getStringValueForKey: @"avatar" defaultValue: @""];
        userId = [userDic getIntValueForKey:@"uid" defaultValue:0];
        phone = [userDic getStringValueForKey: @"mobile" defaultValue: @""];
        email = [userDic getStringValueForKey: @"email" defaultValue: @""];
        token =[dic getStringValueForKey: @"token" defaultValue: @""];
    }
    return self;
}
+ (User *)userWithJsonDictionary:(NSDictionary*)dic{
    return [[User alloc]initWithJsonDictionary:dic];
}
@end
