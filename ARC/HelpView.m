//
//  HelpView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpView.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"

@interface HelpView ()

@end

@implementation HelpView

- (void)viewDidLoad
{
    [rSkybox addEventToSession:@"viewHelpPage"];
     self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = backView.bounds;
    UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [backView.layer insertSublayer:gradient atIndex:0];
    
    self.tableView.backgroundView = backView;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
@end
