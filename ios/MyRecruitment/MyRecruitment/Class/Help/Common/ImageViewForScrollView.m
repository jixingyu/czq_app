//
//  ImageViewForScrollView.m
//  SuningEMall
//
//  Created by Wang Jia on 11-1-10.
//  Copyright 2011 IBM. All rights reserved.
//

#import "ImageViewForScrollView.h"


@implementation ImageViewForScrollView

@synthesize displayHost = _displayHost;
@synthesize imageDidTouched = _imageDidTouched;
@synthesize index;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
   
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchTimer = [touch timestamp];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchTimer = [touch timestamp] - touchTimer;
    
    NSUInteger tapCount = [touch tapCount];
//    CGPoint touchPoint = [touch locationInView:self];
    
    //判断单击事件，touch时间和touch的区域
    if (tapCount == 1 && touchTimer <= 3)
    {
        if(self.displayHost != nil && [self.displayHost respondsToSelector:self.imageDidTouched])
            [self.displayHost performSelectorOnMainThread:self.imageDidTouched withObject:self waitUntilDone:NO];
    }
    
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//	if(self.displayHost != nil && [self.displayHost respondsToSelector:self.imageDidTouched])
//		[self.displayHost performSelectorOnMainThread:self.imageDidTouched withObject:self waitUntilDone:NO];
//}


@end
