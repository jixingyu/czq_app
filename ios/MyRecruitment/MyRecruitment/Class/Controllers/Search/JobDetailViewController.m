//
//  JobDetailViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/16.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "JobDetailViewController.h"
#import "JobDataSource.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "EditResumeViewController.h"
#import "ResumeDataSource.h"

@interface JobDetailViewController ()<JobDataSourceDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,ResumeDataSourceDelegate>{
    IBOutlet UIButton *jobButton;
    IBOutlet UIButton *detailButton;
    
    IBOutlet UIView *applicationView;
    IBOutlet UIButton *applicationButton;
    
    UITableView *mainTableView;
    UIButton *currentButton;
    
    NSMutableArray *resumeList;
    
    int type;
}

@end

@implementation JobDetailViewController
@synthesize currentJob;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    resumeList = [[NSMutableArray alloc] init];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, IS_IPHONE5?568-64-56-44:480-64-56-44) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 0.6)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView];
    
    applicationView.frame = CGRectMake(0, IS_IPHONE5?568-56-64:480-56-64, 320, 56);
    applicationButton.layer.cornerRadius = 20;
    applicationButton.clipsToBounds = YES;
    [self.view addSubview:applicationView];
    
    [[JobDataSource instance] loadJobDetail:self.currentJob.jobId token:self.appDelegate.loginUser.token];
    
    [self setExtraCellLineHidden:mainTableView];
    
    [self setButtonSelect:jobButton];
}
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [JobDataSource instance].delegate = self;
    [ResumeDataSource instance].delegate = self;
}
-(IBAction)setButtonSelect:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button == jobButton) {
        [jobButton setBackgroundColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
        [jobButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [detailButton setBackgroundColor:[UIColor whiteColor]];
        [detailButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        type = 0;
    }else{
        [jobButton setBackgroundColor:[UIColor whiteColor]];
        [jobButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [detailButton setBackgroundColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
        [detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        type = 1;
    }
    [mainTableView reloadData];
}
-(void)getJobDetailSuccess:(Job *)job{
    self.currentJob = job;
    if (self.currentJob.isApplied) {
        [applicationButton setTitle:@"您已申请该职位" forState:UIControlStateNormal];
        applicationButton.enabled = NO;
    }else{
        [applicationButton setTitle:@"申请职位" forState:UIControlStateNormal];
        applicationButton.enabled = YES;
    }
    [mainTableView reloadData];
}
-(void)getJobDetailtFail{
    
}
#pragma mark -
#pragma mark favorite
-(void)collectJob:(id)sender{
    UIButton *button = (UIButton *)sender;
    currentButton = button;
    if (self.appDelegate.loginUser!=nil) {
        [[JobDataSource instance] collectJob:currentJob.jobId token:self.appDelegate.loginUser.token];
    }else{
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.backType = 1;
        loginViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginViewController animated:YES];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
}
-(void)collectJobSuccess:(BOOL)isFavorite{
    currentButton.selected = isFavorite;
    currentJob.isFavorited = isFavorite;
    self.appDelegate.isFavoriteChanged = YES;
}
-(void)collectJobFail:(NSString *)message type:(int)failType{
    if (failType==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        alert.tag = 101;
        [alert show];
    }else{
        [self showAlertView:@"提示" message:message];
    }
}
#pragma mark -
#pragma mark application;
-(IBAction)jobApplication:(id)sender{
    if (self.appDelegate.loginUser == nil) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.backType = 1;
        loginViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginViewController animated:YES];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }else{
        [[ResumeDataSource instance] loadResumeList:self.appDelegate.loginUser.token];
    }
}
-(void)getResumeListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext{
    if(list.count>0){
        resumeList = [NSMutableArray arrayWithArray:list];
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"请选择一份简历投递"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
        actionSheet.tag = 100;
        for (Resume *resume in list) {
            [actionSheet addButtonWithTitle:resume.name];
        }
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"申请职位之前必须创建一份简历"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"创建新简历",nil];
        actionSheet.tag = 101;
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}
-(void)getResumeListFail:(NSString *)message{
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
            [[ResumeDataSource instance] createResume:self.appDelegate.loginUser.token];
        }
    }else{
        if (buttonIndex > 0) {
            Resume *resume = [resumeList objectAtIndex:buttonIndex-1];
            [[JobDataSource instance] applyJob:currentJob.jobId resumeId:resume.resumeId token:self.appDelegate.loginUser.token];
        }
    }
}
- (void)createResumeSuccess:(Resume *)resume{
    EditResumeViewController *editResumeViewController = [[EditResumeViewController alloc] initWithNibName:@"EditResumeViewController" bundle:nil];
    editResumeViewController.backType = 1;
    editResumeViewController.title = @"创建简历";
    editResumeViewController.currentResume = resume;
    [self.navigationController pushViewController:editResumeViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)createResumeFail{
    
}
-(void)applyJobSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"您已申请成功"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    alert.tag = 100;
    [alert show];
}
-(void)applyJobFail:(NSString *)message type:(int)failType{
    if (failType==1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        alert.tag = 101;
        [alert show];
    }else{
        [self showAlertView:@"提示" message:message];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
         [[JobDataSource instance] loadJobDetail:self.currentJob.jobId token:self.appDelegate.loginUser.token];
    }else{
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
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (type == 0) {
        return 4;
    }else{
        return 2;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (type == 0) {
        return 1;
    }else{
        if (section == 0) {
            return 2;
        }else{
            return 1;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (type==0) {
        switch (indexPath.section) {
            case 0:
                return 100;
                break;
            case 1:
                return 55;
                break;
            case 2:{
                float height = (self.currentJob.benefit.count%3==0?self.currentJob.benefit.count/3:self.currentJob.benefit.count/3+1)*30;
                return 40+height;
            }break;
            case 3:{
                float height = 0;
                for (int i=0; i<self.currentJob.requirement.count; i++) {
                    UIFont *font = [UIFont systemFontOfSize:14];
                    CGSize size = [[self.currentJob.requirement objectAtIndex:i] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
                    height+=size.height+5;
                }
                return 40+height;
            }break;
            default:
                break;
        }
    }else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 100;
            }else{
                return 44;
            }
        }else{
            float height = 0;
            UIFont *font = [UIFont systemFontOfSize:14];
            CGSize size = [self.currentJob.companyDescription sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
            height+=size.height+5;
            return 40+height;
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (type == 0) {
        if (section<3) {
            return 10;
        }else{
            return 0;
        }
    }else{
        if (section<1) {
            return 10;
        }else{
            return 0;
        }
    }
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ActivityCell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    if (type == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (indexPath.section == 0) {
            UILabel *jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
            jobLabel.textColor = [UIColor darkGrayColor];
            jobLabel.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:jobLabel];
            
            UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 200, 20)];
            companyLabel.textColor = [UIColor darkGrayColor];
            companyLabel.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:companyLabel];
            
            UILabel *degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 200, 20)];
            degreeLabel.textColor = [UIColor darkGrayColor];
            degreeLabel.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:degreeLabel];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 90, 20)];
            timeLabel.textColor = [UIColor darkGrayColor];
            timeLabel.textAlignment = NSTextAlignmentRight;
            timeLabel.font = [UIFont systemFontOfSize:13];
            [cell.contentView addSubview:timeLabel];
            
            UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            favoriteButton.frame = CGRectMake(285, 40, 20, 20);
            [favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
            [favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorited.png"] forState:UIControlStateSelected];
            [favoriteButton addTarget:self action:@selector(collectJob:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:favoriteButton];
            
            UILabel *salaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 70, 90, 20)];
            salaryLabel.textAlignment = NSTextAlignmentRight;
            salaryLabel.font = [UIFont systemFontOfSize:13];
            salaryLabel.textColor = [UIColor redColor];
            [cell.contentView addSubview:salaryLabel];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"职位名称: %@",self.currentJob.name]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,6)];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6, self.currentJob.name.length)];
            jobLabel.attributedText = str;
            
            companyLabel.text = [NSString stringWithFormat:@"企业名称: %@",self.currentJob.company];
            degreeLabel.text = [NSString stringWithFormat:@"学历要求: %@",self.currentJob.degree];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM-dd"];
            timeLabel.text = [formatter stringFromDate:self.currentJob.updateDate];
            salaryLabel.text = self.currentJob.salary;
            favoriteButton.selected = currentJob.isFavorited;
        }else if (indexPath.section == 1){
            NSArray *titleList = [NSArray arrayWithObjects:@"工作经验",@"招聘人数",@"职位类型", nil];
            for (int i=0; i<3; i++) {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+105*i, 5, 100, 20)];
                titleLabel.text = [titleList objectAtIndex:i];
                titleLabel.font = [UIFont systemFontOfSize:14];
                titleLabel.textColor = [UIColor grayColor];
                [cell.contentView addSubview:titleLabel];
                
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+105*i, 30, 100, 20)];
                nameLabel.font = [UIFont systemFontOfSize:14];
                nameLabel.textColor = [UIColor blackColor];
                [cell.contentView addSubview:nameLabel];
                switch (i) {
                    case 0:
                        nameLabel.text = self.currentJob.workingYears;
                        break;
                    case 1:
                        nameLabel.text = self.currentJob.recruitNumber;
                        break;
                    case 2:
                        nameLabel.text = self.currentJob.jobType;
                        break;
                    default:
                        break;
                }
                if (i<2) {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(105+105*i, 2, 1, 50)];
                    line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
                    [cell.contentView addSubview:line];
                }
            }
        }else if (indexPath.section == 2){
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
            titleLabel.text = @"职位福利";
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = [UIColor orangeColor];
            [cell.contentView addSubview:titleLabel];
            
            for (int i=0; i<self.currentJob.benefit.count; i++) {
                UILabel *benefitLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+110*(i%3), 35+30*(i/3), 100, 20)];
                benefitLabel.text = [self.currentJob.benefit objectAtIndex:i];
                benefitLabel.font = [UIFont systemFontOfSize:14];
                benefitLabel.textColor = [UIColor grayColor];
                [cell.contentView addSubview:benefitLabel];
                
                UIFont *font = [UIFont systemFontOfSize:14];
                CGSize size = [benefitLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(benefitLabel.frame.origin.x+size.width+5, benefitLabel.frame.origin.y, 20, 20)];
                imageView.image = [UIImage imageNamed:@"right.png"];
                [cell.contentView addSubview:imageView];
            }
        }else if (indexPath.section == 3){
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
            titleLabel.text = @"任职要求";
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = [UIColor orangeColor];
            [cell.contentView addSubview:titleLabel];
            
            float height = 28;
            for (int i=0; i<self.currentJob.requirement.count; i++) {
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize size = [[self.currentJob.requirement objectAtIndex:i] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];

                UILabel *benefitLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, height, 280, size.height+5)];
                benefitLabel.text = [self.currentJob.requirement objectAtIndex:i];
                benefitLabel.font = [UIFont systemFontOfSize:13];
                benefitLabel.textColor = [UIColor grayColor];
                benefitLabel.numberOfLines = 0;
                [cell.contentView addSubview:benefitLabel];
                
                UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(12, height+8, 6, 6)];
                redView.backgroundColor = [UIColor redColor];
                [cell.contentView addSubview:redView];
                redView.layer.cornerRadius = 3;
                redView.clipsToBounds = YES;
                
                height+=size.height+5;
            }
        }
        
    }else{
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {

                UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
                companyLabel.textColor = [UIColor blackColor];
                companyLabel.font = [UIFont systemFontOfSize:14];
                [cell.contentView addSubview:companyLabel];
                
                UILabel *industryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 280, 20)];
                industryLabel.textColor = [UIColor darkGrayColor];
                industryLabel.font = [UIFont systemFontOfSize:13];
                [cell.contentView addSubview:industryLabel];
                
                UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 290, 20)];
                numberLabel.textColor = [UIColor redColor];
                numberLabel.font = [UIFont systemFontOfSize:13];
                numberLabel.textAlignment = NSTextAlignmentRight;
                [cell.contentView addSubview:numberLabel];
                
                companyLabel.text = self.currentJob.company;
                industryLabel.text = self.currentJob.industry;
                numberLabel.text = self.currentJob.number;
                
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 300, 0.4)];
                lineView.backgroundColor = [UIColor lightGrayColor];
                [cell.contentView addSubview:lineView];
            }else{
                UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
                addressImageView.image = [UIImage imageNamed:@"address"];
                [cell.contentView addSubview:addressImageView];
                
                UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 12, 260, 20)];
                addressLabel.textColor = [UIColor grayColor];
                addressLabel.font = [UIFont systemFontOfSize:14];
                [cell.contentView addSubview:addressLabel];
                
                addressLabel.text = self.currentJob.address;
            }
        }else{
            UIFont *font = [UIFont systemFontOfSize:14];
            CGSize size = [self.currentJob.companyDescription sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
            titleLabel.text = @"公司介绍";
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = [UIColor orangeColor];
            [cell.contentView addSubview:titleLabel];
            
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, 260, size.height+5)];
            descriptionLabel.textColor = [UIColor grayColor];
            descriptionLabel.text = self.currentJob.companyDescription;
            descriptionLabel.font = [UIFont systemFontOfSize:14];
            descriptionLabel.numberOfLines = 0;
            [cell.contentView addSubview:descriptionLabel];
        }
    }
    return cell;
}

@end
