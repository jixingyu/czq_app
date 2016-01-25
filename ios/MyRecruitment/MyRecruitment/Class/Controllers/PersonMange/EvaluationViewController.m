//
//  EvaluationViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/28.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "EvaluationViewController.h"
#import "ResumeDataSource.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface EvaluationViewController ()<UITextViewDelegate,ResumeDataSourceDelegate>{
    UITextView *contentTextView;
    
    IBOutlet UIView *saveView;
    IBOutlet UIButton *saveButton;
}

@end

@implementation EvaluationViewController
@synthesize currentResume;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自我评价";
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 64, 290, 200)];
    contentTextView.layer.borderColor = [UIColor colorWithRed:242/255. green:105/255. blue:63/255. alpha:1].CGColor;
    contentTextView.layer.borderWidth = 1;
    contentTextView.tag = 101;
    contentTextView.delegate = self;
    [self.view addSubview:contentTextView];
    contentTextView.text = self.currentResume.evaluation;
    
    saveView.frame = CGRectMake(0, IS_IPHONE5?568-56-64:480-56-64, 320, 56);
    saveButton.layer.cornerRadius = 20;
    saveButton.clipsToBounds = YES;
    [self.view addSubview:saveView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [ResumeDataSource instance].delegate = self;
}
-(IBAction)downKeyboard:(id)sender{
    [contentTextView resignFirstResponder];
}
-(IBAction)saveEvaluation:(id)sender{
    [[ResumeDataSource instance] saveEvaluation:self.currentResume.resumeId content:self.currentResume.evaluation token:self.appDelegate.loginUser.token];
}
- (void)saveEvaluationSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"保存成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    alert.tag = 101;
    [alert show];
}
- (void)saveEvaluationFail:(NSString *)message type:(int)type{
    if (type==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        alert.tag = 102;
        [alert show];
    }else{
        [self showAlertView:@"提示" message:message];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 101){
        if (buttonIndex == 0) {
            self.appDelegate.isResumeChanged = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag == 102){
        if (buttonIndex == 1) {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            loginViewController.backType = 1;
            [self.navigationController pushViewController:loginViewController animated:YES];
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            }
        }else{
            self.appDelegate.loginUser = nil;
            self.appDelegate.isLoginChanged = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LOGIN_TOKEN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
#pragma mark -
#pragma mark UITextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *temp = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.currentResume.evaluation = temp;
    return YES;
}
@end
