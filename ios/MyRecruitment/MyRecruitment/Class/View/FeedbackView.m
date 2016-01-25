//
//  FeedbackView.m
//  MyRecruitment
//
//  Created by developer on 15/6/30.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "FeedbackView.h"

@implementation FeedbackView
@synthesize delegate;

-(void)initView{
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downButton.frame = CGRectMake(0, 0, 320,  IS_IPHONE5?568-64-44-49:480-64-44-49);
    [downButton addTarget:self action:@selector(downKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downButton];
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    hintLabel.text = @"请输入您宝贵的意见";
    hintLabel.font = [UIFont systemFontOfSize:15];
    hintLabel.textColor = [UIColor colorWithRed:242/255. green:105/255. blue:63/255. alpha:1];
    [self addSubview:hintLabel];
    
    feedbackTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 300, 200)];
    feedbackTextView.layer.borderColor = [UIColor colorWithRed:242/255. green:105/255. blue:63/255. alpha:1].CGColor;
    feedbackTextView.layer.borderWidth = 1;
    [self addSubview:feedbackTextView];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(20, IS_IPHONE5?568-64-44-49-60:480-64-44-49-60, 280, 40);
    [submitButton setTitle:@"提交并保存" forState:UIControlStateNormal];
    submitButton.backgroundColor = [UIColor colorWithRed:242/255. green:105/255. blue:63/255. alpha:1];
    [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.layer.cornerRadius = 20;
    submitButton.clipsToBounds = YES;
    [self addSubview:submitButton];
}
-(void)submit:(NSString *)message{
    [self.delegate submitFeedback:feedbackTextView.text];
}
-(void)downKeyboard{
    [feedbackTextView resignFirstResponder];
}
@end
