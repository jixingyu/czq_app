//
//  About.m
//  MyRecruitment
//
//  Created by developer on 15/7/29.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "About.h"

@implementation About
@synthesize introduction,phone,qq;

- (About *)initWithJsonDictionary:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        introduction = [dic getStringValueForKey:@"introduction" defaultValue:@""];
        phone = [dic getStringValueForKey:@"phone" defaultValue:@""];
        qq = [dic getStringValueForKey: @"qq" defaultValue: @""];
    }
    return self;
}

+ (About *)aboutWithJsonDictionary:(NSDictionary*)dic{
    return [[About alloc] initWithJsonDictionary:dic];
}
@end
