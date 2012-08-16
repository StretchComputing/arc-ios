//
//  ContactUsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactUsView.h"
#import <QuartzCore/QuartzCore.h>

@interface ContactUsView ()

@end

@implementation ContactUsView



- (void)viewDidLoad
{
     self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
	// Do any additional setup after loading the view.
    self.sloganLabel.font = [UIFont fontWithName:@"Chalet-Tokyo" size:20];

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)call {
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]){
        
       
        NSString *url = [@"tel://" stringByAppendingString:@"3125555555"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
          
        
        
    }else {
        
        NSString *message1 = @"You cannot make calls from this device.";
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:message1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        
    }

    
}

- (IBAction)email {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:@[@"info@arc.com"]];
        
        [self presentModalViewController:mailViewController animated:YES];
        
    }else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSent:
            
			break;
		case MFMailComposeResultFailed:
            
			break;
			
		case MFMailComposeResultSaved:
            
			break;
		default:
			
			break;
	}
	
	
	[self dismissModalViewControllerAnimated:YES];
	
}

@end
