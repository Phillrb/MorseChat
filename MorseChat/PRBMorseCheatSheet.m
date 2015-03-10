//
//  PRBMorseCheatSheet.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 15/09/2014.
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

#import "PRBMorseCheatSheet.h"
#import "PRBMorseOutputCollectionViewCell.h"

@interface PRBMorseCheatSheet()

@property(strong, nonatomic) NSArray* morseItems;

@end

@implementation PRBMorseCheatSheet

#define kMorseDictMorse @"kMorseDictMorse"
#define kMorseDictLetter @"kMorseDictLetter"

static NSString * const reuseIdentifier = @"PRBMorseOutputCell";

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

-(void)setup
{
    _morseItems = @[
                        @{kMorseDictLetter: @"a", kMorseDictMorse: @".-"},
                        @{kMorseDictLetter: @"b", kMorseDictMorse: @"-..."},
                        @{kMorseDictLetter: @"c", kMorseDictMorse: @"-.-."},
                        @{kMorseDictLetter: @"d", kMorseDictMorse: @"-.."},
                        @{kMorseDictLetter: @"e", kMorseDictMorse: @"."},
                        @{kMorseDictLetter: @"f", kMorseDictMorse: @"..-."},
                        @{kMorseDictLetter: @"g", kMorseDictMorse: @"--."},
                        @{kMorseDictLetter: @"h", kMorseDictMorse: @"...."},
                        @{kMorseDictLetter: @"i", kMorseDictMorse: @".."},
                        @{kMorseDictLetter: @"j", kMorseDictMorse: @".---"},
                        @{kMorseDictLetter: @"k", kMorseDictMorse: @"-.-"},
                        @{kMorseDictLetter: @"l", kMorseDictMorse: @".-.."},
                        @{kMorseDictLetter: @"m", kMorseDictMorse: @"--"},
                        @{kMorseDictLetter: @"n", kMorseDictMorse: @"-."},
                        @{kMorseDictLetter: @"o", kMorseDictMorse: @"---"},
                        @{kMorseDictLetter: @"p", kMorseDictMorse: @".--."},
                        @{kMorseDictLetter: @"q", kMorseDictMorse: @"--.-"},
                        @{kMorseDictLetter: @"r", kMorseDictMorse: @".-."},
                        @{kMorseDictLetter: @"s", kMorseDictMorse: @"..."},
                        @{kMorseDictLetter: @"t", kMorseDictMorse: @"-"},
                        @{kMorseDictLetter: @"u", kMorseDictMorse: @"..-"},
                        @{kMorseDictLetter: @"v", kMorseDictMorse: @"...-"},
                        @{kMorseDictLetter: @"w", kMorseDictMorse: @".--"},
                        @{kMorseDictLetter: @"x", kMorseDictMorse: @"-..-"},
                        @{kMorseDictLetter: @"y", kMorseDictMorse: @"-.--"},
                        @{kMorseDictLetter: @"z", kMorseDictMorse: @"--.."},
                        
                        @{kMorseDictLetter: @"1", kMorseDictMorse: @".----"},
                        @{kMorseDictLetter: @"2", kMorseDictMorse: @"..---"},
                        @{kMorseDictLetter: @"3", kMorseDictMorse: @"...--"},
                        @{kMorseDictLetter: @"4", kMorseDictMorse: @"....-"},
                        @{kMorseDictLetter: @"5", kMorseDictMorse: @"....."},
                        @{kMorseDictLetter: @"6", kMorseDictMorse: @"-...."},
                        @{kMorseDictLetter: @"7", kMorseDictMorse: @"--..."},
                        @{kMorseDictLetter: @"8", kMorseDictMorse: @"---.."},
                        @{kMorseDictLetter: @"9", kMorseDictMorse: @"----."},
                        @{kMorseDictLetter: @"0", kMorseDictMorse: @"-----"}
                    ];
    
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _morseItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PRBMorseOutputCollectionViewCell  *cell = (PRBMorseOutputCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //Update text
    NSDictionary* morseDict = [_morseItems objectAtIndex:indexPath.row];
    if(morseDict)
    {
        NSString* morseLetterStr = [morseDict objectForKey:kMorseDictLetter];
        [cell.morseTranslationLabel setText: morseLetterStr ? morseLetterStr : @""];
        
        NSString* morseStr = [morseDict objectForKey:kMorseDictMorse];
        [cell.morseLabel setText: morseStr ? morseStr : @""];
    }
    
    
    return cell;
}



@end
