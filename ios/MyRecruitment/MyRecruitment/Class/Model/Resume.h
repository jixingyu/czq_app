//
//  Resume.h
//  MyRecruitment
//
//  Created by developer on 15/7/17.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface Resume : NSObject

@property (nonatomic,strong) NSString *resumeId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) BOOL isEvaluationCompleted;
@property (nonatomic,assign) BOOL isPersonalInfoCompleted;
@property (nonatomic,assign) BOOL isExperienceCompleted;

@property (nonatomic,strong) NSString *evaluation;
@property (nonatomic,strong) NSString *realName;
@property (nonatomic,assign) int      gender;
@property (nonatomic,assign) long   birthday;
@property (nonatomic,strong) NSString *nativePlace;
@property (nonatomic,assign) long   workStartTime;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *school;
@property (nonatomic,strong) NSString *major;
@property (nonatomic,strong) NSString *degree;
@property (nonatomic,strong) NSString *politicalStatus;

+ (Resume *)resumeWithJsonDictionary:(NSDictionary*)dic;

@end
