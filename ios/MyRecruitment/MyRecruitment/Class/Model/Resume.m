//
//  Resume.m
//  MyRecruitment
//
//  Created by developer on 15/7/17.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "Resume.h"

@implementation Resume
@synthesize name,resumeId,isEvaluationCompleted,isExperienceCompleted,isPersonalInfoCompleted,realName,gender,birthday,nativePlace,workStartTime,mobile,email,school,major,politicalStatus,degree,evaluation;

- (Resume *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        long myId = [dic getLongLongValueValueForKey:@"id" defaultValue:0];
        resumeId = [NSString stringWithFormat:@"%ld",myId];
        name = [dic getStringValueForKey: @"resume_name" defaultValue: @""];

        isEvaluationCompleted = [dic getBoolValueForKey:@"evaluation_completed" defaultValue:NO];
        isExperienceCompleted = [dic getBoolValueForKey:@"experience_completed" defaultValue:NO];
        isPersonalInfoCompleted = [dic getBoolValueForKey:@"personal_info_completed" defaultValue:NO];
        
        evaluation = [dic getStringValueForKey:@"evaluation" defaultValue:@""];
        realName = [dic getStringValueForKey: @"real_name" defaultValue: @""];
        gender = [dic getIntValueForKey:@"gender" defaultValue:0];
        birthday = [dic getLongLongValueValueForKey:@"birthday" defaultValue:0];
//        birthday = [NSDate dateWithTimeIntervalSince1970:time];
        nativePlace = [dic getStringValueForKey: @"native_place" defaultValue: @""];
        workStartTime = [dic getLongLongValueValueForKey:@"work_start_time" defaultValue:0];
//        workStartTime = [NSDate dateWithTimeIntervalSince1970:time1];
        mobile = [dic getStringValueForKey: @"mobile" defaultValue: @""];
        email = [dic getStringValueForKey: @"email" defaultValue: @""];
        school = [dic getStringValueForKey: @"school" defaultValue: @""];
        major = [dic getStringValueForKey: @"major" defaultValue: @""];
        degree = [dic getStringValueForKey: @"degree" defaultValue: @""];
        politicalStatus = [dic getStringValueForKey: @"political_status" defaultValue: @""];
    }
    return self;
}
+ (Resume *)resumeWithJsonDictionary:(NSDictionary*)dic{
    return [[Resume alloc] initWithJsonDictionary:dic];
}
@end
