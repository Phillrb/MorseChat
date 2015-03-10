//
//  PRBMorseAlphaNumericRecognizer.m
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

#import "PRBMorseAlphaNumericRecognizer.h"

@interface PRBMorseAlphaNumericRecognizer()

@property(nonatomic,retain) NSDate *charDuration;
@property(nonatomic,retain) NSDate *silenceDuration;
@property(nonatomic,retain) NSMutableString *currentMorseChar;
@property(nonatomic,retain) NSDictionary *morseDict;
@end

@implementation PRBMorseAlphaNumericRecognizer

//#define OLog(...) NSLog(__VA_ARGS__)
#define OLog(...)

#define maxDurationBetweenPips 0.425 // just > 1 unit
#define maxWaitForNextChar 3.0 * maxDurationBetweenPips //was 1.0 - should be 3 units

NSTimer *endTimer;

-(id)init{
    
    self = [super init];
    
    if (self) {

        _morseDict =
                @{
                    @".-"   :   @"a",
                    @"-..." :   @"b",
                    @"-.-." :   @"c",
                    @"-.."  :   @"d",
                    @"."    :   @"e",
                    @"..-." :   @"f",
                    @"--."  :   @"g",
                    @"...." :   @"h",
                    @".."   :   @"i",
                    @".---" :   @"j",
                    @"-.-"  :   @"k",
                    @".-.." :   @"l",
                    @"--"   :   @"m",
                    @"-."   :   @"n",
                    @"---"  :   @"o",
                    @".--." :   @"p",
                    @"--.-" :   @"q",
                    @".-."  :   @"r",
                    @"..."  :   @"s",
                    @"-"    :   @"t",
                    @"..-"  :   @"u",
                    @"...-" :   @"v",
                    @".--"  :   @"w",
                    @"-..-" :   @"x",
                    @"-.--" :   @"y",
                    @"--.." :   @"z",
                    
                    @".----":   @"1",
                    @"..---":   @"2",
                    @"...--":   @"3",
                    @"....-":   @"4",
                    @".....":   @"5",
                    @"-....":   @"6",
                    @"--...":   @"7",
                    @"---..":   @"8",
                    @"----.":   @"9",
                    @"-----":   @"0"
                };
        
    }
    
    return self;
}


-(void)userInputStart{
    
    //Cancel any timer
    [endTimer invalidate];
    endTimer = nil;
    
    //Calculate silence
    [self analyzeLastEntry];
}

-(void)userInputStop{
    
    //Mark start of silence
    _silenceDuration = [NSDate date];
    
    //Limit time for wait
    if(!endTimer) endTimer = [NSTimer scheduledTimerWithTimeInterval:maxWaitForNextChar target:self selector:@selector(charShouldEnd:) userInfo:nil repeats:NO];
    
}

-(void)charShouldEnd:(NSTimer*)timer{
    
    //New char! Convert last to Alpha-Numeric
    [self translateMorseToAlphaNum:_currentMorseChar];
    
    _currentMorseChar = nil;
    
//    OLog(@" ");
    [_delegate morseAlphaNumericRecognizer:self didRecognizeInput:@" "];
    
}

-(void)analyzeLastEntry{
    
    //If this is the first time then ignore this
    if(!_silenceDuration || !_currentMorseChar) return;
    
    //Is this the start of a new morse char?
    NSTimeInterval timeSinceLastPip = [[NSDate date] timeIntervalSinceDate:_silenceDuration];
    
    //Stop recording silence
    _silenceDuration = nil;
    
    if(timeSinceLastPip > maxDurationBetweenPips)
    {
        //New char! Convert last to Alpha-Numeric
        [self translateMorseToAlphaNum:_currentMorseChar];
        
        _currentMorseChar = nil;
        
//        OLog(@" ");
        [_delegate morseAlphaNumericRecognizer:self didRecognizeInput:@" "];
    }

}

-(void)dotDashReceived:(BOOL)isDot{
    
    if(!_currentMorseChar)
    {
        //Just add pip to new morse char
        _currentMorseChar = [NSMutableString stringWithString:isDot ? @"." : @"-"];
    }
    else
    {
        //append existing char
        [_currentMorseChar appendString:isDot ? @"." : @"-"];
    }
    
//    if(isDot)OLog(@".");
//    else OLog(@"-");
}

#pragma mark - translate
-(void)translateMorseToAlphaNum:(NSString*)morseString{
    
    //Translate and pass back
    NSString* alphaNum = [_morseDict objectForKey:morseString];
    
    if(alphaNum)
    {
        [_delegate morseAlphaNumericRecognizer:self didRecognizeInput:alphaNum];
    }

}

@end
