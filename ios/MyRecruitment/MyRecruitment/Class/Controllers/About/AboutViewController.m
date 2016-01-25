//
//  AboutViewController.m
//  MyRecruitment
//
//  Created by developer on 15/6/25.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AboutViewController.h"
#import "FeedbackView.h"
#import "UMFeedback.h"
#import "AppconfigDataSource.h"
#import "About.h"

@interface AboutViewController ()<UITableViewDataSource,UITableViewDelegate,FeedbackDelegate,AppConfigDelegate>{
    IBOutlet UIButton *aboutButton;
    IBOutlet UIButton *feedbackButton;
    
    UITableView *mainTableView;
    FeedbackView *feedbackView;
    NSMutableArray *titleList;
    
    About *currentAbout;
}

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    
    titleList = [[NSMutableArray alloc] initWithObjects:@"客服电话",@"客服QQ", nil];

    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,44, 320, IS_IPHONE5?568-64-44-49:480-64-44-49) style:UITableViewStyleGrouped];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    feedbackView = [[FeedbackView alloc] initWithFrame:CGRectMake(0, 44, 320, IS_IPHONE5?568-64-44-49:480-64-44-49)];
    feedbackView.delegate = self;
    [feedbackView initView];
    [self.view addSubview:feedbackView];
    feedbackView.hidden = YES;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 0.6)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView];
    
    [self setButtonSelect:aboutButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AppconfigDataSource instance].delegate = self;
    [[AppconfigDataSource instance] loadAppAbout];
}
-(IBAction)setButtonSelect:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    [feedbackView downKeyboard];
    
    if (button == aboutButton) {
        [aboutButton setBackgroundColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
        [aboutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [feedbackButton setBackgroundColor:[UIColor whiteColor]];
        [feedbackButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        mainTableView.hidden = NO;
        feedbackView.hidden = YES;
    }else{
        [aboutButton setBackgroundColor:[UIColor whiteColor]];
        [aboutButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [feedbackButton setBackgroundColor:[UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1]];
        [feedbackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        mainTableView.hidden = YES;
        feedbackView.hidden = NO;
    }
}
-(UIView *)createTableViewHeader{
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize size = [currentAbout.introduction sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, size.height<210?230:size.height+20)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, size.height<210?210:size.height)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:15];
    label.text = currentAbout.introduction;
    [view addSubview:label];
    
    return view;
}
-(void)getAppAboutSuccess:(About *)about{
    currentAbout = about;
    mainTableView.tableHeaderView = [self createTableViewHeader];
    [mainTableView reloadData];
}
-(void)getAppAboutFail:(NSString *)message{
    [self showAlertView:@"提示" message:message];
}
#pragma mark -
#pragma mark Feedback
-(void)submitFeedback:(NSString *)message{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:message,@"content", nil];
    [[UMFeedback sharedInstance] post:dic completion:^(NSError *error){
        if (error==nil) {
            [self showAlertView:@"提示" message:@"您的意见已提交,我们的工作人员会仔细查看,感谢您对我们APP的支持"];
        }else{
            [self showAlertView:@"提示" message:[NSString stringWithFormat:@"%@",error]];
        }
    }];
}
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ActivityCell";
    
    UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel;
    UILabel *contentLabel;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.tag = 100;
        [cell.contentView addSubview:titleLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 160, 50)];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.tag = 101;
        contentLabel.textColor = [UIColor orangeColor];
        contentLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:contentLabel];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        tableView.backgroundColor = [UIColor whiteColor];
    }
    titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    titleLabel.text = [titleList objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        contentLabel.text = currentAbout.phone;
    }else{
        contentLabel.text = currentAbout.qq;
    }
    return cell;
}

@end
