//
//  PersonManageViewController.m
//  MyRecruitment
//
//  Created by developer on 15/6/23.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "PersonManageViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "LoginDataSource.h"

#import "MyResumeViewController.h"
#import "JobRecordViewController.h"
#import "MyFavoriteListViewController.h"
#import "InterviewListViewController.h"
#import "PersonChangeViewController.h"

@interface PersonManageViewController ()<UITableViewDelegate,UITableViewDataSource,LoginDataSourceDelegate>{
    UITableView *mainTableView;
    NSMutableArray *mainList;
    NSMutableArray *picList;
    
    IBOutlet UIView *personView;
    IBOutlet UIImageView *logoImageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIButton *logoutButton;
}

@end

@implementation PersonManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
    
    mainList = [[NSMutableArray alloc] initWithObjects:@"我的简历",@"申请记录",@"面试邀请",@"我的收藏",@"修改个人信息", nil];
    picList = [[NSMutableArray alloc] initWithObjects:@"my_list.png",@"application_record.png",@"my_invitation.png",@"my_favorite.png",@"person_modify.png", nil];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-49:480-64-49) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    personView.frame = CGRectMake(0, 0, 320, 125);
    mainTableView.tableHeaderView = personView;
    
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
    [self refreshLoginStatus];
    [LoginDataSource instance].delegate = self;
}
-(void)refreshLoginStatus{
    if (self.appDelegate.loginUser == nil) {
        logoImageView.image = [UIImage imageNamed:@"not_login.png"];
        nameLabel.text = @"点击登录";
        logoutButton.hidden = YES;
    }else{
        logoImageView.image = [UIImage imageNamed:@"login.png"];
        nameLabel.text = self.appDelegate.loginUser.email;
        logoutButton.hidden = NO;
    }
}
-(IBAction)gotoLogin:(id)sender{
    if (self.appDelegate.loginUser == nil) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.backType = 1;
        loginViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginViewController animated:YES];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
}
-(IBAction)logout:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确定注销账户?"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
    
}
-(void)logoutSuccess{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LOGIN_TOKEN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.appDelegate.loginUser = nil;
    self.appDelegate.isLoginChanged = YES;
    [self.appDelegate.networkManager.operationQueue cancelAllOperations];
    [self refreshLoginStatus];
}
-(void)logoutFailed{
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[LoginDataSource instance] logout:self.appDelegate.loginUser.token];
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
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    titeleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    
    titeleLabel.text = [mainList objectAtIndex:indexPath.row];
    imageView.image = [UIImage imageNamed:[picList objectAtIndex:indexPath.row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.appDelegate.loginUser == nil) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.backType = 1;
        loginViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginViewController animated:YES];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }else{
        switch (indexPath.row) {
            case 0:{
                MyResumeViewController *myResumeViewController = [[MyResumeViewController alloc] initWithNibName:@"MyResumeViewController" bundle:nil];
                myResumeViewController.backType = 1;
                myResumeViewController.hidesBottomBarWhenPushed = YES;
                self.appDelegate.isResumeChanged = YES;
                [self.navigationController pushViewController:myResumeViewController animated:YES];
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                }
            }break;
            case 1:{
                JobRecordViewController *jobRecordViewController = [[JobRecordViewController alloc] initWithNibName:@"JobRecordViewController" bundle:nil];
                jobRecordViewController.backType = 1;
                jobRecordViewController.hidesBottomBarWhenPushed = YES;
                self.appDelegate.isFavoriteChanged = YES;
                [self.navigationController pushViewController:jobRecordViewController animated:YES];
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                }
            }break;
            case 2:{
                InterviewListViewController *interviewListViewController = [[InterviewListViewController alloc] initWithNibName:@"InterviewListViewController" bundle:nil];
                interviewListViewController.backType = 1;
                interviewListViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:interviewListViewController animated:YES];
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                }
            }break;
            case 3:{
                MyFavoriteListViewController *myFavoriteListViewController = [[MyFavoriteListViewController alloc] initWithNibName:@"MyFavoriteListViewController" bundle:nil];
                myFavoriteListViewController.backType = 1;
                myFavoriteListViewController.hidesBottomBarWhenPushed = YES;
                self.appDelegate.isFavoriteChanged = YES;
                [self.navigationController pushViewController:myFavoriteListViewController animated:YES];
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                }
            }break;
            case 4:{
                PersonChangeViewController *personChangeViewController = [[PersonChangeViewController alloc] initWithNibName:@"PersonChangeViewController" bundle:nil];
                personChangeViewController.backType = 1;
                personChangeViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personChangeViewController animated:YES];
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                }
            }break;
            default:
                break;
        }
    }
}

@end
