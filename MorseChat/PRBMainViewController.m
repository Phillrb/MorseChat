//
//  PRBMainViewController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 02/09/2014.
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

#import "PRBMainViewController.h"
#import "PRBToneController.h"
#import "PRBMorseOutputController.h"
#import "PRBMorseBannerView.h"
#import "PRBMorseFullScreenView.h"
#import "PRBChannelController.h"
#import "PRBIncomingChatterViewController.h"
#import "PRBMorseCheatSheet.h"
#import "AppDelegate.h"
#import "PRBAboutViewController.h"
@import AVFoundation;


@interface PRBMainViewController()<PRBMorseOutputControllerDelegate>

@property(nonatomic, assign) BOOL isTouchingDown;
@property(nonatomic, strong) PRBMorseOutputController* outputController;
@property(nonatomic, assign) IBOutlet UIStepper *toneFrequencyStepper;
@property(nonatomic, assign) IBOutlet UIStepper *channelStepper;
@property(nonatomic, assign) IBOutlet UIPageControl *toneFrequencyPageControl;
@property(nonatomic, assign) IBOutlet UIPageControl *channgelPageControl;
@property(nonatomic, assign) IBOutlet PRBMorseBannerView* outgoingMorseBanner;
@property(nonatomic, assign) IBOutlet PRBMorseFullScreenView* outgoingMorseFullscreenView;
@property(nonatomic, strong) PRBIncomingChatterViewController* chatterViewController;
@property(nonatomic, assign) IBOutlet PRBMorseCheatSheet *cheatSheet;
@property(nonatomic, assign) BOOL isShowingCheatSheet;
@property(nonatomic, assign) BOOL isAnimatingCheatSheet;
@property(nonatomic, retain) UIView *tapView;

-(IBAction)toneFrequencyDidChangeWithStepper:(id)sender;

@end

#define kTapDimension 150.0f
#define kTapAlpha 0.3f

@implementation PRBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Start taking input from user
    _outputController = [[PRBMorseOutputController alloc] init];
    [_outputController setDelegate:self];
    
    _barViewController = [[PRBConnectionBarViewController alloc] init];
    [self.view addSubview:_barViewController.view];
    
    _isShowingCheatSheet = NO;
    [_cheatSheet setAlpha:0.0f];
    
    //Limit frequency stepper
    double stepValue = (([[PRBToneController sharedToneController] maxToneFrequency] - [[PRBToneController sharedToneController] minToneFrequency]) / ([[PRBToneController sharedToneController] numberOfToneSteps]));
    
    [_toneFrequencyStepper setMinimumValue:[[PRBToneController sharedToneController] minToneFrequency]];
    [_toneFrequencyStepper setMaximumValue:[[PRBToneController sharedToneController] maxToneFrequency]];
    [_toneFrequencyStepper setStepValue:stepValue];
    [_toneFrequencyStepper setValue:[[PRBToneController sharedToneController] currentToneFrequency]];
    
    [self updateTonePageControl];
    
    //Setup incoming chatter view controller
    _chatterViewController = [[PRBIncomingChatterViewController alloc] init];
    [_chatterViewController setBar:_barViewController];
    
    CGRect chatterViewFrame = CGRectMake(0.0f, _outgoingMorseFullscreenView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - _outgoingMorseFullscreenView.frame.origin.y);
    [_chatterViewController setupViewWithFrame:chatterViewFrame];
    [_chatterViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view insertSubview:_chatterViewController.view belowSubview: _outgoingMorseFullscreenView];
    
    [[PRBChannelController sharedChannelController] setConnectionDelegate:_chatterViewController];
    
    //Assign channel and start looking for connections
    [_channelStepper setMinimumValue:[[PRBChannelController sharedChannelController] minChannel]];
    [_channelStepper setMaximumValue:[[PRBChannelController sharedChannelController] maxChannel]];
    [_channelStepper setValue:[[PRBChannelController sharedChannelController] currentChannel]];
    
    [self updateChannelPageControl];
    
    //Create tap view
    _tapView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kTapDimension, kTapDimension)];
    _tapView.alpha = 0.0;
    _tapView.layer.cornerRadius = kTapDimension / 2.0f;
    _tapView.backgroundColor = [UIColor blackColor];
    [_tapView setUserInteractionEnabled:NO];
    [self.view addSubview:_tapView];

    //On rotate
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [_outgoingMorseBanner refreshMorseScroll];
        
    }];

}

-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarTapped:) name:kStatusBarTappedNotification object:nil];
    [_outgoingMorseFullscreenView scheduleReminder];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
    [_outgoingMorseFullscreenView holdReminder];
}


-(void)updateTonePageControl{
    
    NSInteger numberOfPages = [[PRBToneController sharedToneController] numberOfToneSteps]+ 1;
    NSInteger currentPage =  [[PRBToneController sharedToneController] currentToneFrequency] / (([[PRBToneController sharedToneController] maxToneFrequency] -  [[PRBToneController sharedToneController] minToneFrequency]) / [[PRBToneController sharedToneController] numberOfToneSteps]);
    
    [_toneFrequencyPageControl setNumberOfPages:numberOfPages];
    [_toneFrequencyPageControl setCurrentPage:currentPage];
}

-(void)updateChannelPageControl{
    
    NSInteger numberOfPages = [[PRBChannelController sharedChannelController] maxChannel] - [[PRBChannelController sharedChannelController] minChannel] + 1;
    
    NSInteger currentPage = [[PRBChannelController sharedChannelController] currentChannel] - 1;
    
    [_channgelPageControl setNumberOfPages:numberOfPages];
    [_channgelPageControl setCurrentPage:currentPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Deal with morse input from user
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!_isTouchingDown) {
        
        _isTouchingDown = YES;
        
        //Transmit beep
        [self startTransmit];
        
        UITouch *touch = [touches anyObject];
        
        if (touch && touch.view == _outgoingMorseFullscreenView)
        {
            //Show tap
            [_tapView setAlpha:kTapAlpha];
            [_tapView setCenter:[touch locationInView:self.view]];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self stopTransmitIfNecessary];
    
    //Remove tap view
    [_tapView setAlpha:0.0f];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self stopTransmitIfNecessary];
    
    //Remove tap view
    [_tapView setAlpha:0.0f];
    
    [super touchesEnded:touches withEvent:event];
}

-(void)stopTransmitIfNecessary{
    if(_isTouchingDown)
    {
        _isTouchingDown = NO;
        
        //Stop transmitting beep
        [self stopTransmit];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    if (touch && touch.view == _outgoingMorseFullscreenView)
    {
        //Move tap
        [_tapView setCenter:[touch locationInView:self.view]];
    }

}




#pragma mark- transmit

-(void)startTransmit{
    
    //Play sound
    [[PRBToneController sharedToneController] startTone];
    //Pass user input to outputter
    [_outputController userInputStart];
    
    //Turn LED on
    [self performSelectorInBackground:@selector(flashlight:) withObject:[NSNumber numberWithBool:YES]];
    
}

-(void)stopTransmit{
    
    //Stop sound
    [[PRBToneController sharedToneController] stopTone];
    //Pass user input to outputter 
    [_outputController userInputStop];
    
    //Turn LED off
    [self performSelectorInBackground:@selector(flashlight:) withObject:[NSNumber numberWithBool:NO]];
    
}




#pragma mark - Actions
-(IBAction)toneFrequencyDidChangeWithStepper:(id)sender
{
    UIStepper* stepper = (UIStepper*)sender;
    [[PRBToneController sharedToneController] setToneFrequency: stepper.value];

    [self updateTonePageControl];
    
    //Display change
    [_outgoingMorseFullscreenView displayLetter:[NSString stringWithFormat:@"%.0fmhz", stepper.value]];
}


- (IBAction)channelDidChangeWithStepper:(id)sender {
    
    UIStepper* stepper = (UIStepper*) sender;
    [[PRBChannelController sharedChannelController] setCurrentChannel:(NSInteger)stepper.value];
    
    [self updateChannelPageControl];
    
    //Display change
    [_outgoingMorseFullscreenView displayLetter:[NSString stringWithFormat:@"channel %.0f", stepper.value]];
    
    //reset chatter
    [_chatterViewController clear];
}


-(IBAction)cheatSheetButtonPressed:(id)sender
{
    if(_isAnimatingCheatSheet) return;
    _isAnimatingCheatSheet = YES;
    
    UIButton* btn = (UIButton*)sender;
    
    if(_isShowingCheatSheet)
    {
        [btn setTitle:@"Show" forState:UIControlStateNormal];

        //Hide
        [UIView animateWithDuration:.3f animations:^{
            [_cheatSheet setAlpha:0.0f];
        } completion:^(BOOL finished) {
            _isShowingCheatSheet = NO;
            _isAnimatingCheatSheet = NO;
        }];
    }
    else
    {
        [btn setTitle:@"Hide" forState:UIControlStateNormal];
        
        //Hide
        [UIView animateWithDuration:.3f animations:^{
            [_cheatSheet setAlpha:1.0f];
        } completion:^(BOOL finished) {
            _isShowingCheatSheet = YES;
            _isAnimatingCheatSheet = NO;
        }];

    }
    
    
}

#pragma mark - output
-(void)outputController:(PRBMorseOutputController*)outputController didOutputLetter:(NSString*)letter
{
    [_outgoingMorseBanner appendLetter:letter];
    [_outgoingMorseFullscreenView displayLetter:letter];
    [[PRBChannelController sharedChannelController] sendLetterToChannel:letter];
}

-(void)outputController:(PRBMorseOutputController*)outputController didOutputDotDashSpace:(NSString*)dotDashSpace
{
    [_outgoingMorseBanner appendMorse:dotDashSpace];
    [_outgoingMorseFullscreenView displayMorse:dotDashSpace];
    [[PRBChannelController sharedChannelController] sendMorseToChannel:dotDashSpace];
}



#pragma mark - cleanup
- (void)viewDidUnload {
    
    [[PRBToneController sharedToneController] cleanup];
    [[PRBChannelController sharedChannelController] disconnect];
}

#pragma mark - statusbar tap
-(void)statusBarTapped:(NSNotification*)notification{
    
//    NSLog(@"MVC STATUS TAPPED");
    
    //Pretend channel has changed
    [self channelDidChangeWithStepper:_channelStepper];
    
    //Searching
    [_chatterViewController.bar performSelectorOnMainThread:@selector(startedSearchingForPeers) withObject:nil waitUntilDone:NO];
    
}

#pragma mark - torch

- (void) flashlight:(NSNumber*)changeToOnNum
{
    if(![PRBAboutViewController canUseTorch]) return;
    
    BOOL changeToOn = changeToOnNum.boolValue;
    
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if(changeToOn && ![flashLight isTorchActive])
            {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
            }
            else if(!changeToOn)
            {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            }
            
            [flashLight unlockForConfiguration];
        }
    }
}

@end
