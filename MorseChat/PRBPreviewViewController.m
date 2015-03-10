//
//  PRBPreviewViewController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 10/10/2014.
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

#import "PRBPreviewViewController.h"
#import "Flurry.h"

@interface PRBPreviewViewController ()

@property(nonatomic, retain) NSArray *printableResources;

@end

@implementation PRBPreviewViewController

#define kPrintablesDir @"printables"
#define kPDF @"pdf"


-(id)init{
    
    self = [super init];
    
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
        [self setup];
    }
    
    return self;
}

-(void)setup{
    
    //Create printable resources
    _printableResources = @[
                            [[NSBundle mainBundle] URLForResource:@"International Morse Code" withExtension:kPDF subdirectory:kPrintablesDir],
                            [[NSBundle mainBundle] URLForResource:@"Morse Code Map" withExtension:kPDF subdirectory:kPrintablesDir],
                            [[NSBundle mainBundle] URLForResource:@"Visual Morse Code" withExtension:kPDF subdirectory:kPrintablesDir]
                            ];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Printables"];
    
    [self setCurrentPreviewItemIndex:0];
    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Preview controller

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return _printableResources.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [_printableResources objectAtIndex:index];
}


@end
