//
//  PRBConnectionBarViewController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 04/10/2014.
//  Copyright (c) 2014 Phillip Riscombe-Burton. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ITProgressBar.h"
#import "PRBConnectionBarViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PRBConnectionBarViewController ()

@property(nonatomic, retain) ITProgressBar *progressView;

@end

@implementation PRBConnectionBarViewController

//#define COLog(...) NSLog(__VA_ARGS__)
#define COLog(...)

#define kAnimationDuration 2.0f
#define kAnimationFadeDuration 0.3f

-(id)init{
    
    self = [super init];
    
    if(self)
    {
        //Create view at top for tapping
        UIView *topView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        
        _progressView = [[ITProgressBar alloc] initWithFrame:topView.bounds];
        [_progressView setTintColor:[UIColor lightGrayColor]];
        [_progressView setAlpha:0.0f];
        [topView addSubview:_progressView];

        [self setView:topView];
        
        
        //Custom resizing on rotation - autoresize not working for this badger!
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [_progressView.superview setFrame:[UIApplication sharedApplication].statusBarFrame];
            [_progressView setBounds:topView.bounds];
            
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareChange{
    [_progressView setAlpha:1.0f];
    
    [_progressView.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:kAnimationDuration];
}

-(void)startedSearchingForPeers
{
    COLog(@"> SEARCHING");
    [_progressView setTintColor:[UIColor lightGrayColor]];
    [self prepareChange];
}

-(void)peerConnecting
{
     COLog(@"> CONNECTING");
    [_progressView setTintColor:[[UIColor purpleColor] colorWithAlphaComponent:0.4f]];
    [self prepareChange];
}

-(void)peerConnected
{
     COLog(@"> CONNECTED");
    [_progressView setTintColor:[[UIColor greenColor] colorWithAlphaComponent:0.4f]];
    [self prepareChange];
}

-(void)peerDropped
{
     COLog(@"> DROPPED");
    [_progressView setTintColor:[[UIColor redColor] colorWithAlphaComponent:0.4f]];
    [self prepareChange];
}



-(void)stopAnimating
{
    COLog(@"> FADE");
    [UIView animateWithDuration:kAnimationFadeDuration animations:^{
        [_progressView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        COLog(@"> DONE");
        [_progressView setTintColor:[UIColor lightGrayColor]];
        [_progressView setAlpha:0.0f];
    }];

}
@end
