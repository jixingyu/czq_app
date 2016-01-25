//
//  EditResumeViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/17.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "EditResumeViewController.h"
#import "AppDelegate.h"
#import "ResumeDataSource.h"
#import "LoginViewController.h"

#import "EvaluationViewController.h"
#import "PersonInfoViewController.h"
#import "WorkExperienceViewController.h"

@interface EditResumeViewController ()<UITableViewDelegate,UITableViewDataSource,ResumeDataSourceDelegate>{
    UITableView *mainTableView;
    NSMutableArray *mainList;
    NSMutableArray *picList;
}

@end

@implementation EditResumeViewController
@synthesize currentResume;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mainList = [[NSMutableArray alloc] initWithObjects:@"未命名简历",@"个人信息",@"自我评价",@"工作经验", nil];
    picList = [[NSMutableArray alloc] initWithObjects:@"resume_question.png",@"personal_information.png",@"evaluation.png",@"work_experience.png", nil];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 125)];
    imageView.image = [UIImage imageNamed:@"resume_bg.jpg"];
    mainTableView.tableHeaderView = imageView;
    
    [self setExtraCellLineHidden:mainTableView];

}
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ResumeDataSource instance].delegate = self;
    if (self.appDelegate.isResumeChanged) {
        loadingView.hidden = NO;
        [self.view bringSubviewToFront:loadingView];
       [[ResumeDataSource instance] loadResumeDetail:self.currentResume.resumeId token:self.appDelegate.loginUser.token];
        self.appDelegate.isResumeChanged = NO;
    }
}
- (void)getResumeDetailSuccess:(Resume *)resume{
    loadingView.hidden = YES;
    self.currentResume = resume;
    [mainTableView reloadData];
}
- (void)getResumeDetailFail{
    
}
- (void)changeResumeNameSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"保存成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    alert.tag = 101;
    [alert show];
}
- (void)changeResumeNameFail:(NSString *)message type:(int)type{
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

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mainList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ActivityCell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titeleLabel;
    UIImageView *imageView;
    UILabel *remarkLabel;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        titeleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 120, 20)];
        titeleLabel.tag = 100;
        titeleLabel.textColor = [UIColor darkGrayColor];
        titeleLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:titeleLabel];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
        imageView.tag = 101;
        [cell.contentView addSubview:imageView];
        
        remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 250, 20)];
        remarkLabel.tag = 102;
        remarkLabel.textAlignment = NSTextAlignmentRight;
        remarkLabel.textColor = [UIColor darkGrayColor];
        remarkLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:remarkLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    titeleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    remarkLabel = (UILabel *)[cell.contentView viewWithTag:102];
    
    if (indexPath.row == 0) {
        titeleLabel.textColor = [UIColor grayColor];
        remarkLabel.textColor = [UIColor blackColor];
        remarkLabel.text = @"编辑";
        titeleLabel.text = self.currentResume.name;
    }else{
        if (self.currentResume) {
            switch (indexPath.row) {
                case 1:
                    remarkLabel.text = self.currentResume.isPersonalInfoCompleted?@"完整":@"需完善";
                    remarkLabel.textColor = self.currentResume.isPersonalInfoCompleted?[UIColor blueColor]:[UIColor orangeColor];
                    break;
                case 2:
                    remarkLabel.text = self.currentResume.isEvaluationCompleted?@"完整":@"需完善";
                    remarkLabel.textColor = self.currentResume.isEvaluationCompleted?[UIColor blueColor]:[UIColor orangeColor];
                    break;
                case 3:
                    remarkLabel.text = self.currentResume.isExperienceCompleted?@"完整":@"需完善";
                    remarkLabel.textColor = self.currentResume.isExperienceCompleted?[UIColor blueColor]:[UIColor orangeColor];
                    break;
                default:
                    break;
            }
        }else{
            remarkLabel.textColor = [UIColor orangeColor];
            remarkLabel.text = @"需完善";
        }
       titeleLabel.text = [mainList objectAtIndex:indexPath.row];
    }
    imageView.image = [UIImage imageNamed:[picList objectAtIndex:indexPath.row]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"修改简历名称"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"保存", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField * txt = [alert textFieldAtIndex:0];
            txt.text = self.currentResume.name;
            alert.tag = 100;
            [alert show];
        }break;
        case 1:{
            PersonInfoViewController *personInfoViewController = [[PersonInfoViewController alloc] initWithNibName:@"PersonInfoViewController" bundle:nil];
            personInfoViewController.backType = 1;
            personInfoViewController.currentResume = self.currentResume;
            [self.navigationController pushViewController:personInfoViewController animated:YES];
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            }
        }break;
        case 2:{
            EvaluationViewController *evaluationViewController = [[EvaluationViewController alloc] initWithNibName:@"EvaluationViewController" bundle:nil];
            evaluationViewController.backType = 1;
            evaluationViewController.currentResume = self.currentResume;
            [self.navigationController pushViewController:evaluationViewController animated:YES];
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            }
        }break;
        case 3:{
            WorkExperienceViewController *workExperienceViewController = [[WorkExperienceViewController alloc] initWithNibName:@"WorkExperienceViewController" bundle:nil];
            workExperienceViewController.backType = 1;
            workExperienceViewController.currentResume = self.currentResume;
            self.appDelegate.isResumeChanged = YES;
            [self.navigationController pushViewController:workExperienceViewController animated:YES];
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
            }
        }break;
            
        default:
            break;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            UITextField *nameField = [alertView textFieldAtIndex:0];
            if ([nameField.text isEqualToString:@""]) {
                [self showAlertView:@"提示" message:@"简历名称不能为空"];
            }else{
                [[ResumeDataSource instance] changeResumeName:nameField.text resumeId:currentResume.resumeId token:self.appDelegate.loginUser.token];
            }
        }
    }else if(alertView.tag == 101){
        if (buttonIndex == 0) {
            [[ResumeDataSource instance] loadResumeDetail:self.currentResume.resumeId token:self.appDelegate.loginUser.token];
            self.appDelegate.isResumeChanged = YES;
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

@end
