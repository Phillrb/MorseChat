//
//  PRBToneController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 03/09/2014.
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

#import "PRBToneController.h"
#import "PRBAboutViewController.h"
@import  AVFoundation;

@interface PRBToneController()

@property (nonatomic, strong) NSMutableArray* controllers;
@property (nonatomic, strong) NSMutableArray* toneQueue;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) NSNumber* frequency;
@property (nonatomic, strong) NSNumber* sampleRate;
@property (nonatomic, strong) NSNumber* theta;
@property (nonatomic, assign) AudioComponentInstance toneUnit;

@end

@implementation PRBToneController

//#define TLog(...) NSLog(__VA_ARGS__)
#define TLog(...)

#define kToneFrequencyMin 300.0
#define kToneFrequencyMax 3000.0
#define kToneFrequencyNumberOfSteps 5

#define kToneFrequencyDefault ((kToneFrequencyMax - kToneFrequencyMin) / kToneFrequencyNumberOfSteps) + kToneFrequencyMin

#define kDotLength 0.3f
#define kDashLength 0.75f

//double frequency;

PRBToneController* sharedToneController;

+(PRBToneController*)sharedToneController
{
    if(!sharedToneController)
    {
        sharedToneController = [[PRBToneController alloc] init];
        sharedToneController.controllers = [[NSMutableArray alloc] init];
    }
    
    return sharedToneController;
}

-(id)init{
    self = [super init];
    
    if(self)
    {
        //Setup
        _sampleRate = [NSNumber numberWithDouble:44100];
        
        //Tone
        _frequency = [NSNumber numberWithDouble:kToneFrequencyDefault];
        
        //Ausio session interruptions
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidChangeInterruptionType:)
                                                     name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        _toneQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)manageController:(PRBToneController*)controller{
    
    [[PRBToneController sharedToneController].controllers addObject:controller];
    
}

-(void)startTone{
    
    TLog(@"START TONE");
    [self createToneUnit];
    
    // Stop changing parameters on the unit
    OSErr err = AudioUnitInitialize(_toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
    
    // Start playback
    err = AudioOutputUnitStart(_toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    
}

-(void)stopTone{
    
    TLog(@"STOP TONE");
    if (_toneUnit)
    {
        AudioOutputUnitStop(_toneUnit);
        AudioUnitUninitialize(_toneUnit);
        AudioComponentInstanceDispose(_toneUnit);
        _toneUnit = nil;
    }
    
}

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
    // Fixed amplitude is good enough for our purposes
    const double amplitude = 0.25;
    
    PRBToneController* toneController = (__bridge PRBToneController*)inRefCon;
    
    // Get the tone parameters out of the view controller
    double theta_increment = 2.0 * M_PI * toneController.frequency.doubleValue / toneController.sampleRate.doubleValue;
    
    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        buffer[frame] = sin(toneController.theta.doubleValue) * amplitude;
        
        toneController.theta = [NSNumber numberWithDouble:toneController.theta.doubleValue + theta_increment];
        if (toneController.theta.doubleValue > 2.0 * M_PI)
        {
            toneController.theta = [NSNumber numberWithDouble:toneController.theta.doubleValue - 2.0 * M_PI];
        }
    }
    
    return noErr;
}

- (void)createToneUnit
{
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // Create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
    NSAssert1(_toneUnit, @"Error creating unit: %hd", err);
    
    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = (__bridge void *)(self);
    err = AudioUnitSetProperty(_toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = _sampleRate.doubleValue;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (_toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
}

@class PRBToneController;

- (void)audioSessionDidChangeInterruptionType:(NSNotification *)notification
{
    AVAudioSessionInterruptionType interruptionType = [[[notification userInfo]
                                                        objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (AVAudioSessionInterruptionTypeBegan == interruptionType)
    {
        [self stopAllTones];
    }
    else if (AVAudioSessionInterruptionTypeEnded == interruptionType)
    {
        
    }
}

-(void)stopAllTones{
    
    //Stop shared tone
    [[PRBToneController sharedToneController] stopTone];
    
    //Stop other managed tones
    NSArray* controllers = [PRBToneController sharedToneController].controllers;
    for (PRBToneController* controller in controllers) {
        
        if(controller)[controller stopTone];
        
    }
}

#pragma mark - tone frequency
-(void)setToneFrequency:(double)newFrequency
{
    if(newFrequency >= kToneFrequencyMin
       && newFrequency <= kToneFrequencyMax)
    {
        _frequency = [NSNumber numberWithDouble:newFrequency];
    }
}

-(double)minToneFrequency{
    return kToneFrequencyMin;
}
-(double)maxToneFrequency{
    return kToneFrequencyMax;
}

-(double)currentToneFrequency{
    return _frequency.doubleValue;
}

-(NSInteger)numberOfToneSteps{
    return kToneFrequencyNumberOfSteps;
}



-(void)dashTone
{
    [_toneQueue addObject:@"-"];
    [self nudgeQueue];
}

-(void)dotTone
{
    [_toneQueue addObject:@"."];
    [self nudgeQueue];
}

-(void)nudgeQueue{
    
    if(_toneQueue.count <= 0 || _isPlaying) return;
    
    NSString *nextToneAction = [_toneQueue firstObject];
    [_toneQueue removeObjectAtIndex:0];
    
    if (nextToneAction) {
        
        _isPlaying = YES;
        if([nextToneAction isEqualToString:@"-"]) [self performDash];
        else if([nextToneAction isEqualToString:@"."]) [self performDot];
        else
        {
            _isPlaying = NO;
        }
    }
}


-(void)performDash
{
    TLog(@"DASH TONE");
    [self stopTone];
    [self startTone];
    [self performSelectorOnMainThread:@selector(stopOnMainDash) withObject:nil waitUntilDone:NO];
}

-(void)performDot
{
    TLog(@"DOT TONE");
    [self stopTone];
    [self startTone];
    [self performSelectorOnMainThread:@selector(stopOnMainDot) withObject:nil waitUntilDone:NO];
}




//Execute stop sound
-(void)stopOnMainDash{
    [self performSelector:@selector(stopAndAllowNextToneToPlayAfterDelay) withObject:nil afterDelay:kDashLength];
}
-(void)stopOnMainDot{
    [self performSelector:@selector(stopAndAllowNextToneToPlayAfterDelay) withObject:nil afterDelay:kDotLength];
}

-(void)stopAndAllowNextToneToPlayAfterDelay{
    [self stopTone];
    [self performSelector:@selector(allowNextToneToPlay) withObject:nil afterDelay:kDotLength];
}

-(void)allowNextToneToPlay{
    _isPlaying = NO;
    [self nudgeQueue];
}

#pragma mark - cleanup
-(void)cleanup{
    [[PRBToneController sharedToneController].controllers removeObject:self];
}

@end
