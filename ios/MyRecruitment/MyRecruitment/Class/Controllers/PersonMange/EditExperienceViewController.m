//
//  EditExperienceViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/27.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "EditExperienceViewController.h"
#import "AppDelegate.h"
#import "ResumeDataSource.h"
#import "LoginViewController.h"

@interface EditExperienceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,ResumeDataSourceDelegate>{
    UITableView *mainTableView;
    UITextField *currentTextField;
    UITextView *currentTextView;
    
    NSMutableArray *titleList;
    
    IBOutlet UIView *saveView;
    IBOutlet UIButton *saveButton;
    IBOutlet UIView *inputView;
    IBOutlet UIButton *nowButton;
    
    UIDatePicker *datePickerView;
    UIView *pickBgView;
    
    NSIndexPath *currentIndex;
    BOOL isSaved;
}

@end

@implementation EditExperienceViewController
@synthesize currentExperience,currentResume;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"工作经验";
    titleList = [NSMutableArray arrayWithObjects:@"公司名称:",@"任职时间(开始):",@"任职时间(结束):",@"工作内容:", nil];

    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-56:480-64-56) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mainTableView];
    
    saveView.frame = CGRectMake(0, IS_IPHONE5?568-56-64:480-56-64, 320, 56);
    saveButton.layer.cornerRadius = 20;
    saveButton.clipsToBounds = YES;
    [self.view addSubview:saveView];
    
    [self setExtraCellLineHidden:mainTableView];
    
    pickBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64)];
    pickBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.frame = CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64);
    [dismissButton addTarget:self action:@selector(dismissPickerView) forControlEvents:UIControlEventTouchUpInside];
    [pickBgView addSubview:dismissButton];
    [self.view addSubview:pickBgView];
    
    datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, IS_IPHONE5?568-240:480-240, 320, 240)];
    [datePickerView setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [datePickerView setMaximumDate:[NSDate date]];
    datePickerView.backgroundColor = [UIColor whiteColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [datePickerView setMinimumDate:[dateFormatter dateFromString:@"1970-01-02"]];
    [datePickerView setDatePickerMode:UIDatePickerModeDate];
    [pickBgView addSubview:datePickerView];
    
    inputView.frame = CGRectMake(0, IS_IPHONE5?568-280:480-280, 320, 40);
    for (UIView *view in inputView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.layer.cornerRadius = 3.0f;
            button.clipsToBounds = YES;
        }
    }
    [pickBgView addSubview:inputView];
    pickBgView.hidden = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [ResumeDataSource instance].delegate = self;
}
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
-(void)backView{
    if (!isSaved) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"修改尚未保存,确定退出？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        alert.tag = 103;
        [alert show];
    }else{
        [super backView];
    }
}
-(IBAction)saveExperienceMessage:(id)sender{
    isSaved = YES;
    [[ResumeDataSource instance] changeExperience:self.currentResume.resumeId
                                     experienceId:self.currentExperience.experienceId
                                          company:self.currentExperience.company
                                        startTime:self.currentExperience.startTime
                                          endTime:self.currentExperience.endTime
                                            isNow:self.currentExperience.isNow
                                          content:self.currentExperience.content
                                            token:self.appDelegate.loginUser.token];
}
- (void)changeExperienceSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"保存成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    alert.tag = 101;
    [alert show];
}
- (void)changeExperienceFail:(NSString *)message type:(int)type{
    
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
    }else if (alertView.tag == 103){
        if (buttonIndex == 1) {
            isSaved = YES;
            [self backView];
        }
    }
}
#pragma mark -
#pragma mark UITextField
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    currentTextView = textView;
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *temp = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.currentExperience.content = temp;
    return YES;

}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentTextField = textField;
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.currentExperience.company = @"";
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.currentExperience.company = temp;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.currentExperience.company = textField.text;
    return YES;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [currentTextField resignFirstResponder];
    [currentTextView resignFirstResponder];
}
-(IBAction)datePickerValueComplete{
    UITableViewCell *cell = [mainTableView cellForRowAtIndexPath:currentIndex];
    UILabel *remarkLabel = (UILabel *)[cell.contentView viewWithTag:1000];
    if (currentIndex.row == 1) {
        self.currentExperience.startTime = datePickerView.date;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        remarkLabel.text = [formatter stringFromDate:self.currentExperience.startTime];
    }else if (currentIndex.row == 2){
        self.currentExperience.endTime = datePickerView.date;
        self.currentExperience.isNow = NO;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        remarkLabel.text = [formatter stringFromDate:self.currentExperience.endTime];
    }
    pickBgView.hidden = YES;
}
-(IBAction)dismissPickerView{
    pickBgView.hidden = YES;
}
-(IBAction)confirmNow:(id)sender{
    self.currentExperience.isNow = YES;
    UITableViewCell *cell = [mainTableView cellForRowAtIndexPath:currentIndex];
    UILabel *remarkLabel = (UILabel *)[cell.contentView viewWithTag:1000];
    remarkLabel.text = @"至今";
    self.currentExperience.endTime = [NSDate date];
    pickBgView.hidden = YES;
}
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 250;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ActivityCell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    UILabel *titeleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 120, 20)];
    titeleLabel.textColor = [UIColor darkGrayColor];
    titeleLabel.font = [UIFont systemFontOfSize:13];
    [cell.contentView addSubview:titeleLabel];

    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 265, 20)];
    remarkLabel.textAlignment = NSTextAlignmentRight;
    remarkLabel.textColor = [UIColor darkGrayColor];
    remarkLabel.font = [UIFont systemFontOfSize:13];
    remarkLabel.tag = 1000;
    [cell.contentView addSubview:remarkLabel];
    
    UIView *fieldView = [[UIView alloc] initWithFrame:CGRectMake(160, 10, 150, 25)];
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 140, 25)];
    field.borderStyle = UITextBorderStyleNone;
    field.delegate = self;
    field.tag = 100;
    field.textAlignment = NSTextAlignmentRight;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.font = [UIFont systemFontOfSize:12];
    field.returnKeyType = UIReturnKeyDone;
    [cell.contentView addSubview:fieldView];
    [fieldView addSubview:field];
    
    fieldView.layer.borderColor = [UIColor colorWithRed:200/255. green:200/255. blue:200/255. alpha:1].CGColor;
    fieldView.layer.borderWidth = 0.6;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 43.6, 300, 0.4)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:lineView];
    
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 40, 290, 200)];
    contentTextView.layer.borderColor = [UIColor colorWithRed:242/255. green:105/255. blue:63/255. alpha:1].CGColor;
    contentTextView.layer.borderWidth = 1;
    contentTextView.tag = 101;
    contentTextView.delegate = self;
    [cell.contentView addSubview:contentTextView];
    
    titeleLabel.text = [titleList objectAtIndex:indexPath.row];
    if (self.currentExperience.experienceId == nil) {
        if (indexPath.row<3) {
            remarkLabel.text = @"";
            field.text = @"";
            if (indexPath.row == 0) {
                fieldView.hidden = NO;
                remarkLabel.hidden = YES;
            }else{
                fieldView.hidden = YES;
                remarkLabel.hidden = NO;
            }
            contentTextView.hidden = YES;
            lineView.hidden = NO;
        }else{
            contentTextView.text = @"";
            contentTextView.hidden = NO;
            remarkLabel.hidden = YES;
            fieldView.hidden = YES;
            lineView.hidden = YES;
        }
    }else{
        if (indexPath.row < 3) {
            contentTextView.hidden = YES;
            
            lineView.hidden = NO;
            switch (indexPath.row) {
                case 0:{
                    fieldView.hidden = NO;
                    remarkLabel.hidden = YES;
                    field.text = self.currentExperience.company;
                }break;
                case 1:{
                    fieldView.hidden = YES;
                    remarkLabel.hidden = NO;
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    remarkLabel.text = [formatter stringFromDate:self.currentExperience.startTime];
                }break;
                case 2:{
                    fieldView.hidden = YES;
                    remarkLabel.hidden = NO;
                    if (self.currentExperience.isNow) {
                        remarkLabel.text = @"至今";
                    }else{
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        remarkLabel.text = [formatter stringFromDate:self.currentExperience.endTime];
                    }
                }break;
                default:
                    break;
            }
        }else{
            lineView.hidden = YES;
            contentTextView.hidden = NO;
            remarkLabel.hidden = YES;
            fieldView.hidden = YES;
            contentTextView.text = self.currentExperience.content;
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentIndex = indexPath;
    [currentTextField resignFirstResponder];
    [currentTextView resignFirstResponder];
    
    if (currentIndex.row == 1) {
        pickBgView.hidden = NO;
        nowButton.hidden = YES;
        [datePickerView setDate:self.currentExperience.startTime==nil?[NSDate date]:self.currentExperience.startTime animated:YES];
    }else if (currentIndex.row == 2){
        pickBgView.hidden = NO;
        nowButton.hidden = NO;
        [datePickerView setDate:self.currentExperience.endTime==nil?[NSDate date]:self.currentExperience.endTime  animated:YES];
    }
}
@end
