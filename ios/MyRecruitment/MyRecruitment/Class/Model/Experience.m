//
//  Experience.m
//  MyRecruitment
//
//  Created by developer on 15/7/24.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "Experience.h"

@implementation Experience
@synthesize experienceId,company,startTime,endTime,content,isNow;

- (Experience *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        experienceId = [dic getStringValueForKey: @"id" defaultValue: @""];
        company = [dic getStringValueForKey: @"company" defaultValue: @""];
        int time1 = [dic getIntValueForKey:@"start_time" defaultValue:0];
        startTime = [NSDate dateWithTimeIntervalSince1970:time1];
        int time2 = [dic getIntValueForKey:@"end_time" defaultValue:0];
        isNow = time2 == -1?YES:NO;
        if (isNow) {
            endTime = [NSDate date];
        }else{
            endTime = [NSDate dateWithTimeIntervalSince1970:time2];
        }
        
        content = [dic getStringValueForKey: @"description" defaultValue: @""];
    }
    return self;
}
+ (Experience *)experienceWithJsonDictionary:(NSDictionary*)dic{
    return [[Experience alloc] initWithJsonDictionary:dic];
}

@end
