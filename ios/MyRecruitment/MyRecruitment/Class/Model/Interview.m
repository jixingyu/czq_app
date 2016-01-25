//
//  Interview.m
//  MyRecruitment
//
//  Created by developer on 15/7/20.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "Interview.h"

@implementation Interview
@synthesize job,address,company,time,jobId;

- (Interview *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        jobId = [dic getStringValueForKey:@"job_id" defaultValue:@""];
        job = [dic getStringValueForKey:@"job" defaultValue:@""];
        address = [dic getStringValueForKey: @"address" defaultValue: @""];
        company = [dic getStringValueForKey: @"company" defaultValue: @""];
        int time1 = [dic getIntValueForKey:@"interview_time" defaultValue:0];
        time = [NSDate dateWithTimeIntervalSince1970:time1];
    }
    return self;
}
+ (Interview *)interviewWithJsonDictionary:(NSDictionary*)dic{
    return [[Interview alloc] initWithJsonDictionary:dic];
}

@end
