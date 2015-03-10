//
//  PRBMorseBannerView.m
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

#import "PRBMorseBannerView.h"
#import "PRBMorseOutputCollectionViewCell.h"

@interface PRBMorseBannerView()
@property(nonatomic, strong) IBOutlet UICollectionView *morseCollectionView;
@property(strong, nonatomic) NSMutableArray* morseItems;
@property(nonatomic, strong) UIColor* separatorColor;

@end

@implementation PRBMorseBannerView

static NSString * const reuseIdentifier = @"PRBMorseOutputCell";

#define kCellWidth 40.0f
#define kMorseCollectionViewTag 2000
#define kMorseDictMorse @"kMorseDictMorse"
#define kMorseDictLetter @"kMorseDictLetter"

//#define BLog(...) NSLog(__VA_ARGS__)
#define BLog(...)

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
        [self makeCollectionView];
    }
    
    return self;
}

-(void)setup
{
    _morseItems = [[NSMutableArray alloc] init];
    _separatorColor = [UIColor blueColor];
}

-(void)makeCollectionView{
    
    //Need a collection view?
    if(!_morseCollectionView)
    {
        BLog(@"CREATING COLLECTION VIEW");
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _morseCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [layout setItemSize:[PRBMorseOutputCollectionViewCell cellSize]];
        [layout setMinimumInteritemSpacing:0.0f];
        [layout setMinimumLineSpacing:0.0f];
        
        [_morseCollectionView setBackgroundColor:[UIColor clearColor]];
        [_morseCollectionView registerClass:[PRBMorseOutputCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        [_morseCollectionView setDelegate:self];
        [_morseCollectionView setDataSource:self];
        [self addSubview:_morseCollectionView];
        
        [_morseCollectionView setContentInset:UIEdgeInsetsMake(0.0f, _morseCollectionView.frame.size.width - kCellWidth, 0.0f, 0.0f)];
    }

}


-(void)layoutSubviews
{
    [super layoutSubviews];

    [_morseCollectionView setFrame:CGRectMake(_morseCollectionView.frame.origin.x, _morseCollectionView.frame.origin.y, self.frame.size.width, _morseCollectionView.frame.size.height)];
    [_morseCollectionView setContentInset:UIEdgeInsetsMake(0.0f, self.frame.size.width - kCellWidth, 0.0f, 0.0f)];
}

-(void)appendLetter:(NSString*)letter
{
    BLog(@"APPENDING LETTER TO BANNER: %@", letter);
    
    if(!letter || [letter isEqualToString:@""]) return;
    
    if([letter isEqualToString:@" "])
    {
        //Check there is no letter in last morse
        if([_morseItems lastObject] && ![[_morseItems lastObject] objectForKey:kMorseDictLetter] && [[_morseItems lastObject] objectForKey:kMorseDictMorse])
        {
            //Clear morse - it was invalid!
            [[_morseItems lastObject] removeObjectForKey:kMorseDictMorse];
            [self refreshMorseScroll];
        }
        
        // space char does nothing else!
        return;
    }
    
    NSMutableDictionary* morseDict = nil;

    //Check if last entry complete
    if(_morseItems.count > 0)
    {
        NSMutableDictionary *lastMorseDict = [_morseItems lastObject];
        
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
                [_morseItems addObject:morseDict];
            }
        }
        else
        {
            //Insert entry
            morseDict = [NSMutableDictionary dictionary];
            [_morseItems insertObject:morseDict atIndex:_morseItems.count - 1];
        }
    }
    else
    {
        //Create new entry
        morseDict = [NSMutableDictionary dictionary];
        [_morseItems addObject:morseDict];
    }
    
    if(morseDict)
    {
        [morseDict setObject:letter forKey:kMorseDictLetter];
        
        //Refresh morseCollectionView
        BLog(@"REFRESH!!");
        [self refreshMorseScroll];
    }
    else
    {
        BLog(@"Error: Morse Dict missing!");
    }
}

-(void)appendMorse:(NSString*)morseChar
{
    
    BLog(@"$$$$$$ APPENDING MORSE TO BANNER: %@", morseChar);
    
    //Identical to PRBChatterDataController 'saveMorse:forUserID:'
    
    if(!_morseItems)
    {
        BLog(@"****** FUNKY MORSE ITEMS");
    }
        
    NSMutableDictionary* morseDict = [_morseItems lastObject];
    
    if(!morseDict)
    {
        BLog(@"NO MORSE DICT; CREATING NEW");
        morseDict = [[NSMutableDictionary alloc] init];
        BLog(@"ADDING TO CHAT ITEMS");
        [_morseItems addObject:morseDict];
    }
    else
    {
        BLog(@"FOUND MORSE DICT");
        if([morseDict objectForKey:kMorseDictLetter])
        {
            BLog(@"FOUND LETTER... CREATING NEW LAST MORSE DICT");
            
            //Create new morseDict! Another letter is being formed
            morseDict = [[NSMutableDictionary alloc] init];
            
            BLog(@"ADDING TO CHAT ITEMS");
            [_morseItems addObject:morseDict];
        }
    }
    
    BLog(@"GETTING MORSE TEXT");
    NSMutableString *morseText = [morseDict objectForKey:kMorseDictMorse];
    
    if(!morseText)
    {
        BLog(@"NO TEXT: INIT NEW WITH MORSE: '%@'", morseChar);
        morseText = [NSMutableString stringWithString:morseChar];
        
        BLog(@"ADDING TEXT TO MORSE DICT");
        [morseDict setObject:morseText forKey:kMorseDictMorse];
    }
    else
    {
        BLog(@"FOUND TEXT AND APPENDING: '%@'", morseChar );
        [morseText appendString:morseChar];
        BLog(@"TEXT IS NOW '%@'", morseText);
    }
    
    BLog(@"REQUESTING REFRESH OF COLLECTION VIEW");
    [self refreshMorseScroll];
    

}

-(void)clear
{
    [_morseItems removeAllObjects];
    [_morseCollectionView reloadData];
}


-(void)refreshMorseScroll{
    
    BLog(@"COLLECTION VIEW RELOAD");
    [_morseCollectionView reloadData];

    BLog(@"COLLECTION SCROLL: %li", (long)_morseItems.count);
    [_morseCollectionView scrollRectToVisible:CGRectMake( _morseCollectionView.contentSize.width - 1, 0.0f, 1, 1)  animated:YES];
}

-(void)setMorseSeparatorColor:(UIColor*)newColor
{
    _separatorColor = newColor;
    
    NSArray* visCells = [NSArray arrayWithArray:_morseCollectionView.visibleCells];
    for(PRBMorseOutputCollectionViewCell* cell in visCells)
    {
        if (cell) {
            [cell.separator setBackgroundColor:_separatorColor];
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    BLog(@"COLLECTION ITEMS: %li", (long)_morseItems.count);
    return _morseItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PRBMorseOutputCollectionViewCell *cell = (PRBMorseOutputCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    BLog(@"FETCHING CELL: %li", (long)indexPath.row);
    
    //Update text
    NSDictionary* morseDict = [_morseItems objectAtIndex:indexPath.row];
    if(morseDict)
    {
        NSString* morseLetterStr = [morseDict objectForKey:kMorseDictLetter];
        if(morseLetterStr) BLog(@"DISPLAYING %@", morseLetterStr);
        [cell.morseTranslationLabel setText: morseLetterStr ? morseLetterStr : @""];
        
        NSString* morseStr = [morseDict objectForKey:kMorseDictMorse];
        if(morseStr) BLog(@"DISPLAYING %@", morseStr);
        [cell.morseLabel setText: morseStr ? morseStr : @""];
    }
    else
    {
        BLog(@"Banner: NO DICT");
    }
    
    [cell.separator setBackgroundColor:_separatorColor];
    
    return cell;
}



@end
