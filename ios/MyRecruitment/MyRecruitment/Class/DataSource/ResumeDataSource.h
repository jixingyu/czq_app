//
//  ResumeDataSource.h
//  MyRecruitment
//
//  Created by developer on 15/7/17.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtil.h"
#import "Resume.h"
#import "Experience.h"

@protocol ResumeDataSourceDelegate <NSObject>

@optional
-(void)getResumeListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext;
-(void)getResumeListFail:(NSString *)message;

-(void)getExperienceListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext;
-(void)getExperienceListFail:(NSString *)message;

- (void)createResumeSuccess:(Resume *)resume;
- (void)createResumeFail:(NSString *)message type:(int)type;

- (void)changeExperienceSuccess;
- (void)changeExperienceFail:(NSString *)message type:(int)type;

- (void)getResumeDetailSuccess:(Resume *)resume;
- (void)getResumeDetailFail;

- (void)deleteResumeSuccess;
- (void)deleteResumeFail:(NSString *)message type:(int)type;

- (void)deleteExperienceSuccess;
- (void)deleteExperienceFail:(NSString *)message type:(int)type;

- (void)changeResumeNameSuccess;
- (void)changeResumeNameFail:(NSString *)message type:(int)type;

- (void)changePersonInfoSuccess;
- (void)changePersonInfoFail:(NSString *)message type:(int)type;

- (void)saveEvaluationSuccess;
- (void)saveEvaluationFail:(NSString *)message type:(int)type;
@end

@interface ResumeDataSource : NSObject

@property(nonatomic,assign) id<ResumeDataSourceDelegate> delegate;

+ (ResumeDataSource*)instance;

- (void)loadResumeList:(NSString *)token;
- (void)createResume:(NSString *)token;
- (void)loadResumeDetail:(NSString *)resumeId token:(NSString *)token;
- (void)deleteResume:(NSString *)resumeId token:(NSString *)token;
- (void)loadExperienceList:(NSString *)resumeId token:(NSString *)token;
- (void)deleteExperience:(NSString *)experienceId token:(NSString *)token;
- (void)saveEvaluation:(NSString *)resumeId content:(NSString *)content token:(NSString *)token;

- (void)changeResumeName:(NSString *)name resumeId:(NSString *)resumeId token:(NSString *)token;
- (void)changePersonInfo:(NSString *)realName
                resumeId:(NSString *)resumeId
                  gender:(int)gender
                birthday:(long)birthday
             nativePlace:(NSString *)nativePlace
           workStartTime:(long)workStartTime
                  mobile:(NSString *)mobile
                   email:(NSString *)email
                  school:(NSString *)school
                   major:(NSString *)major
                  degree:(NSString *)degree
         politicalStatus:(NSString *)politicalStatus
                   token:(NSString *)token;

- (void)changeExperience:(NSString *)resumeId
            experienceId:(NSString *)experienceId
                 company:(NSString *)company
               startTime:(NSDate *)startTime
                 endTime:(NSDate *)endTime
                   isNow:(BOOL)isNow
                 content:(NSString *)content
                   token:(NSString *)token;
@end
