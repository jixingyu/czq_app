//
//  ImageViewForScrollView.h
//  SuningEMall
//
//  Created by Wang Jia on 11-1-10.
//  Copyright 2011 IBM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewForScrollView : UIImageView {
	NSObject	*_displayHost;
	SEL			_imageDidTouched;
    NSTimeInterval touchTimer;
}

@property (nonatomic, strong) NSObject	*displayHost;
@property (nonatomic, assign) SEL		imageDidTouched;
@property (nonatomic, assign) int       index;
@end
