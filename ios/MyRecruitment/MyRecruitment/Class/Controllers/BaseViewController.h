//
//  BaseViewController.h
//  MyRecruitment
//
//  Created by developer on 15/6/23.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@class AppDelegate;
@interface BaseViewController : UIViewController{
    LoadingView *loadingView;
}

@property(nonatomic, readonly) AppDelegate *appDelegate;
@property(nonatomic,assign) int backType;

-(void)showAlertView:(NSString *)title message:(NSString *)message;
-(void)backView;

@end
