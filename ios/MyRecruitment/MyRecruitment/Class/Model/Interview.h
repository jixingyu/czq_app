//
//  Interview.h
//  MyRecruitment
//
//  Created by developer on 15/7/20.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface Interview : NSObject

@property (nonatomic,strong) NSString *jobId;
@property (nonatomic,strong) NSString *job;
@property (nonatomic,strong) NSDate *time;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *company;

+ (Interview *)interviewWithJsonDictionary:(NSDictionary*)dic;

@end
