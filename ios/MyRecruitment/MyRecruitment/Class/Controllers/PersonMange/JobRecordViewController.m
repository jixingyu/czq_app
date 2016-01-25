//
//  JobRecordViewController.m
//  MyRecruitment
//
//  Created by developer on 15/6/23.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "JobRecordViewController.h"
#import "JobDataSource.h"
#import "MJRefresh.h"
#import "Job.h"
#import "AppDelegate.h"
#import "JobDetailViewController.h"
#import "LoginViewController.h"

#define kTagJobLabel 100
#define kTagCompanyLabel 101
#define kTagDegreeLabel 102
#define kTagUpdateTimeLabel 103
#define kTagSalaryLabel 104
#define kTagFavoriteButton 105

@interface JobRecordViewController ()<JobDataSourceDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>{
    UITableView *mainTableView;
    
    NSMutableArray *mainList;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL isReload;
    BOOL isRemoveFooter;
    int pageIndex;
    
    IBOutlet UIView *noMessageView;
    IBOutlet UIView *tableViewHeaderView;
    IBOutlet UILabel *headerLabel;
    
    UIButton *currentButton;
    int currentIndex;
}

@end

@implementation JobRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"申请记录";

    isReload = YES;
    pageIndex = 1;
    mainList = [[NSMutableArray alloc] init];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.delegate = self;
    _header.scrollView = mainTableView;
    
    // 上拉加载更多
    _footer = [[MJRefreshFooterView alloc] init];
    _footer.delegate = self;
    _footer.scrollView = mainTableView;
    
    noMessageView.frame = CGRectMake(0, IS_IPHONE5?150:110, 320, 150);
    tableViewHeaderView.frame = CGRectMake(0, 0, 320, 35);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, 320, 0.4)];
    lineView.backgroundColor = [UIColor grayColor];
    [tableViewHeaderView addSubview:lineView];

    
    [self loadJobRecord];
    
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
    
    [JobDataSource instance].delegate = self;
    
    if (self.appDelegate.isFavoriteChanged) {
        [self loadJobRecord];
        self.appDelegate.isFavoriteChanged = NO;
    }
}
#pragma mark -
#pragma mark Job
-(void)loadJobRecord{
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    [[JobDataSource instance] loadJobRecord:self.appDelegate.loginUser.token page:pageIndex];
}
-(void)getJobListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext{
    if (isReload) {
        mainList = [NSMutableArray arrayWithArray:list];
        if (isRemoveFooter) {
            _footer = [MJRefreshFooterView footer];
            _footer.scrollView = mainTableView;
            _footer.delegate = self;
            isRemoveFooter = NO;
        }
        if (!isHasNext) {
            [_footer removeFromSuperview];
            isRemoveFooter = YES;
        }
    }else{
        for (int i=0;i<[list count];i++) {
            [mainList addObject:[list objectAtIndex:i]];
        }
        if (!isHasNext) {
            [_footer removeFromSuperview];
            isRemoveFooter = YES;
        }
    }
    [self performSelector:@selector(reloadJobRecord) withObject:nil afterDelay:0.1];
}
-(void)getJobListFail:(NSString *)message{
    [self performSelector:@selector(reloadJobRecord) withObject:nil afterDelay:0.1];
}
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    
    if (_header == refreshView) {
        pageIndex = 1;
        isReload = YES;
        [self loadJobRecord];
    } else {
        pageIndex++;
        [self loadJobRecord];
        isReload = NO;
    }
}

- (void)reloadJobRecord
{
    [noMessageView removeFromSuperview];
    if (mainList.count<=0) {
        [mainTableView insertSubview:noMessageView atIndex:0];
    }else{
        mainTableView.tableHeaderView = tableViewHeaderView;
        headerLabel.text = [NSString stringWithFormat:@"您目前共申请%ld个职位",mainList.count];
    }
    loadingView.hidden = YES;
    [mainTableView reloadData];
    // 结束刷新状态
    [_header endRefreshing];
    [_footer endRefreshing];
}
#pragma mark -
#pragma mark favorite
-(void)collectJob:(id)sender event:(id)event{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:mainTableView];
    NSIndexPath *indexPath= [mainTableView indexPathForRowAtPoint:currentTouchPosition];
    
    Job *job = [mainList objectAtIndex:indexPath.row];
    UIButton *button = (UIButton *)sender;
    currentButton = button;
    currentIndex = (int)indexPath.row;
    if (self.appDelegate.loginUser!=nil) {
        [[JobDataSource instance] collectJob:job.jobId token:self.appDelegate.loginUser.token];
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
    Job *job = [mainList objectAtIndex:currentIndex];
    job.isFavorited = isFavorite;
    self.appDelegate.isFavoriteChanged = YES;
}
-(void)collectJobFail:(NSString *)message type:(int)type{
    if (type==1) {
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
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mainList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ActivityCell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *jobLabel;
    UILabel *companyLabel;
    UILabel *degreeLabel;
    UILabel *timeLabel;
    UILabel *salaryLabel;
    UIButton *favoriteButton;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        jobLabel.tag = kTagJobLabel;
        jobLabel.textColor = [UIColor darkGrayColor];
        jobLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:jobLabel];
        
        companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 200, 20)];
        companyLabel.tag = kTagCompanyLabel;
        companyLabel.textColor = [UIColor darkGrayColor];
        companyLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:companyLabel];
        
        degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 200, 20)];
        degreeLabel.tag = kTagDegreeLabel;
        degreeLabel.textColor = [UIColor darkGrayColor];
        degreeLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:degreeLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 90, 20)];
        timeLabel.tag = kTagUpdateTimeLabel;
        timeLabel.textColor = [UIColor darkGrayColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:timeLabel];
        
        favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favoriteButton.frame = CGRectMake(285, 40, 20, 20);
        favoriteButton.tag = kTagFavoriteButton;
        [cell.contentView addSubview:favoriteButton];
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorited.png"] forState:UIControlStateSelected];
        [favoriteButton addTarget:self action:@selector(collectJob:event:) forControlEvents:UIControlEventTouchUpInside];
        
        salaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 70, 90, 20)];
        salaryLabel.tag = kTagSalaryLabel;
        salaryLabel.textAlignment = NSTextAlignmentRight;
        salaryLabel.font = [UIFont systemFontOfSize:13];
        salaryLabel.textColor = [UIColor redColor];
        [cell.contentView addSubview:salaryLabel];
    }
    jobLabel = (UILabel *)[cell.contentView viewWithTag:kTagJobLabel];
    companyLabel = (UILabel *)[cell.contentView viewWithTag:kTagCompanyLabel];
    degreeLabel = (UILabel *)[cell.contentView viewWithTag:kTagDegreeLabel];
    timeLabel = (UILabel *)[cell.contentView viewWithTag:kTagUpdateTimeLabel];
    salaryLabel = (UILabel *)[cell.contentView viewWithTag:kTagSalaryLabel];
    favoriteButton = (UIButton *)[cell.contentView viewWithTag:kTagFavoriteButton];
    
    Job *job = [mainList objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"职位名称: %@",job.name]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,6)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6, job.name.length)];
    jobLabel.attributedText = str;
    
    companyLabel.text = [NSString stringWithFormat:@"企业名称: %@",job.company];
    degreeLabel.text = [NSString stringWithFormat:@"学历要求: %@",job.degree];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    timeLabel.text = [formatter stringFromDate:job.updateDate];
    salaryLabel.text = job.salary;
    favoriteButton.selected = job.isFavorited;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Job *job = [mainList objectAtIndex:indexPath.row];
    
    JobDetailViewController *jobDetailViewController = [[JobDetailViewController alloc] initWithNibName:@"JobDetailViewController" bundle:nil];
    jobDetailViewController.backType = 1;
    jobDetailViewController.currentJob = job;
    [self.navigationController pushViewController:jobDetailViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
@end
