//
//  InterviewListViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/20.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "InterviewListViewController.h"
#import "JobDataSource.h"
#import "MJRefresh.h"
#import "Interview.h"
#import "AppDelegate.h"
#import "JobDetailViewController.h"

#define kTagJobLabel 100
#define kTagCompanyLabel 101
#define kTagAddressLabel 102
#define kTagUpdateTimeLabel 103

@interface InterviewListViewController ()<JobDataSourceDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>{
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
}

@end

@implementation InterviewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"面试邀请";
    
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
    
    [self loadInterviewList];
    
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
    
}
#pragma mark -
#pragma mark Job
-(void)loadInterviewList{
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    [[JobDataSource instance] loadInterviewList:self.appDelegate.loginUser.token page:pageIndex];
}
-(void)getInterviewListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext{
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
-(void)getInterviewListFail:(NSString *)message{
    [self performSelector:@selector(reloadJobRecord) withObject:nil afterDelay:0.1];
}
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    
    if (_header == refreshView) {
        pageIndex = 1;
        isReload = YES;
        [self loadInterviewList];
    } else {
        pageIndex++;
        [self loadInterviewList];
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
        headerLabel.text = [NSString stringWithFormat:@"您目前共有%ld个面试邀请",mainList.count];
    }
    loadingView.hidden = YES;
    [mainTableView reloadData];
    // 结束刷新状态
    [_header endRefreshing];
    [_footer endRefreshing];
}
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mainList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ActivityCell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *jobLabel;
    UILabel *companyLabel;
    UILabel *addressLabel;
    UILabel *timeLabel;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
        companyLabel.tag = kTagCompanyLabel;
        companyLabel.textColor = [UIColor darkGrayColor];
        companyLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:companyLabel];
        
        jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 280, 20)];
        jobLabel.tag = kTagJobLabel;
        jobLabel.textColor = [UIColor darkGrayColor];
        jobLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:jobLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 280, 20)];
        timeLabel.tag = kTagUpdateTimeLabel;
        timeLabel.textColor = [UIColor darkGrayColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:timeLabel];
        
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 280, 20)];
        addressLabel.tag = kTagAddressLabel;
        addressLabel.textColor = [UIColor darkGrayColor];
        addressLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:addressLabel];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    jobLabel = (UILabel *)[cell.contentView viewWithTag:kTagJobLabel];
    companyLabel = (UILabel *)[cell.contentView viewWithTag:kTagCompanyLabel];
    addressLabel = (UILabel *)[cell.contentView viewWithTag:kTagAddressLabel];
    timeLabel = (UILabel *)[cell.contentView viewWithTag:kTagUpdateTimeLabel];
    
    Interview *interview = [mainList objectAtIndex:indexPath.row];
    
    jobLabel.text = [NSString stringWithFormat:@"应聘职位: %@",interview.job];
    companyLabel.text = [NSString stringWithFormat:@"企业名称: %@",interview.company];
    addressLabel.text = [NSString stringWithFormat:@"面试地点: %@",interview.address];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    timeLabel.text = [NSString stringWithFormat:@"面试时间:%@",[formatter stringFromDate:interview.time]];

    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Interview *interview = [mainList objectAtIndex:indexPath.row];
    Job *job = [[Job alloc] init];
    job.jobId = interview.jobId;
    
    JobDetailViewController *jobDetailViewController = [[JobDetailViewController alloc] initWithNibName:@"JobDetailViewController" bundle:nil];
    jobDetailViewController.backType = 1;
    jobDetailViewController.currentJob = job;
    [self.navigationController pushViewController:jobDetailViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
@end
