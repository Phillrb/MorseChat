//
//  PRBChannelConnection.m
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

#import "PRBChannelConnection.h"
#import "AppDelegate.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <MultipeerConnectivity/MCNearbyServiceAdvertiser.h>
#import <MultipeerConnectivity/MCNearbyServiceBrowser.h>
#include <string>
#import "PRBToneController.h"
#import "Flurry.h"

using namespace std;

@interface PRBChannelConnection() <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

@property(nonatomic, retain) MCNearbyServiceAdvertiser *advertiser;
@property(nonatomic, retain) MCNearbyServiceBrowser *browser;
@property(nonatomic, retain) MCSession *sessionAdvertise;
@property(nonatomic, retain) MCSession *sessionBrowse;

@end

@implementation PRBChannelConnection

#define kPRBMorseService @"discover-morse"
#define kPRBChannelNumber @"channel"

#define kPRBMorse @"morse"
#define kPRBLetter @"letter"
#define kPRBFreq @"freq"

#define kRetryTime 10

BOOL isAdvertising = NO;
BOOL isBrowsing = NO;

#define CHLog(...) NSLog(__VA_ARGS__)
//#define CHLog(...)

-(id)initWithChannel:(NSInteger)channel{
    
    self = [super init];
    
    if(self)
    {
        //Get Peer ID
        MCPeerID *peerID = [self newPeerID];
        
        //Get Advertiser
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID discoveryInfo:@{kPRBChannelNumber:[NSString stringWithFormat:@"%li", (long)channel]} serviceType:kPRBMorseService];
        [_advertiser setDelegate:self];
        
        //Get Browser
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:kPRBMorseService];
        [_browser setDelegate:self];
        
        //Create session
        _sessionAdvertise = [[MCSession alloc] initWithPeer:peerID];
        [_sessionAdvertise setDelegate:self];
        
        _sessionBrowse = [[MCSession alloc] initWithPeer:peerID];
        [_sessionBrowse setDelegate:self];
        
        //Now advertise and browse
        isAdvertising = YES;
        [_advertiser startAdvertisingPeer];
        
        isBrowsing = YES;
        [_browser startBrowsingForPeers];
    }
    
    return self;
}

-(MCPeerID*)newPeerID{
    NSString *deviceName = [UIDevice currentDevice].name;
    
    //Replace deviceName if it's not valid for use
    if (!deviceName || deviceName.length <= 0) deviceName = [UIDevice currentDevice].model;
    else
    {
        const char* deviceNameStr = [deviceName UTF8String];
        if( sizeof(deviceNameStr) > 63)
        {
            deviceName = [UIDevice currentDevice].model;
        }
    }
    
    return [[MCPeerID alloc] initWithDisplayName:deviceName];
}

-(void)cancelDelayedSelectors{
    
    if(_advertiser) [NSObject cancelPreviousPerformRequestsWithTarget:_advertiser selector:@selector(startAdvertisingPeer) object:nil];
    
    if(_browser) [NSObject cancelPreviousPerformRequestsWithTarget:_browser selector:@selector(startBrowsingForPeers) object:nil];
}

#pragma mark - connection
-(void)connect
{
    CHLog(@"+ PRBChannelConnection: connect");
    [self cancelDelayedSelectors];
    
    if (_advertiser && !isAdvertising)
    {
        CHLog(@"PRBChannelConnection: connect adv");
        isAdvertising = YES;
        [_advertiser startAdvertisingPeer];
    }
    
    if(_browser && !isBrowsing)
    {
        CHLog(@"PRBChannelConnection: connect browse");
        isBrowsing = YES;
        [_browser startBrowsingForPeers];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(startingToSearch)])
    {
        [_delegate startingToSearch];
    }
}

-(void)disconnect
{
    CHLog(@"+ PRBChannelConnection: disconnect");
    [self cancelDelayedSelectors];
    
    if(_advertiser && isAdvertising)
    {
        CHLog(@"PRBChannelConnection: disconnect adv");
        isAdvertising = NO;
        [_advertiser stopAdvertisingPeer];
    }
    
    if(_browser && isBrowsing)
    {
        CHLog(@"PRBChannelConnection: disconnect browse");
        isBrowsing = NO;
        [_browser stopBrowsingForPeers];
    }
}

#pragma mark - advertiser

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    CHLog(@"PRBChannelConnection: Advertiser got invite from: %@", peerID.displayName);
    
    //Refuse if they should be the client
    CHLog(@"Adv PEER-ID: %li , THIS PEER: %li", (long)peerID.hash, (long)_advertiser.myPeerID.hash);
    
    //Refuse if they should be the server
    if(peerID.hash <= advertiser.myPeerID.hash)
    {
        CHLog(@"PRBChannelConnection: adv - Peer should be server - no connect: %@", peerID.displayName);
        invitationHandler(NO, nil);
//        [_browser invitePeer:peerID toSession:_sessionBrowse withContext:nil timeout:0];
        return;
    }
    
    //Pass session for them to connect to
    CHLog(@"PRBConnection: adv - Allowing peer to connect: %@", peerID.displayName);
    [Flurry logEvent:@"Peer connect request a"];
    invitationHandler(YES, _sessionAdvertise);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    CHLog(@"PRBChannelConnection: adv - Error advertising peer: %@", error.localizedDescription);
    
    isAdvertising = NO;
    
    //Attempt to start advertising again later
    [NSObject cancelPreviousPerformRequestsWithTarget:_advertiser selector:@selector(startAdvertisingPeer) object:nil];
    [_advertiser performSelector:@selector(startAdvertisingPeer) withObject:nil afterDelay:kRetryTime];
}

#pragma mark - browser

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if(_advertiser && _advertiser.discoveryInfo && [_advertiser.discoveryInfo objectForKey:kPRBChannelNumber])
    {
        NSString *channelStr = [_advertiser.discoveryInfo objectForKey:kPRBChannelNumber];
        
        if(channelStr.length > 0)
        {
            //Check for channel
            if(info && [info objectForKey:kPRBChannelNumber])
            {
                NSString* peerChannelStr = [info objectForKey:kPRBChannelNumber];
                
                if([peerChannelStr isEqualToString:channelStr])
                {
                    CHLog(@"PRBChannelConnection: browser - Found peer '%@' on channel '%@'", peerID.displayName, peerChannelStr);
                    
                    //Refuse if they should be the client
                    CHLog(@"BR PEER-ID: %li , THIS PEER: %li", (long)peerID.hash, (long)_advertiser.myPeerID.hash);
                    
                    if(peerID.hash > _advertiser.myPeerID.hash)
                    {
                        CHLog(@"PRBChannelConnection: browser - Peer should be client - no connect: %@", peerID.displayName);
                        
//                        if(![_sessionAdvertise.connectedPeers containsObject:peerID])
//                        {
//                            [_advertiser stopAdvertisingPeer];
//                            [_advertiser startAdvertisingPeer];
//                        }
                        return;
                    }
                    
                    //Connect - max 30 seconds timeout by default - no context needed
                    [Flurry logEvent:@"Peer connect request b"];
                    CHLog(@"Inviting peer to connect: %@", peerID.displayName);
                    [browser invitePeer:peerID toSession:_sessionBrowse withContext:nil timeout:0];
                }
                else
                {
                    CHLog(@"PRBChannelConnection: browser - Ignoring peer '%@' on channel '%@'", peerID.displayName, peerChannelStr);
                }
            }
            else
            {
                CHLog(@"PRBChannelConnection: browser - Error peer channel is nil");
            }
        }
        else
        {
            CHLog(@"PRBChannelConnection: browser - Error adv channel is nil");
        }
    }
    else
    {
        CHLog(@"PRBChannelConnection: browser - Error getting channel from adv.");
    }
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    //Do nothing - no change to UI
    CHLog(@"PRBChannelConnection: browser lost peer: %@", peerID.displayName);
}

// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    CHLog(@"PRBChannelConnection: Error browsing for peers: %@", error.localizedDescription);
    
    isBrowsing = NO;
    
    //start browsing after delay
    [NSObject cancelPreviousPerformRequestsWithTarget:_browser selector:@selector(startBrowsingForPeers) object:nil];
    [_browser performSelector:@selector(startBrowsingForPeers) withObject:nil afterDelay:kRetryTime];
}

#pragma mark - session

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(session == _sessionBrowse)CHLog(@"Browse session: state");
    else CHLog(@"Adv session: state");
    
    switch (state) {
        case MCSessionStateConnected:
        {
             CHLog(@"PRBChannelConnection: Peer connected: %@", peerID.displayName);
            [Flurry logEvent:@"Peer connected"];
            
            //Inform UI of connection
            if(_delegate && [_delegate respondsToSelector:@selector(connectedToUserWithID:)])
            {
                [_delegate connectedToUserWithID:peerID.hash];
            }
        }
            break;
        case MCSessionStateConnecting:
        {
            //Do nothing in this state
            CHLog(@"PRBChannelConnection: Peer connecting: %@", peerID.displayName);
        }
            break;
        case MCSessionStateNotConnected:
        {
            
            CHLog(@"PRBChannelConnection: Peer disconnected: %@", peerID.displayName);
            
            //Inform UI of connection
            if(_delegate && [_delegate respondsToSelector:@selector(disconnectedFromUserWithID:)])
            {
                [_delegate disconnectedFromUserWithID:peerID.hash];
            }
        }
            break;
            
        default:
            break;
    }
}

// Received data from remote peer - pass to UI
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    CHLog(@"**** INCOMING! ****");
    
    if(session == _sessionBrowse)CHLog(@"Browse session: received data");
    else CHLog(@"Adv session: received data");
    
    if(data && data.length > 0)
    {
        NSDictionary* dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if([dict objectForKey:kPRBMorse])
        {
            NSString *morse = [dict objectForKey:kPRBMorse];
            NSNumber *freqNum = [dict objectForKey:kPRBFreq];
            
            //Pass Morse to UI for peer
            if(_delegate && [_delegate respondsToSelector:@selector(userWithID:didSendMorse:withFrequency:)])
            {
                double freq = 0.0f;
                if(freqNum) freq = freqNum.doubleValue;
                [_delegate userWithID:peerID.hash didSendMorse:morse withFrequency:freq];
            }
        }
        else if([dict objectForKey:kPRBLetter])
        {
            NSString *letter = [dict objectForKey:kPRBLetter];
            
            //Pass Morse to UI for peer
            if(_delegate && [_delegate respondsToSelector:@selector(userWithID:didSendLetter:)])
            {
                [_delegate userWithID:peerID.hash didSendLetter:letter];
            }
        }
    }
}


/* UNUSED! */
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    CHLog(@"PRBChannelConnection: Error - peer sending stream!");
}
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    CHLog(@"PRBChannelConnection: Error - peer sending resource!");
}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    CHLog(@"PRBChannelConnection: Error - peer sent resource!");
}
/* END UNUSED! */



#pragma mark - transmission

-(void)sendMorseToChannel:(NSString*)morse
{
    NSNumber *freqNum = [NSNumber numberWithDouble:[PRBToneController sharedToneController].currentToneFrequency];
    
    NSDictionary* payloadDict = @{kPRBMorse: morse, kPRBFreq: freqNum};
    [self sendDictionary:payloadDict];
}

-(void)sendLetterToChannel:(NSString*)letter
{
    NSDictionary* payloadDict = @{kPRBLetter: letter};
    [self sendDictionary:payloadDict];
}

-(void)sendDictionary:(NSDictionary*)dict{
    
    NSData* payload = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    NSError *err = nil;
    
    BOOL success = NO;
    
    //Send to browser peers
    if(_sessionBrowse.connectedPeers.count > 0)
    {
        success = [_sessionBrowse sendData:payload toPeers:_sessionBrowse.connectedPeers withMode:MCSessionSendDataReliable error:&err];
        
        if(!success || err)
        {
            CHLog(@"PRBChannelConnection: Error sending data to browse peers: %@", err.localizedDescription);
        }
        
        err = nil;
    }
    
    //Send to advertiser peers
    if(_sessionAdvertise.connectedPeers.count > 0)
    {
        success = [_sessionAdvertise sendData:payload toPeers:_sessionAdvertise.connectedPeers withMode:MCSessionSendDataReliable error:&err];
        
        if(!success || err)
        {
            CHLog(@"PRBChannelConnection: Error sending data to Adv peers: %@", err.localizedDescription);
        }
    }
}

@end
