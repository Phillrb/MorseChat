//
//  PRBChatterTableViewCell.m
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

#import "PRBChatterTableViewCell.h"
#import "PRBMorseBannerView.h"

@interface PRBChatterTableViewCell()

@property(nonatomic,strong) PRBMorseBannerView* banner;

@end

@implementation PRBChatterTableViewCell

#define kCellHeight 40.0f
#define kMorseDictMorse @"kMorseDictMorse"
#define kMorseDictLetter @"kMorseDictLetter"

//#define CTLog(...) NSLog(__VA_ARGS__)
#define CTLog(...)

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self)
    {
        [self setup:self.frame.size.width];
    }

return self;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier initialWidth:(float)width{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        [self setup:width];
    }
    
    return self;
}

-(void)setup:(float)width{
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    //Create a generic banner view
    _banner = [[PRBMorseBannerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, kCellHeight)];
    [self addSubview:_banner];
}

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)addMorse:(NSString*)morse
{
    if(_banner)
    {
        [_banner appendMorse:morse];
    }
}
-(void)addLetter:(NSString*)letter
{
    if(_banner)
    {
        [_banner appendLetter:letter];
    }
}

-(void)resizeBanner:(float)width
{
    [_banner setFrame:CGRectMake(_banner.bounds.origin.x, _banner.bounds.origin.y, width, _banner.bounds.size.height)];
}

-(void)updateWithChatHistory:(NSArray*)chatHistory
{
    [_banner clear];
    
    CTLog(@"PRB Populating banner: %@", chatHistory);
    for (NSDictionary* dict in chatHistory)
    {
        CTLog(@"DICT: %@", dict);
        
        NSString* morseStr = [dict objectForKey:kMorseDictMorse];
        NSString* letterStr = [dict objectForKey:kMorseDictLetter];
        
        if(morseStr)
        {
            CTLog(@"* APPENDING MORSE TO BANNER: %@", morseStr);
            [_banner appendMorse:morseStr];
        }
        
        if(letterStr)
        {
            CTLog(@"* APPENDING LETTER TO BANNER: %@", letterStr);
            [_banner appendLetter:letterStr];
        }
        
    }
}

-(void)setMorseSeparatorColor:(UIColor*)newColor
{
    [_banner setMorseSeparatorColor:newColor];
}

@end
