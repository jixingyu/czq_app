//
//  PersonInfoViewController.m
//  MyRecruitment
//
//  Created by developer on 15/7/22.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "AppDelegate.h"
#import "ResumeDataSource.h"
#import "LoginViewController.h"

@interface PersonInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,ResumeDataSourceDelegate>{
    UITableView *mainTableView;
    
    IBOutlet UIView *saveView;
    IBOutlet UIButton *saveButton;
    IBOutlet UIView *inputView;
    
    NSMutableArray *titleList;
    NSMutableArray *picList;
    NSMutableArray *messageList;
    
    int currentTag;
    NSIndexPath *currentIndex;
    UITextField *currentTextField;
    int height;
    
    UIPickerView *pickerView;
    UIDatePicker *datePickerView;
    UIView *pickBgView;
    
    NSArray *provinces;
    NSArray *cities;
}

@end

@implementation PersonInfoViewController
@synthesize currentResume;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    
    height = 589;
    
    titleList = [NSMutableArray arrayWithObjects:@"姓名:",@"性别:",@"出生日期:",@"籍贯:",@"参加工作时间:",@"手机号:",@"邮箱:",@"毕业院校:",@"大学专业:",@"学历:",@"政治面貌:", nil];
    picList = [NSMutableArray arrayWithObjects:@"姓名.png",@"性别.png",@"出生日期.png",@"籍贯.png",@"工作经历.png",@"手机号.png",@"邮箱.png",@"大学专业.png",@"大学专业.png",@"学历.png",@"政治面貌.png", nil];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64-56:480-64-56) style:UITableViewStylePlain];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    
    saveView.frame = CGRectMake(0, IS_IPHONE5?568-56-64:480-56-64, 320, 56);
    saveButton.layer.cornerRadius = 20;
    saveButton.clipsToBounds = YES;
    [self.view addSubview:saveView];

    [self setExtraCellLineHidden:mainTableView];
    
    pickBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64)];
    pickBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.frame = CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64);
    [dismissButton addTarget:self action:@selector(dismissPickerView) forControlEvents:UIControlEventTouchUpInside];
    [pickBgView addSubview:dismissButton];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, IS_IPHONE5?568-240:480-240, 320, 240)];
    pickerView.delegate = self;
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    [pickBgView addSubview:pickerView];
    [self.view addSubview:pickBgView];
    pickerView.hidden = YES;
    pickBgView.hidden = YES;
    
    datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, IS_IPHONE5?568-240:480-240, 320, 240)];
    [datePickerView setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [datePickerView setMaximumDate:[NSDate date]];
    datePickerView.backgroundColor = [UIColor whiteColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [datePickerView setMinimumDate:[dateFormatter dateFromString:@"1970-01-02"]];
    [datePickerView setDatePickerMode:UIDatePickerModeDate];
//    [datePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [pickBgView addSubview:datePickerView];
    datePickerView.hidden = YES;
    
    inputView.frame = CGRectMake(0, IS_IPHONE5?568-280:480-280, 320, 40);
    for (UIView *view in inputView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.layer.cornerRadius = 3.0f;
            button.clipsToBounds = YES;
        }
    }
    [pickBgView addSubview:inputView];
    
    provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city.plist" ofType:nil]];
    cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
//    NSString *str = @"{\"city_list\":[";
//    NSString *str1  = @"";
//    for(int i=0;i<provinces.count;i++){
//        NSString *province = [[provinces objectAtIndex:i] objectForKey:@"state"];
//        str1 = [NSString stringWithFormat:@"%@{\"province\":\"%@\",\"city\":[",str1,province];
//        cities = [[provinces objectAtIndex:i] objectForKey:@"cities"];
//        NSString *str2 = @"";
//        for (int j=0; j<cities.count; j++) {
//            NSString *city = [cities objectAtIndex:j];
//            
//            if (j<cities.count-1) {
//                str2 = [NSString stringWithFormat:@"%@{\"name\":\"%@\"},",str2,city];
//            }else{
//                str2 = [NSString stringWithFormat:@"%@{\"name\":\"%@\"}",str2,city];
//            }
//        }
//        if (i<provinces.count-1) {
//            str2 = [NSString stringWithFormat:@"%@]},",str2 ];
//        }else{
//            str2 = [NSString stringWithFormat:@"%@]}",str2 ];
//        }
//        
//        str1 = [NSString stringWithFormat:@"%@%@",str1,str2 ];
//    }
//    str = [NSString stringWithFormat:@"%@%@]}",str,str1 ];
//    NSLog(@"str1==%@",str);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [ResumeDataSource instance].delegate = self;
}
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentTag = (int)textField.tag;
    currentTextField = textField;
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    switch (textField.tag) {
        case 100:
            self.currentResume.realName = @"";
            break;
        case 101:
            self.currentResume.mobile = @"";
            break;
        case 102:
            self.currentResume.email = @"";
            break;
        case 103:
            self.currentResume.school = @"";
            break;
        case 104:
            self.currentResume.major = @"";
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
            self.currentResume.realName = temp;
            break;
        case 101:
            self.currentResume.mobile = temp;
            break;
        case 102:
            self.currentResume.email = temp;
            break;
        case 103:
            self.currentResume.school = temp;
            break;
        case 104:
            self.currentResume.major = temp;
            break;
        default:
            break;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 100:
            self.currentResume.realName = textField.text;
            break;
        case 101:
            self.currentResume.mobile = textField.text;
            break;
        case 102:
            self.currentResume.email = textField.text;
            break;
        case 103:
            self.currentResume.school = textField.text;
            break;
        case 104:
            self.currentResume.major = textField.text;
            break;
        default:
            break;
    }
    
    return YES;
}
-(void)keyboardWillShow:(NSNotification *)notification
{
    if (currentTag != 100) {
        mainTableView.contentSize = CGSizeMake(320, 1000);
        [mainTableView scrollRectToVisible:CGRectMake(0, 240,320, mainTableView.frame.size.height) animated:YES];
    }
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    if (currentTag != 100) {
        mainTableView.contentSize = CGSizeMake(320, height);
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [currentTextField resignFirstResponder];
}
-(IBAction)savePersonMessage:(id)sender{
    [[ResumeDataSource instance] changePersonInfo:self.currentResume.realName
                                         resumeId:self.currentResume.resumeId
                                           gender:self.currentResume.gender
                                         birthday:self.currentResume.birthday
                                      nativePlace:self.currentResume.nativePlace
                                    workStartTime:self.currentResume.workStartTime
                                           mobile:self.currentResume.mobile
                                            email:self.currentResume.email
                                           school:self.currentResume.school
                                            major:self.currentResume.major
                                           degree:self.currentResume.degree
                                  politicalStatus:self.currentResume.politicalStatus
                                            token:self.appDelegate.loginUser.token];
}
- (void)changePersonInfoSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"保存成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    alert.tag = 101;
    [alert show];
}
- (void)changePersonInfoFail:(NSString *)message type:(int)type{
    
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
            self.appDelegate.isResumeChanged = YES;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 5;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 4;
            break;
        default:
            break;
    };
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    sectionView.backgroundColor = [UIColor colorWithRed:53/255. green:188/255. blue:122/255. alpha:1];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 35)];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont systemFontOfSize:15];
    switch (section) {
        case 0:
            messageLabel.text = @"个人信息";
            break;
        case 1:
            messageLabel.text = @"联系方式";
            break;
        case 2:
            messageLabel.text = @"学历专业";
            break;
        default:
            break;
    }
    [sectionView addSubview:messageLabel];
    
    return sectionView;
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
    
    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 245, 20)];
    remarkLabel.textAlignment = NSTextAlignmentRight;
    remarkLabel.textColor = [UIColor darkGrayColor];
    remarkLabel.font = [UIFont systemFontOfSize:13];
    remarkLabel.tag = 1000;
    [cell.contentView addSubview:remarkLabel];
    
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
    
    fieldView.layer.borderColor = [UIColor colorWithRed:200/255. green:200/255. blue:200/255. alpha:1].CGColor;
    fieldView.layer.borderWidth = 0.6;
    
    if (indexPath.section == 0) {
        titeleLabel.text = [titleList objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[picList objectAtIndex:indexPath.row]];
        switch (indexPath.row) {
            case 0:
                cell.accessoryType = UITableViewCellAccessoryNone;
                [remarkLabel removeFromSuperview];
                field.text = self.currentResume.realName;
                field.placeholder = @"输入姓名";
                field.tag = 100;
                break;
            case 1:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fieldView removeFromSuperview];
                remarkLabel.text = self.currentResume.gender==0?@"女":@"男";
                break;
            case 2:{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fieldView removeFromSuperview];
                if (self.currentResume.birthday == 0) {
                    remarkLabel.text = @"";
                }else{
                    NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:self.currentResume.birthday];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM"];
                    remarkLabel.text = [formatter stringFromDate:birthDate];
                }
            }break;
            case 3:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fieldView removeFromSuperview];
                remarkLabel.text = self.currentResume.nativePlace;
                break;
            case 4:{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fieldView removeFromSuperview];
                if (self.currentResume.workStartTime == 0) {
                    remarkLabel.text = @"";
                }else{
                    NSDate *workStartDate = [NSDate dateWithTimeIntervalSince1970:self.currentResume.workStartTime];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM"];
                    remarkLabel.text = [formatter stringFromDate:workStartDate];
                }
            }break;
            default:
                break;
        }
    }else if (indexPath.section == 1){
        cell.accessoryType = UITableViewCellAccessoryNone;
        titeleLabel.text = [titleList objectAtIndex:indexPath.row+5];
        imageView.image = [UIImage imageNamed:[picList objectAtIndex:indexPath.row+5]];
        switch (indexPath.row) {
            case 0:
                [remarkLabel removeFromSuperview];
                field.text = self.currentResume.mobile;
                field.placeholder = @"输入电话";
                field.tag = 101;
                break;
            case 1:
                [remarkLabel removeFromSuperview];
                field.text = self.currentResume.email;
                field.placeholder = @"输入邮箱";
                field.tag = 102;
                break;
            default:
                break;
        }
    }else{
        
        titeleLabel.text = [titleList objectAtIndex:indexPath.row+7];
        imageView.image = [UIImage imageNamed:[picList objectAtIndex:indexPath.row+7]];
        switch (indexPath.row) {
            case 0:
                cell.accessoryType = UITableViewCellAccessoryNone;
                [remarkLabel removeFromSuperview];
                field.text = self.currentResume.school;
                field.placeholder = @"毕业院校";
                field.tag = 103;
                break;
            case 1:
                cell.accessoryType = UITableViewCellAccessoryNone;
                [remarkLabel removeFromSuperview];
                field.text = self.currentResume.major;
                field.placeholder = @"输入专业";
                field.tag = 104;
                break;
            case 2:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fieldView removeFromSuperview];
                remarkLabel.text = self.currentResume.degree;
                break;
            case 3:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fieldView removeFromSuperview];
                remarkLabel.text = self.currentResume.politicalStatus;
                break;
            default:
                break;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentIndex = indexPath;
    [currentTextField resignFirstResponder];

    if (currentIndex.section == 0) {
        if (currentIndex.row == 2) {
            pickBgView.hidden = NO;
            pickerView.hidden = YES;
            datePickerView.hidden = NO;
            NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:self.currentResume.birthday];
            [datePickerView setDate:birthDate animated:YES];
        }else if (currentIndex.row == 4){
            pickBgView.hidden = NO;
            pickerView.hidden = YES;
            datePickerView.hidden = NO;
            NSDate *workStartDate = [NSDate dateWithTimeIntervalSince1970:self.currentResume.workStartTime];
            [datePickerView setDate:workStartDate animated:YES];
        }else if (currentIndex.row == 1){
            pickBgView.hidden = NO;
            pickerView.hidden = NO;
            datePickerView.hidden = YES;
            [pickerView reloadAllComponents];
            [pickerView selectRow:self.currentResume.gender == 0?0:1 inComponent:0 animated:YES];
        }else if (currentIndex.row == 3){
            pickBgView.hidden = NO;
            pickerView.hidden = NO;
            datePickerView.hidden = YES;
            [pickerView reloadAllComponents];
            NSArray *list = [self.currentResume.nativePlace componentsSeparatedByString:@" "];
            if (list.count>=2) {
                NSString *province = [list objectAtIndex:0];
                NSString *city = [list objectAtIndex:1];
                for (int i=0;i<provinces.count;i++) {
                    NSString *province1 = [[provinces objectAtIndex:i] objectForKey:@"state"];
                    if ([province1 isEqualToString:province]) {
                        cities = [[provinces objectAtIndex:i] objectForKey:@"cities"];
                        for (int j=0;j<cities.count;j++) {
                            NSString *city1 = [cities objectAtIndex:j];
                            if ([city1 isEqualToString:city]) {
                                [pickerView selectRow:i inComponent:0 animated:YES];
                                [pickerView selectRow:j inComponent:1 animated:YES];
                                break;
                            }
                        }
                        break;
                    }
                }
            }
            
        }
    }else if (currentIndex.section == 2){
        if (currentIndex.row == 2) {
            pickBgView.hidden = NO;
            pickerView.hidden = NO;
            datePickerView.hidden = YES;
            [pickerView reloadAllComponents];
            for (int i=0;i<self.appDelegate.currentAppConfig.degreeList.count;i++) {
                NSString *degree = [self.appDelegate.currentAppConfig.degreeList objectAtIndex:i];
                if ([degree isEqualToString:self.currentResume.degree]) {
                    [pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }else if (currentIndex.row == 3){
            pickBgView.hidden = NO;
            pickerView.hidden = NO;
            datePickerView.hidden = YES;
            [pickerView reloadAllComponents];
            for (int i=0;i<self.appDelegate.currentAppConfig.politicalStatusList.count;i++) {
                NSString *politicalStatus = [self.appDelegate.currentAppConfig.politicalStatusList objectAtIndex:i];
                if ([politicalStatus isEqualToString:self.currentResume.politicalStatus]) {
                    [pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
}
#pragma mark -
#pragma mark pickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (currentIndex.section == 0) {
        if (currentIndex.row == 3) {
            return 2;
        }
    }
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (currentIndex.section == 0) {
        if (currentIndex.row == 1) {
            return 2;
        }else if (currentIndex.row == 3){
            switch (component) {
                case 0:
                    return [provinces count];
                    break;
                case 1:
                    return [cities count];
                    break;
                default:
                    return 0;
                    break;
            }
        }
    }else if (currentIndex.section == 2){
        if (currentIndex.row == 2) {
            return self.appDelegate.currentAppConfig.degreeList.count;
        }else if (currentIndex.row == 3) {
            return self.appDelegate.currentAppConfig.politicalStatusList.count;
        }
    }
    return 10;
}
- (UIView *)pickerView:(UIPickerView *)picker viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, picker.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:28];
    if (currentIndex.section == 0) {
        if (currentIndex.row == 1) {
            if (row == 0) {
                label.text = @"女";
            }else{
                label.text = @"男";
            }
        }else if (currentIndex.row == 3){
            switch (component) {
                case 0:
                    label.text = [[provinces objectAtIndex:row] objectForKey:@"state"];
                    break;
                case 1:
                    label.text = [cities objectAtIndex:row];
                    break;
                default:
                    break;
            }
        }
    }else if (currentIndex.section == 2){
        if (currentIndex.row == 2) {
            label.text = [self.appDelegate.currentAppConfig.degreeList objectAtIndex:row];
        }else if (currentIndex.row == 3) {
            label.text = [self.appDelegate.currentAppConfig.politicalStatusList objectAtIndex:row];
        }
    }
    return label;
}
- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (currentIndex.section == 0) {
        if (currentIndex.row == 3){
            if (component == 0) {
                cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
                [pickerView reloadAllComponents];
                [pickerView selectRow:0 inComponent:1 animated:YES];
            }
        }
    }
}
-(IBAction)dismissPickerView{
    pickBgView.hidden = YES;
}
-(IBAction)confirmPickerView:(id)sender{
    UITableViewCell *cell = [mainTableView cellForRowAtIndexPath:currentIndex];
    UILabel *remarkLabel = (UILabel *)[cell.contentView viewWithTag:1000];
    
    if (currentIndex.section == 0) {
        if (currentIndex.row == 1) {
            NSInteger row=[pickerView selectedRowInComponent:0];
            self.currentResume.gender = row==0?0:1;
            remarkLabel.text = self.currentResume.gender==0?@"女":@"男";
        }else if (currentIndex.row == 2) {
            self.currentResume.birthday = [datePickerView.date timeIntervalSince1970];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM"];
            remarkLabel.text = [formatter stringFromDate:datePickerView.date];
        }else if (currentIndex.row == 3){

            NSInteger row=[pickerView selectedRowInComponent:0];
            NSString *province = [[provinces objectAtIndex:row] objectForKey:@"state"];
            row=[pickerView selectedRowInComponent:1];
            NSString *city = [cities objectAtIndex:row];
            
            self.currentResume.nativePlace = [NSString stringWithFormat:@"%@ %@",province,city];
            remarkLabel.text = self.currentResume.nativePlace;
        }else if (currentIndex.row == 4){
            self.currentResume.workStartTime = [datePickerView.date timeIntervalSince1970];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM"];
            remarkLabel.text = [formatter stringFromDate:datePickerView.date];
        }
    }else if (currentIndex.section == 2){
        if (currentIndex.row == 2) {
            NSInteger row=[pickerView selectedRowInComponent:0];
            self.currentResume.degree = [self.appDelegate.currentAppConfig.degreeList objectAtIndex:row];
            remarkLabel.text = self.currentResume.degree;
        }else if (currentIndex.row == 3) {
            NSInteger row=[pickerView selectedRowInComponent:0];
            self.currentResume.politicalStatus = [self.appDelegate.currentAppConfig.politicalStatusList objectAtIndex:row];
            remarkLabel.text = self.currentResume.politicalStatus;
        }
    }

    pickBgView.hidden = YES;
}
@end
