//
//  LoadingView.m
//  MyRecruitment
//
//  Created by developer on 15/7/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

-(void)initView{
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568:480)];
    blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:blackView];
    
    UIView *loadIngBgView = [[UIView alloc] initWithFrame:CGRectMake(120, IS_IPHONE5?180:140, 80, 80)];
    loadIngBgView.backgroundColor = [UIColor blackColor];
    loadIngBgView.layer.cornerRadius = 5.0;
    loadIngBgView.clipsToBounds = YES;
    [self addSubview:loadIngBgView];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.frame = CGRectMake(25, 10, 30, 30);
    [activityIndicatorView startAnimating];
    [loadIngBgView addSubview:activityIndicatorView];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, 70, 30)];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.text = @"正在加载...";
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont systemFontOfSize:12];
    [loadIngBgView addSubview:loadingLabel];
}

@end
