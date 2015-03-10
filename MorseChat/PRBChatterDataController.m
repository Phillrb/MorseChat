//
//  PRBChatterDataController.mm
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 22/09/2014.
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

#import "PRBChatterDataController.h"
#import <pthread.h>
#include "common.h"

@interface PRBChatterDataController ()

@property(nonatomic, retain) NSMutableArray *userArr;
@property(nonatomic, retain) NSMutableDictionary *userChat;

@end

pthread_mutex_t chatter_mutex;

@implementation PRBChatterDataController

#pragma mark - mutext on table refresh
-(void)prepareMutex{
//    pthread_mutex_init(&chatter_mutex, NULL);
}

-(void)lock{
    MLog(@"D+");
//    pthread_mutex_lock(&chatter_mutex);
}

-(void)unlock{
    MLog(@"D-");
//    pthread_mutex_unlock(&chatter_mutex);
}

//#define DLog(...) NSLog(__VA_ARGS__)
#define DLog(...)

#pragma mark - setup
-(id)init{
    
    self = [super init];
    
    if(self)
    {
        [self prepareMutex];
        
        //Setup array
        _userArr = [[NSMutableArray alloc] init];
        _userChat = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
}


#pragma mark - data

-(void)addUserID:(NSInteger)userID{
    
    if(![self containsUserID:userID])
    {
        DLog(@"ADDING: %li", (long)userID);
        [self lock];
        {
            NSNumber * userNum = [NSNumber numberWithInteger:userID];
            [_userArr addObject:userNum];
        }
        [self unlock];
    }
}

-(void)removeUserID:(NSInteger)userID
{
    if([self containsUserID:userID])
    {
        NSNumber* num = [self userIDNumMatchingUserID:userID];
        if(num)
        {
            DLog(@"Removing: %li", (long)userID);
            [self lock];
            {
                [_userArr removeObject:num];
            }
            [self unlock];
        }
    }
}

-(NSInteger)numberOfUsers{
    
    NSInteger noOfUsers = 0;
    
    [self lock];
    {
        noOfUsers = _userArr.count;
    }
    [self unlock];
    
    return noOfUsers;
}

-(NSInteger)userIDAtPos:(NSInteger)pos{
    
    NSInteger userID = 0;
    NSNumber *userIDNum = nil;
    [self lock];
    {
        if(pos < _userArr.count)
        {
            userIDNum = [_userArr objectAtIndex:pos];
        }
    }
    [self unlock];
    
    if(userIDNum) userID = userIDNum.integerValue;
    
    return userID;
}

-(NSMutableArray*)chatForUserID:(NSInteger)userID
{
    NSString* userKey = [self keyForUserID:userID];
    NSMutableArray* morseItems = nil;
    
    [self lock];
        morseItems = [_userChat objectForKey:userKey];
    [self unlock];
    
    if(!morseItems)
    {
        morseItems = [[NSMutableArray alloc] init];
        [self lock];
        {
            [_userChat setObject:morseItems forKey:userKey];
        }
        [self unlock];
    }
    
    DLog(@"Returning %li items", (long)morseItems.count);
    
    
    
    return morseItems;
}

#define kMorseDictMorse @"kMorseDictMorse"
#define kMorseDictLetter @"kMorseDictLetter"

-(void)saveMorse:(NSString*)morse forUserID:(NSInteger)userID
{
    //Identical to PRBMorseBannerView 'appendMorse:'
    
    if(morse.length <= 0 || [morse isEqualToString:@" "]) return;
    
    //Get chat for user
    NSMutableArray* morseItems = [self chatForUserID:userID];
    
    if(!morseItems)
    {
        DLog(@"NO CHAT ITEMS FOR USER");
    }
    
    NSMutableDictionary* morseDict = [morseItems lastObject];
    
    if(!morseDict)
    {
        DLog(@"NO LAST MORSE DICT: CREATING MORSE DICT FOR USER");
        morseDict = [NSMutableDictionary dictionary];
        [self lock];
        {
            DLog(@"ADDING MORSE DICT TO CHAT ITEMS");
            [morseItems addObject:morseDict];
        }
        [self unlock];
    }
    else
    {
        DLog(@"FOUND LAST MORSE DICT");
        
        if([morseDict objectForKey:kMorseDictLetter])
        {
             DLog(@"FOUND LETTER IN LAST MORSE DICT: CREATING NEW LAST ITEM ON END");
            
            //Create new morseDict! Another letter is being formed
            morseDict = [NSMutableDictionary dictionary];
            [self lock];
            {
                DLog(@"ADDING LAST ITEM TO CHAT ITEMS");
                [morseItems addObject:morseDict];
            }
            [self unlock];
        }
    }
    
    
    DLog(@"GETTING MORSE TEXT FROM LAST MORSE DICT");
    NSMutableString *morseText = [morseDict objectForKey:kMorseDictMorse];
    
    if(!morseText)
    {
        DLog(@"NO TEXT OBJECT: INIT NEW WITH MORSE: '%@'", morse);
        morseText = [NSMutableString stringWithString:morse];
        [self lock];
        {
            DLog(@"ADDING TEXT TO MORSE DICT");
            [morseDict setObject:morseText forKey:kMorseDictMorse];
        }
        [self unlock];
    }
    else
    {
        DLog(@"FOUND MORSE TEXT AND APPENDING: %@", morse);
        [morseText appendString:morse];
        DLog(@"MORSE TEXT IS NOW: %@", morseText);
    }
}

-(void)saveLetter:(NSString*)letter forUserID:(NSInteger)userID
{
    //Get chat for user
    NSMutableArray* morseItems = [self chatForUserID:userID];

    if(!letter || [letter isEqualToString:@""]) return;
    
    if([letter isEqualToString:@" "])
    {
        //Check there is no letter in last morse
        if([morseItems lastObject] && ![[morseItems lastObject] objectForKey:kMorseDictLetter] && [[morseItems lastObject] objectForKey:kMorseDictMorse])
        {
            //Clear morse - it was invalid!
            [self lock];
            {
                [[morseItems lastObject] removeObjectForKey:kMorseDictMorse];
            }
            [self unlock];
        }
        
        // space char does nothing else!
        return;
    }
    
    NSMutableDictionary* morseDict = nil;
    
    //Check if last entry complete
    if(morseItems.count > 0)
    {
        NSMutableDictionary *lastMorseDict = [morseItems lastObject];
        
        if(lastMorseDict)
        {
            NSString* lastLeter = [lastMorseDict objectForKey:kMorseDictLetter];
            
            if(!lastLeter || [lastLeter isEqualToString:@""] || [lastLeter isEqualToString:@" "])
            {
                morseDict = lastMorseDict;
            }
            else
            {
                //Create new entry
                morseDict = [NSMutableDictionary dictionary];
                [self lock];
                {
                    [morseItems addObject:morseDict];
                }
                [self unlock];
            }
        }
        else
        {
            //Insert entry
            morseDict = [NSMutableDictionary dictionary];
            [self lock];
            {
                [morseItems insertObject:morseDict atIndex:morseItems.count - 1];
            }
            [self unlock];
        }
    }
    else
    {
        //Create new entry
        morseDict = [NSMutableDictionary dictionary];
        [self lock];
        {
            [morseItems addObject:morseDict];
        }
        [self unlock];
    }
    
    if(morseDict)
    {
        [morseDict setObject:letter forKey:kMorseDictLetter];
    }
    else
    {
        DLog(@"Error: chatter data controller Morse Dict missing!");
    }
}

-(void)clear{
    
    [self lock];
    {
        [_userArr removeAllObjects];
        [_userChat removeAllObjects];
    }
    [self unlock];
}


#pragma mark - internal

-(NSString*)keyForUserID:(NSInteger)userID{
    return [NSString stringWithFormat:@"%li", (long)userID];
}


-(BOOL)containsUserID:(NSInteger)userID{
    NSNumber* num = [self userIDNumMatchingUserID:userID];
    if(num) return YES;
    return NO;
}

-(NSNumber*)userIDNumMatchingUserID:(NSInteger)userID{
[self lock];
    NSNumber* num = nil;
    for (NSNumber* userNum in _userArr) {
        if (userNum.integerValue == userID) {
            num = userNum;
            break;
        }
    }
[self unlock];
    return num;
}


@end
