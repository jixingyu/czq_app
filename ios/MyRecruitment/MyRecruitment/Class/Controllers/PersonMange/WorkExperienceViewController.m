//
//  WorkExperienceViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/24.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "WorkExperienceViewController.h"
#import "ResumeDataSource.h"
#import "AppDelegate.h"
#import "EditExperienceViewController.h"
#import "MJRefresh.h"
#import "LoginViewController.h"

@interface WorkExperienceViewController ()<UITableViewDelegate,UITableViewDataSource,ResumeDataSourceDelegate,MJRefreshBaseViewDelegate>{
    UITableView *mainTableView;
    NSMutableArray *mainList;
    
    IBOutlet UIView *noMessageView;
    IBOutlet UIButton *createExperienceButton;
    
    IBOutlet UIView *createView;
    IBOutlet UIButton *createButton;
    
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL isReload;
    BOOL isRemoveFooter;
    int pageIndex;
}

@end

@implementation WorkExperienceViewController
@synthesize currentResume;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"工作经验";
    mainList = [[NSMutableArray alloc] init];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    [self setExtraCellLineHidden:mainTableView];
    
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.delegate = self;
    _header.scrollView = mainTableView;
    
    // 上拉加载更多
    _footer = [[MJRefreshFooterView alloc] init];
    _footer.delegate = self;
    _footer.scrollView = mainTableView;
    
    noMessageView.frame = CGRectMake(0, IS_IPHONE5?150:110, 320, 150);
    createExperienceButton.layer.cornerRadius = 20;
    createExperienceButton.clipsToBounds = YES;
    
    createView.frame = CGRectMake(0, IS_IPHONE5?568-56-64:480-56-64, 320, 56);
    createButton.layer.cornerRadius = 20;
    createButton.clipsToBounds = YES;
    [self.view addSubview:createView];
    createView.hidden = YES;
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
        isReload = YES;
        [self loadExperienceList];
        self.appDelegate.isResumeChanged = NO;
    }
}

-(void)loadExperienceList{
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    [[ResumeDataSource instance] loadExperienceList:self.currentResume.resumeId token:self.appDelegate.loginUser.token];
}

-(void)getExperienceListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext{
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
    [noMessageView removeFromSuperview];
    if (mainList.count<=0) {
        [mainTableView insertSubview:noMessageView atIndex:0];
    }else{
        createView.hidden = NO;
    }
    [self performSelector:@selector(reloadExperienceList) withObject:nil afterDelay:0.1];
}
-(void)getExperienceListFail:(NSString *)message{
    [self performSelector:@selector(reloadExperienceList) withObject:nil afterDelay:0.1];
}
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    
    if (_header == refreshView) {
        pageIndex = 1;
        isReload = YES;
        [self loadExperienceList];
    } else {
        pageIndex++;
        [self loadExperienceList];
        isReload = NO;
    }
}

- (void)reloadExperienceList
{
    loadingView.hidden = YES;
    [mainTableView reloadData];
    // 结束刷新状态
    [_header endRefreshing];
    [_footer endRefreshing];
}
-(IBAction)createExperience:(id)sender{
    EditExperienceViewController *editExperienceViewController = [[EditExperienceViewController alloc] initWithNibName:@"EditExperienceViewController" bundle:nil];
    editExperienceViewController.backType = 1;
    Experience *experience = [[Experience alloc] init];
    editExperienceViewController.currentExperience = experience;
    editExperienceViewController.currentResume = self.currentResume;
    [self.navigationController pushViewController:editExperienceViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)deleteExperienceSuccess{
    self.appDelegate.isResumeChanged = YES;
}
- (void)deleteExperienceFail:(NSString *)message type:(int)type{
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
    return 44;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row<[mainList count]) {
            Experience *experience = [mainList objectAtIndex:indexPath.row];
            [[ResumeDataSource instance] deleteExperience:experience.experienceId token:self.appDelegate.loginUser.token];
            [mainList removeObjectAtIndex:indexPath.row];//移除数据源的数据
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
            createView.hidden = NO;
            [noMessageView removeFromSuperview];
            if (mainList.count<=0) {
                [mainTableView insertSubview:noMessageView atIndex:0];
                createView.hidden = YES;
            }
        }
    }
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
        
        titeleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 160, 20)];
        titeleLabel.tag = 100;
        titeleLabel.textColor = [UIColor darkGrayColor];
        titeleLabel.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:titeleLabel];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
        imageView.tag = 101;
        [cell.contentView addSubview:imageView];
        
        remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 14, 100, 20)];
        remarkLabel.tag = 102;
        remarkLabel.textColor = [UIColor darkGrayColor];
        remarkLabel.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:remarkLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    titeleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    remarkLabel = (UILabel *)[cell.contentView viewWithTag:102];
    
    Experience *experience = [mainList objectAtIndex:indexPath.row];
    titeleLabel.text = experience.company;
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy.MM"];
    if (experience.isNow) {
        remarkLabel.text = [NSString stringWithFormat:@"%@-至今",[formatter1 stringFromDate:experience.startTime]];
    }else{
        remarkLabel.text = [NSString stringWithFormat:@"%@-%@",[formatter1 stringFromDate:experience.startTime],[formatter1 stringFromDate:experience.endTime]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Experience *experience = [mainList objectAtIndex:indexPath.row];
    
    EditExperienceViewController *editExperienceViewController = [[EditExperienceViewController alloc] initWithNibName:@"EditExperienceViewController" bundle:nil];
    editExperienceViewController.backType = 1;
    editExperienceViewController.currentExperience = experience;
    editExperienceViewController.currentResume = self.currentResume;
    [self.navigationController pushViewController:editExperienceViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}


@end
