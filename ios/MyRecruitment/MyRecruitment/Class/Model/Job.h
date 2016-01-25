//
//  Job.h
//  MyRecruitment
//
//  Created by developer on 15/7/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface Job : NSObject

@property (nonatomic,strong) NSString *jobId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *degree;
@property (nonatomic,strong) NSString *salary;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSDate *updateDate;
@property (nonatomic,assign) BOOL isFavorited;

@property (nonatomic,strong) NSString *workingYears;
@property (nonatomic,strong) NSString *recruitNumber;
@property (nonatomic,strong) NSString *jobType;

@property (nonatomic,strong) NSArray *benefit;
@property (nonatomic,strong) NSArray *requirement;

@property (nonatomic,assign) BOOL isApplied;
@property (nonatomic,strong) NSString *industry;
@property (nonatomic,strong) NSString *number;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *companyDescription;

+ (Job *)jobWithJsonDictionary:(NSDictionary*)dic;
+ (Job *)jobDeatilWithJsonDictionary:(NSDictionary*)dic;

@end
