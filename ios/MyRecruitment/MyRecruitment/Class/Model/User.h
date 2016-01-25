//
//  User.h
//  MyRecruitment
//
//  Created by developer on 15/7/14.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface User : NSObject

@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,strong) NSString *realName;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,assign) int userId;
@property (nonatomic,strong) NSString *token;

+ (User *)userWithJsonDictionary:(NSDictionary*)dic;
@end
