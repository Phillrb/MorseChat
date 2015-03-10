//
//  PRBMorseOutputController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 04/09/2014.
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

#import "PRBMorseOutputController.h"
#import "PRBMorseAlphaNumericRecognizer.h"
#import "PRBMorseDotDashRecognizer.h"

@interface PRBMorseOutputController()<PRBMorseAlphaNumericRecognizerDelegate, PRBMorseDotDashRecognizerDelegate>

@property(nonatomic,retain) PRBMorseAlphaNumericRecognizer *outgoingAlphaNumericRecognizer;
@property(nonatomic,retain) PRBMorseDotDashRecognizer* outgoingDotDashRecognizer;

@end

@implementation PRBMorseOutputController

-(id)init{
    
    self = [super init];
    
    if(self)
    {
        //Prepare Alpha Num recog
        _outgoingAlphaNumericRecognizer = [[PRBMorseAlphaNumericRecognizer alloc] init];
        [_outgoingAlphaNumericRecognizer setDelegate:self];
        
        //Prepare dotDashRecog
        _outgoingDotDashRecognizer = [[PRBMorseDotDashRecognizer alloc] init];
        [_outgoingDotDashRecognizer setDelegate:self];
    }
    
    return self;
    
}

-(void)userInputStart{
    
    //begin recognition
    [_outgoingAlphaNumericRecognizer userInputStart];
    [_outgoingDotDashRecognizer startRecog];
}

-(void)userInputStop{
    
    //stop recognition
    [_outgoingAlphaNumericRecognizer userInputStop];
    [_outgoingDotDashRecognizer stopRecog];
}

#define alpha numeric delegate
-(void)morseAlphaNumericRecognizer:(PRBMorseAlphaNumericRecognizer*)recognizer didRecognizeInput:(NSString*)charInput
{
//    NSLog(@"%@", charInput);
    
    if(recognizer == _outgoingAlphaNumericRecognizer)
    {
        //Inform local delegate for UI purposes
        if (_delegate && [_delegate respondsToSelector:@selector(outputController:didOutputLetter:)])
        {
            [_delegate outputController:self didOutputLetter:charInput];
        }
        
        //Space in DOT DASH sequence too?
        if([charInput isEqualToString:@" "])
        {
            if (_delegate && [_delegate respondsToSelector:@selector(outputController:didOutputDotDashSpace:)])
            {
                [_delegate outputController:self didOutputDotDashSpace:charInput];
            }
        }
    }
}

#pragma mark - dot dash recog
-(void)morseDotDashRecognizer:(PRBMorseDotDashRecognizer *)recognizer didRecognizeInput:(BOOL)isDot{
    
    if(recognizer == _outgoingDotDashRecognizer)
    {
        //Inform local UI
        if (_delegate && [_delegate respondsToSelector:@selector(outputController:didOutputDotDashSpace:)])
        {
            [_delegate outputController:self didOutputDotDashSpace:isDot? @".":@"-"];
        }
        
        //Analyze dot dash group
        [_outgoingAlphaNumericRecognizer dotDashReceived:isDot];
        
    }
}


@end
