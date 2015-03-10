//
//  PRBIncomingChatterViewController.mm
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 18/09/2014.
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

#import "PRBIncomingChatterViewController.h"
#import "PRBChatterTableViewCell.h"
#import "PRBChatterDataController.h"
#import "PRBToneController.h"
#import <pthread.h>
#include "common.h"

typedef NS_ENUM(NSUInteger, PRBUserColor) {
    PRBUserColorRedColor,
    PRBUserColorGreenColor,
    PRBUserColorBlueColor,
    PRBUserColorCyanColor,
    PRBUserColorYellowColor,
    PRBUserColorMagentaColor,
    PRBUserColorOrangeColor,
    PRBUserColorPurpleColor,
    PRBUserColorBrownColor
};

@interface PRBIncomingChatterViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) UITableView *chatterTable;
@property(nonatomic, strong) PRBChatterDataController *dataController;
@property(nonatomic, retain) NSMutableDictionary *userTone;
@property(nonatomic, retain) NSMutableDictionary *userColor;
@property(nonatomic, assign) NSInteger userColorPos;

@end

//#define ILog(...) NSLog(__VA_ARGS__)
#define ILog(...)

pthread_mutex_t table_mutex;

@implementation PRBIncomingChatterViewController

#pragma mark - mutext on table refresh
-(void)prepareMutex{
//    pthread_mutex_init(&table_mutex, NULL);
}

-(void)lock{
    MLog(@"T+");
//    pthread_mutex_lock(&table_mutex);
}

-(void)unlock{
    MLog(@"T-");
//    pthread_mutex_unlock(&table_mutex);
}

#pragma mark - setup
-(void)setupViewWithFrame:(CGRect)frame{
    
[self prepareMutex];
    
    //Prepare noise makers!
    _userTone = [[NSMutableDictionary alloc] init];
    _userColor = [[NSMutableDictionary alloc] init];
    
    //Setup data
    _dataController = [[PRBChatterDataController alloc] init];
    
    //Create table
    _chatterTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [_chatterTable setUserInteractionEnabled:NO];
    [_chatterTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_chatterTable setBackgroundColor:[UIColor clearColor]];
    [_chatterTable setDataSource:self];
    [_chatterTable setDelegate:self];
    [self setView:_chatterTable];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [_chatterTable reloadData];
    }];
    
    [_chatterTable reloadData];
    
   // [self performSelector:@selector(testUser1) withObject:nil afterDelay:1.5];
   // [self performSelector:@selector(testUser2) withObject:nil afterDelay:1.0];
   // [self performSelector:@selector(testUser3) withObject:nil afterDelay:1.4];
   // [self performSelector:@selector(testUser4) withObject:nil afterDelay:2.6];
    
}

/*
#define testUserID 123456789
#define testUser2ID 123456788
#define testUser3ID 123456787
#define testUser1Tone 2500
#define testUser2Tone 3000
#define testUser3Tone 3000
#define testUser4Tone 3000
-(void)go{
[self userWithID:testUserID didSendLetter:@" "];
}

-(void)testUser1{
    [self connectedToUserWithID:testUserID];
    [self userWithID:testUserID didSendMorse:@"...." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"h"];
    [self userWithID:testUserID didSendMorse:@"." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"e"];
    [self userWithID:testUserID didSendMorse:@"-.--" withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"y"];
    [self userWithID:testUserID didSendMorse:@"--" withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"m"];
    [self userWithID:testUserID didSendMorse:@"--..." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"8"];
    [self userWithID:testUserID didSendMorse:@"--." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"g"];
    [self userWithID:testUserID didSendMorse:@".-." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"r"];
    [self userWithID:testUserID didSendMorse:@"--..." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"8"];
    [self userWithID:testUserID didSendMorse:@".-" withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"a"];
    [self userWithID:testUserID didSendMorse:@".--." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"p"];
    [self userWithID:testUserID didSendMorse:@".--." withFrequency:testUser1Tone];
    [self userWithID:testUserID didSendLetter:@"p"];
}

-(void)testUser2{
    [self connectedToUserWithID:testUser2ID];
    [self userWithID:testUser2ID didSendMorse:@"-.-." withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"c"];
    [self userWithID:testUser2ID didSendMorse:@"---" withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"o"];
    [self userWithID:testUser2ID didSendMorse:@"---" withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"o"];
    [self userWithID:testUser2ID didSendMorse:@".-.." withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"l"];
    [self userWithID:testUser2ID didSendMorse:@"-" withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"t"];
    [self userWithID:testUser2ID didSendMorse:@"-..-" withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"x"];
    [self userWithID:testUser2ID didSendMorse:@"-" withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"t"];
    [self userWithID:testUser2ID didSendMorse:@"..." withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"s"];
    [self userWithID:testUser2ID didSendMorse:@".--." withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"p"];
    [self userWithID:testUser2ID didSendMorse:@"-.-" withFrequency:testUser2Tone];
    [self userWithID:testUser2ID didSendLetter:@"k"];
}

-(void)testUser3{
    [self connectedToUserWithID:testUser3ID];
    [self userWithID:testUser3ID didSendMorse:@"--" withFrequency:testUser2Tone];
    [self userWithID:testUser3ID didSendLetter:@"m"];
    [self userWithID:testUser3ID didSendMorse:@"---" withFrequency:testUser2Tone];
    [self userWithID:testUser3ID didSendLetter:@"o"];
    [self userWithID:testUser3ID didSendMorse:@".-." withFrequency:testUser2Tone];
    [self userWithID:testUser3ID didSendLetter:@"r"];
    [self userWithID:testUser3ID didSendMorse:@"..." withFrequency:testUser2Tone];
    [self userWithID:testUser3ID didSendLetter:@"s"];
    [self userWithID:testUser3ID didSendMorse:@"." withFrequency:testUser2Tone];
    [self userWithID:testUser3ID didSendLetter:@"e"];
//    [self userWithID:testUser3ID didSendMorse:@"---" withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"o"];
//    [self userWithID:testUser3ID didSendMorse:@"..-." withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"f"];
//    [self userWithID:testUser3ID didSendMorse:@"-.-." withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"c"];
//    [self userWithID:testUser3ID didSendMorse:@"---" withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"o"];
//    [self userWithID:testUser3ID didSendMorse:@"..-" withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"u"];
//    [self userWithID:testUser3ID didSendMorse:@".-." withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"r"];
//    [self userWithID:testUser3ID didSendMorse:@"..." withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"s"];
//    [self userWithID:testUser3ID didSendMorse:@"." withFrequency:testUser2Tone];
//    [self userWithID:testUser3ID didSendLetter:@"e"];
}

//-(void)testUser4{
//    [self connectedToUserWithID:testUser4ID];
////    [self userWithID:testUser4ID didSendMorse:@"-.." withFrequency:testUser4Tone];
////    [self userWithID:testUser4ID didSendLetter:@"d"];
////    [self userWithID:testUser4ID didSendMorse:@"---" withFrequency:testUser4Tone];
////    [self userWithID:testUser4ID didSendLetter:@"o"];
////    [self userWithID:testUser4ID didSendMorse:@"-" withFrequency:testUser4Tone];
////    [self userWithID:testUser4ID didSendLetter:@"t"];
//    [self userWithID:testUser4ID didSendMorse:@"-.." withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"d"];
//    [self userWithID:testUser4ID didSendMorse:@"---" withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"o"];
//    [self userWithID:testUser4ID didSendMorse:@"-" withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"t"];
//    [self userWithID:testUser4ID didSendMorse:@"-.." withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"d"];
//    [self userWithID:testUser4ID didSendMorse:@".-" withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"a"];
//    [self userWithID:testUser4ID didSendMorse:@"..." withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"s"];
//    [self userWithID:testUser4ID didSendMorse:@"...." withFrequency:testUser4Tone];
//    [self userWithID:testUser4ID didSendLetter:@"h"];
//[self performSelector:@selector(go) withObject:nil afterDelay:0.01f];
//}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clear{
    
    //Remove all rows
    [_dataController clear];
    [self refreshTable];
}


#pragma mark - incoming
-(void)connectedToUserWithID:(NSInteger)userID
{
    //Add user to array
    [_dataController addUserID:userID];
    [self createTonePlayerForUserID:userID];
    [self addUserColorForUserID:userID];
    
    [_bar performSelectorOnMainThread:@selector(peerConnected) withObject:nil waitUntilDone:NO];
    
    [self refreshTable];
}

-(void)disconnectedFromUserWithID:(NSInteger)userID
{
    //Remove user
    [_dataController removeUserID:userID];
    [self removeTonePlayerForUserID:userID];
    [self removeColorForUserID:userID];
    
    [_bar performSelectorOnMainThread:@selector(peerDropped) withObject:nil waitUntilDone:NO];
    
    [self refreshTable];
}

-(void)connectingToUserWithID:(NSInteger)userID
{
    [_bar performSelectorOnMainThread:@selector(peerConnecting) withObject:nil waitUntilDone:NO];
}

-(void)startingToSearch{
    [_bar performSelectorOnMainThread:@selector(startedSearchingForPeers) withObject:nil waitUntilDone:NO];
}


-(void)createTonePlayerForUserID:(NSInteger)userID{
    
    PRBToneController* userToneController = [[PRBToneController alloc] init];
    [[PRBToneController sharedToneController] manageController:userToneController];
    [_userTone setObject:userToneController forKey:[NSNumber numberWithInteger:userID]];
}

-(void)removeTonePlayerForUserID:(NSInteger)userID{
    
    NSNumber* num = [NSNumber numberWithInteger:userID];
    
    PRBToneController* controller = [_userTone objectForKey:num];
    
    if(controller)
    {
        [controller cleanup];
        [_userTone removeObjectForKey:num];
    }
}

-(void)addUserColorForUserID:(NSInteger)userID{
    
    if(![_userColor objectForKey:[NSNumber numberWithInteger:userID]])
    {
        [self createColorForUserID:userID];
    }
}

-(void)createColorForUserID:(NSInteger)userID{
    
    NSNumber* num = [NSNumber numberWithInteger:userID];
    UIColor *color = [self nextUserColor];
    [_userColor setObject:color forKey:num];
}

-(void)removeColorForUserID:(NSInteger)userID{
    NSNumber* num = [NSNumber numberWithInteger:userID];
    [_userColor removeObjectForKey:num];
}

-(void)userWithID:(NSInteger)userID didSendMorse:(NSString*)morse withFrequency:(double)frequency
{
    ILog(@"UPDATE USER '%li' with morse '%@'",(long)userID, morse);
    
    //Add morse to history
    [_dataController saveMorse:morse forUserID:userID];
    [self playToneForMorse:morse forUserID:userID withFrequency:frequency];
    
    //Refresh visible cells
    [self refreshTable];
}

-(void)userWithID:(NSInteger)userID didSendLetter:(NSString*)letter
{
    //Add morse to history
    [_dataController saveLetter:letter forUserID:userID];
    
    //Refresh visible cells
    [self refreshTable];
}

-(void)playToneForMorse:(NSString*)morse forUserID:(NSInteger)userID withFrequency:(double)frequency
{
    
    if(morse.length <= 0 || [morse isEqualToString:@" "]) return;
    
    PRBToneController* toneController = [_userTone objectForKey:[NSNumber numberWithInteger:userID]];
    
    if(toneController)
    {
        //Set frequency
        if (frequency > 0) {
            [toneController setToneFrequency:frequency];
        }
        
        //Play tone
        if ([morse isEqualToString:@"-"])
        {
            [toneController dashTone];
        }
        else if ([morse isEqualToString:@"."])
        {
            [toneController dotTone];
        }
    }
    
}

#pragma mark - Tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger users = [_dataController numberOfUsers];
    ILog(@"TABLE HAS %li rows", (long)users);
    return users;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ILog(@"REFRESHING CELL FOR %li", (long)indexPath.row);
    static NSString* cellId = @"cell";
    
    PRBChatterTableViewCell* cell = (PRBChatterTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell)
    {
        cell = [[PRBChatterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    //Get userID
    NSInteger userID = [_dataController userIDAtPos:indexPath.row];
    
    ILog(@"UPDATING CELL");
    [cell resizeBanner:tableView.bounds.size.width];
    [cell setUserIDNum:[NSNumber numberWithInteger:userID]];
    if(userID != 0)
    {
        NSArray *userChat = [_dataController chatForUserID:userID];
        if(userChat)
        {
            NSArray* userChatCopy = [userChat copy];
            [cell updateWithChatHistory: userChatCopy];
        }
    }
    [cell setMorseSeparatorColor:[_userColor objectForKey:[NSNumber numberWithInteger:userID]]];
    
    return cell;
}


-(void)refreshTable{
//[self lock];

    [_chatterTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
//[self unlock];
}

-(UIColor*)nextUserColor{
    
    UIColor *color;
    
    switch (_userColorPos) {
        case PRBUserColorRedColor:
            color = [UIColor redColor];
            break;
        case  PRBUserColorGreenColor:
            color = [UIColor greenColor];
            break;
            
        case PRBUserColorBlueColor:
            color = [UIColor blueColor];
            break;
            
        case PRBUserColorCyanColor:
            color = [UIColor cyanColor];
            break;
            
        case PRBUserColorYellowColor:
            color = [UIColor yellowColor];
            break;
            
        case PRBUserColorMagentaColor:
            color = [UIColor magentaColor];
            break;
            
        case PRBUserColorOrangeColor:
            color = [UIColor orangeColor];
            break;
            
        case PRBUserColorPurpleColor:
            color = [UIColor purpleColor];
            break;
            
        case PRBUserColorBrownColor:
            color = [UIColor brownColor];
            break;
            
        default:
        {
            _userColorPos = PRBUserColorRedColor;
            color = [UIColor redColor];
        }
            break;
    }
    
    
    //increment
    _userColorPos++;
    
    //Go to start if needed
    if(_userColorPos > PRBUserColorBrownColor)
    {
        _userColorPos = PRBUserColorRedColor;
    }
    
    return color;
}

@end
