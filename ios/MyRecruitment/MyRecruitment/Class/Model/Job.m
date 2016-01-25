//
//  Job.m
//  MyRecruitment
//
//  Created by developer on 15/7/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "Job.h"

@implementation Job
@synthesize jobId,name,degree,salary,company,updateDate,isFavorited,workingYears,recruitNumber,jobType,industry,number,address,companyDescription,benefit,requirement,isApplied;

- (Job *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        jobId = [dic getStringValueForKey:@"job_id" defaultValue:@""];
        name = [dic getStringValueForKey: @"job" defaultValue: @""];
        degree = [dic getStringValueForKey:  @"degree" defaultValue: @""];
        salary = [dic getStringValueForKey: @"salary" defaultValue: @""];
        company = [dic getStringValueForKey: @"company" defaultValue: @""];
        int time = [dic getIntValueForKey:@"date" defaultValue:0];
        updateDate = [NSDate dateWithTimeIntervalSince1970:time];
        isFavorited = [dic getBoolValueForKey:@"is_favorite" defaultValue:NO];
    }
    return self;
}
+ (Job *)jobWithJsonDictionary:(NSDictionary*)dic{
    return [[Job alloc] initWithJsonDictionary:dic];
}
- (Job *)initDetailWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        jobId = [dic getStringValueForKey:@"id" defaultValue:@""];
        name = [dic getStringValueForKey: @"name" defaultValue: @""];
        degree = [dic getStringValueForKey:  @"degree" defaultValue: @""];
        salary = [dic getStringValueForKey: @"salary" defaultValue: @""];
        int time = [dic getIntValueForKey:@"date" defaultValue:0];
        updateDate = [NSDate dateWithTimeIntervalSince1970:time];
        isFavorited = [dic getBoolValueForKey:@"is_favorite" defaultValue:NO];
        
        isApplied = [dic getBoolValueForKey:@"applied" defaultValue:NO];
        workingYears = [dic getStringValueForKey:@"working_years" defaultValue:@""];
        recruitNumber = [dic getStringValueForKey:@"recruit_number" defaultValue:@""];
        jobType = [dic getStringValueForKey:@"job_type" defaultValue:@""];
        
        NSString *dic1 = [dic objectForKey:@"benefit"];
        if (dic1!=nil&&![dic1 isEqual:[NSNull null]]) {
            NSError *serializationError = nil;
            NSData* xmlData = [dic1 dataUsingEncoding:NSUTF8StringEncoding];
            benefit = [NSJSONSerialization JSONObjectWithData:xmlData options:NSJSONReadingMutableContainers error:&serializationError];
        }
        NSString *req = [dic objectForKey:@"requirement"];
        requirement = [req componentsSeparatedByString:@"\r\n"];
        
        company = [dic getStringValueForKey: @"c_name" defaultValue: @""];
        industry = [dic getStringValueForKey: @"c_industry" defaultValue: @""];
        number = [dic getStringValueForKey: @"c_number" defaultValue: @""];
        address = [dic getStringValueForKey: @"c_address" defaultValue: @""];
        companyDescription = [dic getStringValueForKey: @"c_description" defaultValue: @""];
    }
    return self;
}
+ (Job *)jobDeatilWithJsonDictionary:(NSDictionary*)dic{
    return [[Job alloc] initDetailWithJsonDictionary:dic];
}
@end
