//
//  LoginViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/14.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginDataSource.h"
#import "AppDelegate.h"
#import "WebViewController.h"

@interface LoginViewController ()<LoginDataSourceDelegate>{
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *registerButton;
    
    IBOutlet UIView *loginView;
    IBOutlet UIView *registerView;
    
    IBOutlet UIButton *loginViewButton;
    IBOutlet UIButton *registerViewButton;
    
    IBOutlet UITextField *loginNameTextfield;
    IBOutlet UITextField *loginPasswordTextfield;
    
    IBOutlet UITextField *registerNameTextfield;
    IBOutlet UITextField *registerPasswordTextfield;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 0.6)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView];
    
    loginView.frame = CGRectMake(0, 45, 320, 240);
    registerView.frame = CGRectMake(0, 45, 320, 240);
    [self.view addSubview:loginView];
    [self.view addSubview:registerView];
    loginViewButton.layer.cornerRadius = 20;
    loginViewButton.clipsToBounds = YES;
    registerViewButton.layer.cornerRadius = 20;
    registerViewButton.clipsToBounds = YES;
    
    for (int i=0; i<2; i++) {
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 60*(i+1), 320, 0.6)];
        lineView1.backgroundColor = [UIColor grayColor];
        [loginView addSubview:lineView1];
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 60*(i+1), 320, 0.6)];
        lineView2.backgroundColor = [UIColor grayColor];
        [registerView addSubview:lineView2];
    }
    
    [self setButtonSelect:loginButton];
    
    [LoginDataSource instance].delegate = self;
}
-(IBAction)setButtonSelect:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button == loginButton) {
        [loginButton setBackgroundColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerButton setBackgroundColor:[UIColor whiteColor]];
        [registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        self.title = @"登录";
        loginView.hidden = NO;
        registerView.hidden = YES;
    }else{
        [loginButton setBackgroundColor:[UIColor whiteColor]];
        [loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [registerButton setBackgroundColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.title = @"注册";
        loginView.hidden = YES;
        registerView.hidden = NO;
    }
    [self downKeyboard];
}
-(IBAction)downKeyboard{
    [loginNameTextfield resignFirstResponder];
    [loginPasswordTextfield resignFirstResponder];
    
    [registerNameTextfield resignFirstResponder];
    [registerPasswordTextfield resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == loginNameTextfield) {
        [loginNameTextfield resignFirstResponder];
        [loginPasswordTextfield becomeFirstResponder];
    }else if (textField == loginPasswordTextfield){
        [loginPasswordTextfield resignFirstResponder];
        [self login];
    }else if (textField == registerNameTextfield){
        [registerNameTextfield resignFirstResponder];
        [registerPasswordTextfield becomeFirstResponder];
    }else if (textField == registerPasswordTextfield){
        [registerPasswordTextfield resignFirstResponder];
        [self registerUser];
    }
    return YES;
}
-(IBAction)forgetPassword:(id)sender{
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.backType = 0;
    webViewController.title = @"忘记密码";
    webViewController.url = [NSURL URLWithString:@"http://czq.justxy.com/passport/find_pwd"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
-(IBAction)login{
    if ([loginNameTextfield.text isEqualToString:@""]) {
        [self showAlertView:@"提示" message:@"请输入账号!"];
        return;
    }
    if ([loginPasswordTextfield.text isEqualToString:@""]) {
        [self showAlertView:@"提示" message:@"请输入密码!"];
        return;
    }
    [loginNameTextfield resignFirstResponder];
    [loginPasswordTextfield resignFirstResponder];
    
    [[LoginDataSource instance] login:loginNameTextfield.text password:loginPasswordTextfield.text];
    
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
}
- (void)loginSuccess:(User *)user{
    self.appDelegate.loginUser = user;
    self.appDelegate.isLoginChanged = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.appDelegate.loginUser.token forKey:@"LOGIN_TOKEN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    loadingView.hidden = YES;
}
- (void)loginFailed:(NSString *)message{
    loadingView.hidden = YES;
    [self showAlertView:@"提示" message:message];
}
-(IBAction)registerUser{
    if ([registerNameTextfield.text isEqualToString:@""]) {
        [self showAlertView:@"提示" message:@"请输入账号!"];
        return;
    }
    if ([registerPasswordTextfield.text isEqualToString:@""]) {
        [self showAlertView:@"提示" message:@"请输入密码!"];
        return;
    }
    [registerNameTextfield resignFirstResponder];
    [registerPasswordTextfield resignFirstResponder];
    
    [[LoginDataSource instance] registerUser:registerNameTextfield.text password:registerPasswordTextfield.text];
    
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
}
- (void)registerSuccess{
    loadingView.hidden = YES;
    [self showAlertView:@"提示" message:@"注册成功"];
}
- (void)registerFailed:(NSString *)message{
    loadingView.hidden = YES;
    [self showAlertView:@"提示" message:message];
}
@end
