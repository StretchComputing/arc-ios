//
//  HomeNavigationController.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeNavigationController.h"

@interface HomeNavigationController ()

@end

@implementation HomeNavigationController


- (void)viewDidLoad
{
     self.navigationBar.tintColor = [UIColor colorWithRed:0.0427221 green:0.380456 blue:0.785953 alpha:1.0];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
