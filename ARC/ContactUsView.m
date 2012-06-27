//
//  ContactUsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactUsView.h"

@interface ContactUsView ()

@end

@implementation ContactUsView



- (void)viewDidLoad
{
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0427221 green:0.380456 blue:0.785953 alpha:1.0];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"info@arc.com"]];
        
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
