//
//  JobDataSource.h
//  MyRecruitment
//
//  Created by developer on 15/7/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringUtil.h"
#import "Job.h"

@protocol JobDataSourceDelegate <NSObject>

@optional
-(void)getJobListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext;
-(void)getJobListFail:(NSString *)message;

-(void)getJobDetailSuccess:(Job *)job;
-(void)getJobDetailtFail;

-(void)collectJobSuccess:(BOOL)isFavorite;
-(void)collectJobFail:(NSString *)message type:(int)type;

-(void)getInterviewListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext;
-(void)getInterviewListFail:(NSString *)message;

-(void)applyJobSuccess;
-(void)applyJobFail:(NSString *)message type:(int)type;
@end


@interface JobDataSource : NSObject

@property(nonatomic,assign) id<JobDataSourceDelegate> delegate;

+ (JobDataSource*)instance;

- (void)loadJobList:(NSString *)searchTitle district:(NSString *)district page:(int)page token:(NSString *)token;;
- (void)loadJobDetail:(NSString *)jobId token:(NSString *)token;;
- (void)loadJobRecord:(NSString *)token page:(int)page;
- (void)loadFavoriteList:(NSString *)token page:(int)page;
- (void)loadInterviewList:(NSString *)token page:(int)page;

- (void)collectJob:(NSString *)jobId token:(NSString *)token;
- (void)applyJob:(NSString *)jobId resumeId:(NSString *)resumeId token:(NSString *)token;

@end
