//
//  RegisterNavigation.m
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "RegisterNavigation.h"
#import "rSkybox.h"

@interface RegisterNavigation ()

@end

@implementation RegisterNavigation



- (void)viewDidLoad
{
    @try {
        self.navigationBarHidden = YES;
        self.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        [super viewDidLoad];
        // Do any additional setup after loading the view.
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterNavigation.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)viewDidUnload
{
    @try {
        
        [super viewDidUnload];
        // Release any retained subviews of the main view.
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterNavigation.viewDidUnload" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    @try {
        
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterNavigation.shouldAutorotateToInterfaceOrientation" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end
