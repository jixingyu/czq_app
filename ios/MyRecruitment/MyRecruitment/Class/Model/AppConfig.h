//
//  AppConfig.h
//  MyRecruitment
//
//  Created by developer on 15/7/10.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionaryAdditions.h"

@interface AppConfig : NSObject

@property (nonatomic,strong) NSArray *degreeList;
@property (nonatomic,strong) NSArray *salaryList;
@property (nonatomic,strong) NSArray *districtList;
@property (nonatomic,strong) NSArray *workYearsList;
@property (nonatomic,strong) NSArray *politicalStatusList;
@property (nonatomic,assign) int resumeLimit;
@property (nonatomic,assign) BOOL isForce;

+ (AppConfig *)appConfigWithJsonDictionary:(NSDictionary*)dic;

@end
