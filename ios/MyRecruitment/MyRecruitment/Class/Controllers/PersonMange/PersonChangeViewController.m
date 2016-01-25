//
//  PersonChangeViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/28.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "PersonChangeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "LoginDataSource.h"

@interface PersonChangeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,LoginDataSourceDelegate>{
    UITableView *mainTableView;
    
    IBOutlet UIView *saveView;
    IBOutlet UIButton *saveButton;
    
    NSMutableArray *titleList;
    NSMutableArray *picList;
    
    UITextField *currentTextField;
    User *currentUser;
}

@end

@implementation PersonChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改个人信息";
    currentUser = [[User alloc] init];
    
    titleList = [NSMutableArray arrayWithObjects:@"姓名:",@"手机号:",@"邮箱:", nil];
    picList = [NSMutableArray arrayWithObjects:@"姓名.png",@"手机号.png",@"邮箱.png", nil];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-56:480-64-56) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    saveView.frame = CGRectMake(0, IS_IPHONE5?568-56-64:480-56-64, 320, 56);
    saveButton.layer.cornerRadius = 20;
    saveButton.clipsToBounds = YES;
    [self.view addSubview:saveView];
    
    [self setExtraCellLineHidden:mainTableView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [LoginDataSource instance].delegate = self;
}
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
#pragma mark -
#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentTextField = textField;
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    switch (textField.tag) {
        case 100:
            currentUser.realName = @"";
            break;
        case 101:
            currentUser.phone = @"";
            break;
        default:
            break;
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (textField.tag) {
        case 100:
            currentUser.realName = temp;
            break;
        case 101:
            currentUser.phone = temp;
            break;
        default:
            break;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 100:
            currentUser.realName = textField.text;
            break;
        case 101:
            currentUser.phone = textField.text;
            break;
        default:
            break;
    }
    
    return YES;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [currentTextField resignFirstResponder];
}
#pragma mark -
#pragma mark Save
-(IBAction)savePersonMessage:(id)sender{
    [[LoginDataSource instance] changePerson:currentUser.realName phone:currentUser.phone email:currentUser.email token:self.appDelegate.loginUser.token];
}
-(void)saveSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"保存成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    alert.tag = 101;
    [alert show];
}
-(void)saveFail:(NSString *)message type:(int)type{
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
            self.appDelegate.loginUser.realName = currentUser.realName;
            self.appDelegate.loginUser.phone = currentUser.phone;
            self.appDelegate.loginUser.email = currentUser.email;
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
    }
}
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    UILabel *titeleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 12, 120, 20)];
    titeleLabel.textColor = [UIColor darkGrayColor];
    titeleLabel.font = [UIFont systemFontOfSize:13];
    [cell.contentView addSubview:titeleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 20, 20)];
    [cell.contentView addSubview:imageView];

    UIView *fieldView = [[UIView alloc] initWithFrame:CGRectMake(160, 10, 150, 25)];
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 140, 25)];
    field.borderStyle = UITextBorderStyleNone;
    field.delegate = self;
    field.textAlignment = NSTextAlignmentRight;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.font = [UIFont systemFontOfSize:12];
    field.returnKeyType = UIReturnKeyDone;
    [cell.contentView addSubview:fieldView];
    [fieldView addSubview:field];
    
    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 270, 20)];
    remarkLabel.textAlignment = NSTextAlignmentRight;
    remarkLabel.textColor = [UIColor darkGrayColor];
    remarkLabel.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:remarkLabel];
    
    fieldView.layer.borderColor = [UIColor colorWithRed:200/255. green:200/255. blue:200/255. alpha:1].CGColor;
    fieldView.layer.borderWidth = 0.6;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    titeleLabel.text = [titleList objectAtIndex:indexPath.row];
    imageView.image = [UIImage imageNamed:[picList objectAtIndex:indexPath.row]];
    switch (indexPath.row) {
        case 0:
            [remarkLabel removeFromSuperview];
            field.text = self.appDelegate.loginUser.realName;
            currentUser.realName = self.appDelegate.loginUser.realName;
            field.placeholder = @"输入姓名";
            field.tag = 100;
            break;
        case 1:{
            [remarkLabel removeFromSuperview];
            field.text = self.appDelegate.loginUser.phone;
            currentUser.phone = self.appDelegate.loginUser.phone;
            field.placeholder = @"输入手机号";
            field.tag = 101;
        }break;
        case 2:{
            [fieldView removeFromSuperview];
            remarkLabel.text = self.appDelegate.loginUser.email;
            currentUser.email = self.appDelegate.loginUser.email;
            field.tag = 102;
        }break;
        default:
            break;
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
