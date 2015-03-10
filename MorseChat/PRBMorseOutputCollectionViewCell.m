//
//  PRBMorseOutputCollectionViewCell.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 11/09/2014.
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

#import "PRBMorseOutputCollectionViewCell.h"

@interface PRBMorseOutputCollectionViewCell()

@end

@implementation PRBMorseOutputCollectionViewCell

#define kCellWidth 40.0f
#define kCellHeight 40.0f
#define kSeparatorY 25.0f

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self setup];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //THIS IS SETUP FROM NIB
    }
    return self;
}

-(void)setup
{
    if(!_morseTranslationLabel)
    {
        _morseTranslationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kCellWidth, kCellHeight / 2.0f)];
        [_morseTranslationLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_morseTranslationLabel];
    }
    
    if(!_morseLabel)
    {
        _morseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, kCellHeight / 2.0f, kCellWidth, kCellHeight / 2.0f)];
        [_morseLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_morseLabel];
    }
    
    if(!_separator)
    {
        _separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSeparatorY , kCellWidth, 1.0f)];
        [self addSubview:_separator];
    }
}

-(void)layoutSubviews{
    
    [super layoutSubviews];

    [_morseLabel setAdjustsFontSizeToFitWidth:YES];
}

+(CGSize)cellSize
{
    return CGSizeMake(kCellWidth, kCellHeight);
}

@end
