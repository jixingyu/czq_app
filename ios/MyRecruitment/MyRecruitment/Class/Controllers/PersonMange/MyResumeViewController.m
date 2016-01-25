//
//  MyResumeViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/17.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "MyResumeViewController.h"
#import "ResumeDataSource.h"
#import "AppDelegate.h"
#import "EditResumeViewController.h"
#import "MJRefresh.h"
#import "LoginViewController.h"

@interface MyResumeViewController ()<UITableViewDelegate,UITableViewDataSource,ResumeDataSourceDelegate,MJRefreshBaseViewDelegate>{
    UITableView *mainTableView;
    NSMutableArray *mainList;
    
    IBOutlet UIView *noMessageView;
    IBOutlet UIButton *createResumeButton;
    
    IBOutlet UIView *createView;
    IBOutlet UIButton *createButton;
    
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL isReload;
    BOOL isRemoveFooter;
    int pageIndex;
}

@end

@implementation MyResumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的简历";
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
    createResumeButton.layer.cornerRadius = 20;
    createResumeButton.clipsToBounds = YES;
    
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
        [self loadResumeList];
        self.appDelegate.isResumeChanged = NO;
    }
}

-(void)loadResumeList{
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    [[ResumeDataSource instance] loadResumeList:self.appDelegate.loginUser.token];
}

-(void)getResumeListSuccess:(NSArray *)list isHasNext:(BOOL)isHasNext{
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
        if (mainList.count<self.appDelegate.currentAppConfig.resumeLimit) {
            createView.hidden = NO;;
        }else{
            createView.hidden = YES;
        }
    }
    [self performSelector:@selector(reloadResume) withObject:nil afterDelay:0.1];
}
-(void)getResumeListFail:(NSString *)message{
    [self performSelector:@selector(reloadResume) withObject:nil afterDelay:0.1];
}
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    
    if (_header == refreshView) {
        pageIndex = 1;
        isReload = YES;
        [self loadResumeList];
    } else {
        pageIndex++;
        [self loadResumeList];
        isReload = NO;
    }
}

- (void)reloadResume
{
    loadingView.hidden = YES;
    [mainTableView reloadData];
    // 结束刷新状态
    [_header endRefreshing];
    [_footer endRefreshing];
}
-(IBAction)createResume:(id)sender{
    [[ResumeDataSource instance] createResume:self.appDelegate.loginUser.token];
}
- (void)createResumeSuccess:(Resume *)resume{
    [mainList addObject:resume];
    [noMessageView removeFromSuperview];
    if (mainList.count<self.appDelegate.currentAppConfig.resumeLimit) {
        createView.hidden = NO;
    }else{
        createView.hidden = YES;
    }
    [self reloadResume];
    
    EditResumeViewController *editResumeViewController = [[EditResumeViewController alloc] initWithNibName:@"EditResumeViewController" bundle:nil];
    editResumeViewController.backType = 1;
    editResumeViewController.title = @"创建简历";
    editResumeViewController.currentResume = resume;
    [self.navigationController pushViewController:editResumeViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)createResumeFail:(NSString *)message type:(int)type{
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
- (void)deleteResumeSuccess{

}
- (void)deleteResumeFail:(NSString *)message type:(int)type{
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
            Resume *resume = [mainList objectAtIndex:indexPath.row];
            [[ResumeDataSource instance] deleteResume:resume.resumeId token:self.appDelegate.loginUser.token];
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
    
    Resume *resume = [mainList objectAtIndex:indexPath.row];
    titeleLabel.text = resume.name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Resume *resume = [mainList objectAtIndex:indexPath.row];
    
    self.appDelegate.isResumeChanged = YES;
    EditResumeViewController *editResumeViewController = [[EditResumeViewController alloc] initWithNibName:@"EditResumeViewController" bundle:nil];
    editResumeViewController.backType = 1;
    editResumeViewController.title = @"编辑简历";
    editResumeViewController.currentResume = resume;
    [self.navigationController pushViewController:editResumeViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
@end
