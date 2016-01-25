//
//  AppConfig.m
//  MyRecruitment
//
//  Created by developer on 15/7/10.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig
@synthesize degreeList,salaryList,districtList,workYearsList,resumeLimit,politicalStatusList,isForce;

- (AppConfig *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        degreeList = [dic objectForKey:@"degree"];
        salaryList = [dic objectForKey:@"salary"];
        districtList = [dic objectForKey:@"district"];
        workYearsList = [dic objectForKey:@"working_years"];
        politicalStatusList = [dic objectForKey:@"political_status"];
        resumeLimit = [dic getIntValueForKey:@"resume_limit" defaultValue:0];
        isForce = [dic getBoolValueForKey:@"force_update" defaultValue:NO];
    }
    return self;
}
+ (AppConfig *)appConfigWithJsonDictionary:(NSDictionary*)dic{
    return [[AppConfig alloc] initWithJsonDictionary:dic];
}
@end
