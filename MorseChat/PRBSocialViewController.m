//
//  PRBSocialViewController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 06/10/2014.
//  Copyright (c) 2014 Phillip Riscombe-Burton. All rights reserved.
//

#import "PRBSocialViewController.h"

@interface PRBSocialViewController ()

@end

@implementation PRBSocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)didSelectPost
{
    UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.textView.text] applicationActivities:nil];
    
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
          [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [self presentViewController:activityVC animated:YES completion:^{
     
    }];

}

- (void)didSelectCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




-(BOOL)prefersStatusBarHidden{
    return YES;
}


@end
