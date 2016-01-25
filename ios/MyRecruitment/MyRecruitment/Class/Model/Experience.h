//
//  Experience.h
//  MyRecruitment
//
//  Created by developer on 15/7/24.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface Experience : NSObject

@property (nonatomic,strong) NSString *experienceId;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSDate   *startTime;
@property (nonatomic,strong) NSDate   *endTime;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,assign) int isNow;

+ (Experience *)experienceWithJsonDictionary:(NSDictionary*)dic;

@end
