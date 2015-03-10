//
//  PRBMorseFullScreenView.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 09/09/2014.
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

#import "PRBMorseFullScreenView.h"

@interface PRBMorseFullScreenView()

@property(strong, nonatomic) IBOutlet UILabel* morseLabel;
@property(strong, nonatomic) NSTimer *timer;

@end

#define kFadeTime 2.0
#define kFadeDelay 1.0
#define kLabelMaxOpacity 0.8
#define kTimeToNudge 15.0

@implementation PRBMorseFullScreenView

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setup];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self setup];
    }
    
    return self;
}

-(void)setup{

    //Start a timer
    [self resetTimer:YES];
}

//Reminder about tapping
-(void)resetTimer:(BOOL)isFirst{
    if(_timer)[_timer invalidate];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimeToNudge target:self selector:@selector(remindUser) userInfo:nil repeats:YES];
    [_timer setFireDate:[[NSDate date] dateByAddingTimeInterval:isFirst ? kTimeToNudge / 2.0f : kTimeToNudge]];
}

-(void)holdReminder
{
    if(_timer)[_timer invalidate];
}

-(void)scheduleReminder
{
    [self resetTimer:YES];
}

-(void)remindUser{

    //Prepare
    [_morseLabel setAlpha: 0.0f];
    [_morseLabel setNumberOfLines:0];
    
    [UIView animateWithDuration:kFadeDelay animations:^{
        [_morseLabel setText:@"quick tap\n●\nslow tap\n—"];
        [_morseLabel setAlpha: kLabelMaxOpacity];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kFadeTime delay:kFadeDelay * 2.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [_morseLabel setAlpha: 0.0f];
            
        } completion:^(BOOL finished){
            
        }];
    }];
     
}

-(void)layoutSubviews
{
    [_morseLabel setAdjustsFontSizeToFitWidth:YES];
}

-(void)clearFrequenciesAndChannels{
    
    //Clear frequencies
    if(_morseLabel.text.length > 1 && !([_morseLabel.text containsString:@"."] || [_morseLabel.text containsString:@"-"]))
    {
        [_morseLabel setText:@""];
    }
    
    [self.layer removeAllAnimations];
    [self resetTimer:NO];
    [_morseLabel setNumberOfLines:1];
    
}

-(void)displayMorse:(NSString*)morseChar
{
    [self clearFrequenciesAndChannels];
    
    if(![morseChar isEqualToString:@" "])
    {
        [_morseLabel setAlpha: kLabelMaxOpacity];
        
        if(_morseLabel.text.length == 1 &&
           !([_morseLabel.text isEqualToString:@"-"] || [_morseLabel.text isEqualToString:@"."]))
        {
            [_morseLabel setText:morseChar];
        }
        else
        {
            [_morseLabel setText:[NSString stringWithFormat:@"%@%@", _morseLabel.text.length > 0 ? _morseLabel.text : @"" , morseChar]];
        }
    }
}

-(void)displayLetter:(NSString*)letter
{
    
    [self clearFrequenciesAndChannels];
    
    if(![letter isEqualToString:@" "])
    {
        [_morseLabel setText:letter];
        [_morseLabel setAlpha: kLabelMaxOpacity];
        
        [UIView animateWithDuration:kFadeTime delay:kFadeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [_morseLabel setAlpha: 0.0f];
            
        } completion:^(BOOL finished){
            
        }];
    }
    else
    {
        //Remove random gubbins that's not morse
        if(_morseLabel.text.length > 0 && ([[_morseLabel.text substringFromIndex:_morseLabel.text.length-1] isEqualToString:@"."] ||  [[_morseLabel.text substringFromIndex:_morseLabel.text.length-1] isEqualToString:@"-"]))
        {
            //Not recognized entry
            [_morseLabel setText:@""];
        }
    }
}


@end
