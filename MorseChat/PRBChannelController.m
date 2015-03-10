//
//  PRBChannelController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 17/09/2014.
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

#import "PRBChannelController.h"

@interface PRBChannelController()

@property(nonatomic, retain) PRBChannelConnection* connection;

@end

@implementation PRBChannelController

#define kDefaultChannel 1
#define kMinChannel 1
#define kMaxChannel 6

NSInteger channel;
BOOL isConnecting;

#define CHALog(...) NSLog(__VA_ARGS__)
//#define CHALog(...)

PRBChannelController* sharedChannelController;

+(PRBChannelController*)sharedChannelController
{
    if(!sharedChannelController)
    {
        sharedChannelController = [[PRBChannelController alloc] init];
        
        //Setup connection
        sharedChannelController.connection = [[PRBChannelConnection alloc] initWithChannel:sharedChannelController.currentChannel];
    }
    
    return sharedChannelController;
}

-(id)init{
    self = [super init];
    
    if(self)
    {
        channel = kDefaultChannel;
    }
    
    return self;
}

//Pass delegate
-(void)setConnectionDelegate:(NSObject<PRBChannelConnectionDelegate>*)connectionDelegate{
    [sharedChannelController.connection setDelegate:connectionDelegate];
    
}

#pragma mark - channels
-(NSInteger)currentChannel
{
    return channel;
}

-(void)setCurrentChannel:(NSInteger)newChannel
{
    if(newChannel >= kMinChannel && newChannel <= kMaxChannel)
    {
        CHALog(@"PRBChannelController: change channel: %li", (long)newChannel);
        
        channel = newChannel;
        
        //Disconnect channel connection
        [_connection disconnect];
        
        //Hold ref to delegate
        NSObject<PRBChannelConnectionDelegate>* connectionDelegate = _connection.delegate;
        
        //Destroy
        _connection = nil;
        
        //Recreate
        _connection = [[PRBChannelConnection alloc] initWithChannel:channel];
        [_connection setDelegate:connectionDelegate];
        
        //Connect
        [_connection connect];
    }
}

-(NSInteger)minChannel
{
    return kMinChannel;
}

-(NSInteger)maxChannel
{
    return kMaxChannel;
}


#pragma mark - connection
-(void)connect
{
    CHALog(@"PRBChannelController: CONNECT");
    [_connection connect];
    
}
-(void)disconnect
{
    CHALog(@"PRBChannelController: DISCONNECT");
    [_connection disconnect];
}

-(void)sendMorseToChannel:(NSString*)morse
{
    [_connection sendMorseToChannel:morse];
}
-(void)sendLetterToChannel:(NSString*)letter
{
    [_connection sendLetterToChannel:letter];
}


@end
