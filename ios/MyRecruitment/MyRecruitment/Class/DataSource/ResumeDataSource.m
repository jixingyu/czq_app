//
//  ResumeDataSource.m
//  MyRecruitment
//
//  Created by developer on 15/7/17.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "ResumeDataSource.h"
#import "AppDelegate.h"
#import "Experience.h"

@implementation ResumeDataSource

+ (ResumeDataSource*)instance{
    static ResumeDataSource* instance = nil;
    
    @synchronized(self) {
        if(instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return(instance);
}
- (void)loadResumeList:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }

    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/resume_list" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *resumeList = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSArray *resumeValueList = [responseObject objectForKey:@"data"];
            
            NSDictionary *pageDic = [responseObject objectForKey:@"pagination"];
            int pageIndex = [[pageDic objectForKey:@"page"] intValue];
            int paseSize = [[pageDic objectForKey:@"pageSize"] intValue];
            int total = [[pageDic objectForKey:@"total"] intValue];

            if (resumeValueList.count>0) {
                for(NSDictionary* resumeSimple in resumeValueList) {
                    Resume *resume = [Resume resumeWithJsonDictionary:resumeSimple];
                    [resumeList addObject:resume];
                }
                if ([self.delegate respondsToSelector: @selector(getResumeListSuccess:isHasNext:)]) {
                    [self.delegate getResumeListSuccess:resumeList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }else{
                if ([self.delegate respondsToSelector: @selector(getResumeListSuccess:isHasNext:)]) {
                    [self.delegate getResumeListSuccess:resumeList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getResumeListFail:)]) {
                [self.delegate getResumeListFail:@"网络发生错误" ];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getResumeListFail:)]) {
            [self.delegate getResumeListFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)createResume:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/add_resume" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *resumeDic = [responseObject objectForKey:@"data"];
            Resume *resume = [Resume resumeWithJsonDictionary:resumeDic];
            if([self.delegate respondsToSelector:@selector(createResumeSuccess:)]) {
                [self.delegate createResumeSuccess:resume];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(createResumeFail:type:)]) {
                [self.delegate createResumeFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(createResumeFail:type:)]) {
            [self.delegate createResumeFail:@"创建失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)loadResumeDetail:(NSString *)resumeId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/resume" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSDictionary *resumeDic = [responseObject objectForKey:@"data"];
            Resume *resume = [Resume resumeWithJsonDictionary:resumeDic];
            if([self.delegate respondsToSelector:@selector(getResumeDetailSuccess:)]) {
                [self.delegate getResumeDetailSuccess:resume];
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getResumeDetailFail)]) {
                [self.delegate getResumeDetailFail];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getResumeDetailFail)]) {
            [self.delegate getResumeDetailFail];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)deleteResume:(NSString *)resumeId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/resume" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] DELETE:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(deleteResumeSuccess)]) {
                [self.delegate deleteResumeSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(deleteResumeFail:type:)]) {
                [self.delegate deleteResumeFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(deleteResumeFail:type:)]) {
            [self.delegate deleteResumeFail:@"删除失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)changeResumeName:(NSString *)name resumeId:(NSString *)resumeId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (token!=nil) {
        [paramToken setObject:token forKey:@"token"];
    }
    if (name!=nil) {
        [params setObject:name forKey:@"resume_name"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/resume_name" requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(changeResumeNameSuccess)]) {
                [self.delegate changeResumeNameSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(changeResumeNameFail:type:)]) {
                [self.delegate changeResumeNameFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(changeResumeNameFail:type:)]) {
            [self.delegate changeResumeNameFail:@"保存失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)changePersonInfo:(NSString *)realName
                resumeId:(NSString *)resumeId
                  gender:(int)gender
                birthday:(long )birthday
             nativePlace:(NSString *)nativePlace
           workStartTime:(long)workStartTime
                  mobile:(NSString *)mobile
                   email:(NSString *)email
                  school:(NSString *)school
                   major:(NSString *)major
                  degree:(NSString *)degree
         politicalStatus:(NSString *)politicalStatus
                   token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (realName!=nil) {
        [params setObject:realName forKey:@"real_name"];
    }
    [params setObject:[NSString stringWithFormat:@"%d",gender] forKey:@"gender"];
    [params setObject:[NSString stringWithFormat:@"%ld",birthday] forKey:@"birthday"];
    if (nativePlace!=nil) {
        [params setObject:nativePlace forKey:@"native_place"];
    }
    [params setObject:[NSString stringWithFormat:@"%ld",workStartTime] forKey:@"work_start_time"];
    if (mobile!=nil) {
        [params setObject:mobile forKey:@"mobile"];
    }
    if (email!=nil) {
        [params setObject:email forKey:@"email"];
    }
    if (school!=nil) {
        [params setObject:school forKey:@"school"];
    }
    if (major!=nil) {
        [params setObject:major forKey:@"major"];
    }
    if (degree!=nil) {
        [params setObject:degree forKey:@"degree"];
    }
    if (politicalStatus!=nil) {
        [params setObject:politicalStatus forKey:@"political_status"];
    }
    if (token!=nil) {
        [paramToken setObject:token forKey:@"token"];
    }

    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/resume" requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(changePersonInfoSuccess)]) {
                [self.delegate changePersonInfoSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(changePersonInfoFail:type:)]) {
                [self.delegate changePersonInfoFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(changePersonInfoFail:type:)]) {
            [self.delegate changePersonInfoFail:@"保存失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)loadExperienceList:(NSString *)resumeId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/experience_list" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *experienceList = [[NSMutableArray alloc] init];
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            NSArray *experienceValueList = [responseObject objectForKey:@"data"];
            
            NSDictionary *pageDic = [responseObject objectForKey:@"pagination"];
            int pageIndex = [[pageDic objectForKey:@"page"] intValue];
            int paseSize = [[pageDic objectForKey:@"pageSize"] intValue];
            int total = [[pageDic objectForKey:@"total"] intValue];
            
            if (experienceValueList.count>0) {
                for(NSDictionary* experienceSimple in experienceValueList) {
                    Experience *experience = [Experience experienceWithJsonDictionary:experienceSimple];
                    [experienceList addObject:experience];
                }
                if ([self.delegate respondsToSelector: @selector(getExperienceListSuccess:isHasNext:)]) {
                    [self.delegate getExperienceListSuccess:experienceList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }else{
                if ([self.delegate respondsToSelector: @selector(getExperienceListSuccess:isHasNext:)]) {
                    [self.delegate getExperienceListSuccess:experienceList isHasNext:pageIndex*paseSize<total?YES:NO];
                }
            }
        }else{
            if([self.delegate respondsToSelector:@selector(getExperienceListFail:)]) {
                [self.delegate getExperienceListFail:@"网络发生错误" ];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(getResumeListFail:)]) {
            [self.delegate getResumeListFail:@"网络发生错误" ];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)changeExperience:(NSString *)resumeId
            experienceId:(NSString *)experienceId
                 company:(NSString *)company
               startTime:(NSDate *)startTime
                 endTime:(NSDate *)endTime
                   isNow:(BOOL)isNow
                 content:(NSString *)content
                   token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (experienceId!=nil) {
        [params setObject:experienceId forKey:@"experience_id"];
    }
    if (startTime!=nil) {
        [params setObject:[NSString stringWithFormat:@"%ld",(long)[startTime timeIntervalSince1970]] forKey:@"start_time"];
    }
    if (company!=nil) {
        [params setObject:company forKey:@"company"];
    }
    if (isNow) {
        [params setObject:[NSString stringWithFormat:@"%d",-1] forKey:@"end_time"];
    }else{
        if (endTime!=nil) {
            [params setObject:[NSString stringWithFormat:@"%ld",(long)[endTime timeIntervalSince1970]] forKey:@"end_time"];
        }
    }
    
    if (content!=nil) {
        [params setObject:content forKey:@"description"];
    }
    if (token!=nil) {
        [paramToken setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/experience" requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(changeExperienceSuccess)]) {
                [self.delegate changeExperienceSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(changeExperienceFail:type:)]) {
                [self.delegate changeExperienceFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(changePersonInfoFail:type:)]) {
            [self.delegate changePersonInfoFail:@"保存失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)deleteExperience:(NSString *)experienceId token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (experienceId!=nil) {
        [params setObject:experienceId forKey:@"experience_id"];
    }
    if (token!=nil) {
        [params setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/experience" requestdomain:kAppMainURL queryParameters:params secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] DELETE:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(deleteExperienceSuccess)]) {
                [self.delegate deleteExperienceSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(deleteExperienceFail:type:)]) {
                [self.delegate deleteExperienceFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(deleteExperienceFail:type:)]) {
            [self.delegate deleteExperienceFail:@"删除失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];
}
- (void)saveEvaluation:(NSString *)resumeId content:(NSString *)content token:(NSString *)token{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *paramToken = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (resumeId!=nil) {
        [params setObject:resumeId forKey:@"resume_id"];
    }
    if (content!=nil) {
        [params setObject:content forKey:@"evaluation"];
    }
    if (token!=nil) {
        [paramToken setObject:token forKey:@"token"];
    }
    
    NSString *urlPath = [NSString stringWithFormat: @"%@", [NSString getURL:@"app/resume_api/evaluation" requestdomain:kAppMainURL queryParameters:paramToken secureConnection:false]];
    NSLog(@"path==%@",urlPath);
    
    [[AppDelegateAccessor networkManager] POST:urlPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int status = [[responseObject objectForKey:@"code"] intValue];
        if (status==1) {
            if([self.delegate respondsToSelector:@selector(saveEvaluationSuccess)]) {
                [self.delegate saveEvaluationSuccess];
            }
        }else{
            NSString *error = [responseObject objectForKey:@"error"];
            NSString *errorCode = [responseObject objectForKey:@"code"];
            if ([self.delegate respondsToSelector: @selector(saveEvaluationFail:type:)]) {
                [self.delegate saveEvaluationFail:error type:[errorCode intValue]==40103?1:0];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector: @selector(saveEvaluationFail:type:)]) {
            [self.delegate saveEvaluationFail:@"保存失败,请查看网络是否正常" type:0];
        }
        NSLog(@"Error: %@", error);
    }];

}
@end
