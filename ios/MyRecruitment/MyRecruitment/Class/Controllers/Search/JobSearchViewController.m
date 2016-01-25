//
//  JobSearchViewController.m
//  MyRecruitment
//
//  Created by developer on 15/6/23.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "JobSearchViewController.h"
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

@interface JobSearchViewController ()<UISearchBarDelegate,JobDataSourceDelegate,UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>{
    UISearchBar *customSearchBar;
    UIView *cityView;
    UIView *citySelectView;
    
    UIImageView *arrowImageView;
    UITableView *mainTableView;
    
    NSMutableArray *mainList;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL isReload;
    BOOL isRemoveFooter;
    int pageIndex;
    
    float cityHeight;
    NSString *currentCity;
    NSString *keyword;
    
    UIButton *currentButton;
    int currentIndex;
    IBOutlet UIView *noMessageView;
}

@end

@implementation JobSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isReload = YES;
    pageIndex = 1;
    mainList = [[NSMutableArray alloc] init];
    
    currentCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"LOCTION"];
    if (currentCity == nil || [currentCity isEqualToString:@""]) {
        currentCity = @"请选择";
    }
    keyword = @"";
    
    [self locationDidChanged:currentCity];
    
    [self initCityView];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-49:480-64-49) style:UITableViewStylePlain];
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

    [self setExtraCellLineHidden:mainTableView];
    self.tabBarController.tabBar.superview.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCitySuccess) name:@"GetAppConfigSuccess" object:nil];
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
    
    [self initSearchBar];
    
    if (self.appDelegate.isFavoriteChanged||self.appDelegate.isLoginChanged) {
        [self loadJob];
        self.appDelegate.isFavoriteChanged = NO;
        self.appDelegate.isLoginChanged = NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [customSearchBar removeFromSuperview];
}

#pragma mark -
#pragma mark searchBar
-(void)initSearchBar{
    customSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(80,2,230,40)];
    customSearchBar.delegate = self;
    customSearchBar.tintColor = [UIColor whiteColor];
    [customSearchBar setImage:[UIImage imageNamed:@"search.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    for (UIView *view in customSearchBar.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            
            UITextField *textField = (UITextField *)[view.subviews objectAtIndex:1];
            textField.textColor = [UIColor whiteColor];
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入信息..." attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            textField.backgroundColor = [UIColor colorWithRed:43/255. green:147/255. blue:98/255. alpha:1];
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            
            break;
        }
    }
    [self.navigationController.navigationBar addSubview: customSearchBar];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    customSearchBar.showsCancelButton = YES;
    for (UIView *view in customSearchBar.subviews){
        if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)view;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0){
            for (UIView *subView in view.subviews){
                if([subView isKindOfClass:[UIButton class]])
                {
                    UIButton *btn = (UIButton *)subView;
                    [btn setTitle:@"取消"  forState:UIControlStateNormal];
                }
            }
        }
    }
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    customSearchBar.showsCancelButton = NO;
    customSearchBar.text = @"";
    keyword = @"";
    [customSearchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    keyword = searchBar.text;
    [self loadJob];
}
#pragma mark -
#pragma mark city
-(void)initCityView{
    cityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-49:480-64-49)];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-49:480-64-49)];
    blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [cityView addSubview:blackView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 320, IS_IPHONE5?568-64-49:480-64-49);
    [button addTarget:self action:@selector(closeCityView) forControlEvents:UIControlEventTouchUpInside];
    [cityView addSubview:button];
    
    citySelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, cityHeight)];
    citySelectView.backgroundColor = [UIColor whiteColor];
    [cityView addSubview:citySelectView];
    
    [self.view addSubview:cityView];
    cityView.hidden = YES;
}
-(void)locationDidChanged:(NSString *)city{
    self.navigationItem.leftBarButtonItem  = nil;
    
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize size = [city sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    bgView.backgroundColor = [UIColor clearColor];
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [control addTarget:self action:@selector(cityChanged) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, size.width>50?52:size.width, 30)];
    titleLabel.text = city;
    titleLabel.font = font;
    titleLabel.textColor = [UIColor whiteColor];
    
    arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width>50?52:size.width+2, 22, 8, 5)];
    arrowImageView.image = [UIImage imageNamed:@"arrow_down.png"];
    
    [bgView addSubview:control];
    [bgView addSubview:titleLabel];
    [bgView addSubview:arrowImageView];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bgView];
    leftBarButtonItem.width = -5;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"LOCTION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)cityChanged{
    if (cityView.hidden) {
        arrowImageView.image = [UIImage imageNamed:@"arrow_up.png"];
        cityView.hidden = NO;
        [self.view bringSubviewToFront:cityView];
        
    }else{
        arrowImageView.image = [UIImage imageNamed:@"arrow_down.png"];
        cityView.hidden = YES;
    }
    if (self.appDelegate.currentAppConfig.districtList.count == 0) {
        [self.appDelegate getAppConfig];
    }else{
        [self cityDidChanged];
    }
}
-(void)getCitySuccess{
    [self cityDidChanged];
}
-(void)cityDidChanged{
    cityHeight = (self.appDelegate.currentAppConfig.districtList.count%4==0?(self.appDelegate.currentAppConfig.districtList.count/4):(self.appDelegate.currentAppConfig.districtList.count+1))*45+15;
    citySelectView.frame = CGRectMake(0, 0, 320, cityHeight);
    for (UIView *view in citySelectView.subviews) {
        [view removeFromSuperview];
    }
    for (int i=0; i<self.appDelegate.currentAppConfig.districtList.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = i;
        button.frame = CGRectMake(10+i%4*80, 15+i/4*45, 60, 30);
        [button setTitle:[self.appDelegate.currentAppConfig.districtList objectAtIndex:i] forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button addTarget:self action:@selector(selectCity:) forControlEvents:UIControlEventTouchUpInside];
        [citySelectView addSubview:button];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        if ([currentCity isEqualToString:[self.appDelegate.currentAppConfig.districtList objectAtIndex:i]]) {
            [button setBackgroundColor:[UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1]];
        }else{
            [button setBackgroundColor:[UIColor whiteColor]];
        }
    }
}
-(void)selectCity:(UIButton *)button{
    for (UIView *view in citySelectView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *theButton = (UIButton *)view;
            if (theButton.tag == button.tag) {
                [theButton setBackgroundColor:[UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1]];
            }else{
                [theButton setBackgroundColor:[UIColor whiteColor]];
            }
        }
    }
    [self closeCityView];
    currentCity = [self.appDelegate.currentAppConfig.districtList objectAtIndex:button.tag];
    pageIndex = 1;
    isReload = YES;
    [self locationDidChanged:currentCity];
    [self loadJob];
}
-(void)closeCityView{
    arrowImageView.image = [UIImage imageNamed:@"arrow_down.png"];
    cityView.hidden = YES;
}

#pragma mark -
#pragma mark Job
-(void)loadJob{
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    [[JobDataSource instance] loadJobList:keyword district:[currentCity isEqualToString:@"请选择"]?@"":currentCity page:pageIndex token:self.appDelegate.loginUser.token];
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
    [self performSelector:@selector(reloadJob) withObject:nil afterDelay:0.1];
}
-(void)getJobListFail:(NSString *)message{
    [self performSelector:@selector(reloadJob) withObject:nil afterDelay:0.1];
}
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    
    if (_header == refreshView) {
        pageIndex = 1;
        isReload = YES;
        [self loadJob];
    } else {
        pageIndex++;
        [self loadJob];
        isReload = NO;
    }
}

- (void)reloadJob
{
    [noMessageView removeFromSuperview];
    if (mainList.count<=0) {
        [mainTableView insertSubview:noMessageView atIndex:0];
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
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 100, 20)];
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
        
        salaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 70, 100, 20)];
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
    [jobDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:jobDetailViewController animated:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
@end
