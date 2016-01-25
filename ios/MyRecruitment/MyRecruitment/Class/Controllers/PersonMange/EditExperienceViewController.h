//
//  EditExperienceViewController.h
//  MyRecruitment
//
//  Created by developer on 15/7/27.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "BaseViewController.h"
#import "Experience.h"
#import "Resume.h"

@interface EditExperienceViewController : BaseViewController

@property(nonatomic,strong) Experience *currentExperience;
@property(nonatomic,strong) Resume *currentResume;

@end
