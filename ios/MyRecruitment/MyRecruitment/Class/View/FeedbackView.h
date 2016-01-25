//
//  FeedbackView.h
//  MyRecruitment
//
//  Created by developer on 15/6/30.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedbackDelegate <NSObject>

-(void)submitFeedback:(NSString *)message;

@end

@interface FeedbackView : UIView{
    UITextView *feedbackTextView;
}

@property(nonatomic,assign) id<FeedbackDelegate> delegate;

-(void)initView;
-(void)downKeyboard;

@end
