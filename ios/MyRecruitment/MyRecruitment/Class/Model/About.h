//
//  About.h
//  MyRecruitment
//
//  Created by developer on 15/7/29.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface About : NSObject

@property (nonatomic,strong) NSString *introduction;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *qq;

+ (About *)aboutWithJsonDictionary:(NSDictionary*)dic;

@end

