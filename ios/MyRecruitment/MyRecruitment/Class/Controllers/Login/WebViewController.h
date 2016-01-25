//
//  WebViewController.h
//  EEvent
//
//  Created by developer on 15/5/27.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "BaseViewController.h"

@interface WebViewController : BaseViewController

@property(nonatomic,strong) NSURL *url;
@property(nonatomic,strong) NSString *html;
@end
