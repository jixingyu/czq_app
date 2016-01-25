//
//  JobDataSource.m
//  MyRecruitment
//
//  Created by developer on 15/7/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "JobDataSource.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "Interview.h"

@implementation JobDataSource

+ (JobDataSource*)instance{
    static JobDataSource* instance = nil;
    
    @synchronized(self) {
        if(instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return(instance);
}

- (void)loadJobList:(NSString *)searchTitle district:(NSString *)district page:(int)page token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (searchTitle!=nil) {
        [params setObject:searchTitle forKey:@"q"];
    }
    if (district!=nil) {
        [params setObject:district forKey:@"district"];
    }
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
        
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/job_list" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *jobList = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *pageDic = [responseObject objectForKey:@"pagination"];
            int pageIndex = [[pageDic objectForKey:@"page"] intValue];
            int paseSize = [[pageDic objectForKey:@"pageSize"] intValue];
            int total = [[pageDic objectForKey:@"total"] intValue];
            
            NSArray *jobValueList = [responseObject objectForKey:@"data"];
            if (jobValueList.count>0) {
                for(NSDictionary* jobSimple in jobValueList) {
                    Job *job = [Job jobWithJsonDictionary:jobSimple];
                    [jobList addObject:job];
                }
                if ([self.delegate respondsToSelector: @selector(getJobListSuccess:isHasNext:)]) {
                    [self.delegate getJobListSuccess:jobList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }else{
                if ([self.delegate respondsToSelector: @selector(getJobListSuccess:isHasNext:)]) {
                    [self.delegate getJobListSuccess:jobList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getJobListFail:)]) {
                [self.delegate getJobListFail:@"网络发生错误" ];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getJobListFail:)]) {
            [self.delegate getJobListFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];

}
- (void)loadJobDetail:(NSString *)jobId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (jobId!=nil) {
        [params setObject:jobId forKey:@"job_id"];
    }
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/job" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *jobDic = [responseObject objectForKey:@"data"];
            Job *job = [Job jobDeatilWithJsonDictionary:jobDic];
            if([self.delegate respondsToSelector:@selector(getJobDetailSuccess:)]) {
                [self.delegate getJobDetailSuccess:job ];
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getJobDetailtFail)]) {
                [self.delegate getJobDetailtFail];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getJobDetailtFail)]) {
            [self.delegate getJobDetailtFail];
        }
        NSLog(@"Error: %@", error);
    }];

}
- (void)loadJobRecord:(NSString *)token page:(int)page{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];

    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/apply_list" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *jobList = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *pageDic = [responseObject objectForKey:@"pagination"];
            int pageIndex = [[pageDic objectForKey:@"page"] intValue];
            int paseSize = [[pageDic objectForKey:@"pageSize"] intValue];
            int total = [[pageDic objectForKey:@"total"] intValue];
            
            NSArray *jobValueList = [responseObject objectForKey:@"data"];
            if (jobValueList.count>0) {
                for(NSDictionary* jobSimple in jobValueList) {
                    Job *job = [Job jobWithJsonDictionary:jobSimple];
                    [jobList addObject:job];
                }
                if ([self.delegate respondsToSelector: @selector(getJobListSuccess:isHasNext:)]) {
                    [self.delegate getJobListSuccess:jobList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }else{
                if ([self.delegate respondsToSelector: @selector(getJobListSuccess:isHasNext:)]) {
                    [self.delegate getJobListSuccess:jobList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getJobListFail:)]) {
                [self.delegate getJobListFail:@"网络发生错误" ];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getJobListFail:)]) {
            [self.delegate getJobListFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];
    
}
- (void)loadFavoriteList:(NSString *)token page:(int)page{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];

    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/favorite_list" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *jobList = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *pageDic = [responseObject objectForKey:@"pagination"];
            int pageIndex = [[pageDic objectForKey:@"page"] intValue];
            int paseSize = [[pageDic objectForKey:@"pageSize"] intValue];
            int total = [[pageDic objectForKey:@"total"] intValue];
            
            NSArray *jobValueList = [responseObject objectForKey:@"data"];
            if (jobValueList.count>0) {
                for(NSDictionary* jobSimple in jobValueList) {
                    Job *job = [Job jobWithJsonDictionary:jobSimple];
                    [jobList addObject:job];
                }
                if ([self.delegate respondsToSelector: @selector(getJobListSuccess:isHasNext:)]) {
                    [self.delegate getJobListSuccess:jobList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }else{
                if ([self.delegate respondsToSelector: @selector(getJobListSuccess:isHasNext:)]) {
                    [self.delegate getJobListSuccess:jobList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getJobListFail:)]) {
                [self.delegate getJobListFail:@"网络发生错误" ];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getJobListFail:)]) {
            [self.delegate getJobListFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];

}
-(void)collectJob:(NSString *)jobId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (jobId!=nil) {
        [params setObject:jobId forKey:@"job_id"];
    }
    if (token!=nil) {
        [paramToken setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/favorite" requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject==%@",responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            int favorite = [[responseObject objectForKey:@"is_favorite"] intValue];
            if (favorite ==0) {
                if([self.delegate respondsToSelector:@selector(collectJobSuccess:)]) {
                    [self.delegate collectJobSuccess:NO];
                }
            }else{
                if([self.delegate respondsToSelector:@selector(collectJobSuccess:)]) {
                    [self.delegate collectJobSuccess:YES];
                }
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(collectJobFail:type:)]) {
                [self.delegate collectJobFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(collectJobFail:type:)]) {
            [self.delegate collectJobFail:@"收藏失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];

}
- (void)loadInterviewList:(NSString *)token page:(int)page{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];

    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/interview_list" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *interviewList = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *pageDic = [responseObject objectForKey:@"pagination"];
            int pageIndex = [[pageDic objectForKey:@"page"] intValue];
            int paseSize = [[pageDic objectForKey:@"pageSize"] intValue];
            int total = [[pageDic objectForKey:@"total"] intValue];
            
            NSArray *interviewValueList = [responseObject objectForKey:@"data"];
            if (interviewValueList.count>0) {
                for(NSDictionary* interviewSimple in interviewValueList) {
                    Interview *interview = [Interview interviewWithJsonDictionary:interviewSimple];
                    [interviewList addObject:interview];
                }
                if ([self.delegate respondsToSelector: @selector(getInterviewListSuccess:isHasNext:)]) {
                    [self.delegate getInterviewListSuccess:interviewList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }else{
                if ([self.delegate respondsToSelector: @selector(getInterviewListSuccess:isHasNext:)]) {
                    [self.delegate getInterviewListSuccess:interviewList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getInterviewListFail:)]) {
                [self.delegate getInterviewListFail:@"网络发生错误" ];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getInterviewListFail:)]) {
            [self.delegate getInterviewListFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)applyJob:(NSString *)jobId resumeId:(NSString *)resumeId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (jobId!=nil) {
        [params setObject:jobId forKey:@"job_id"];
    }
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (token!=nil) {
        [paramToken setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/api/apply" requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject==%@",responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(applyJobSuccess)]) {
                [self.delegate applyJobSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(applyJobFail:type:)]) {
                [self.delegate applyJobFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(applyJobFail:type:)]) {
            [self.delegate applyJobFail:@"收藏失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];

}
@end
