//
//  ContactUsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ContactUsView.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "ArcClient.h"

@interface ContactUsView ()

@end

@implementation ContactUsView



- (void)viewDidLoad
{

    @try {
        
        
        [rSkybox addEventToSession:@"viewContactUsPage"];
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Contact Us"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Contact Us"];
		self.navigationItem.backBarButtonItem = temp;
        
        
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
        
        [ArcClient trackEvent:@"CONTACT_US_VIEW"];

    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ContactUsView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)call {
    @try {
        
        [rSkybox addEventToSession:@"phoneCallToArc"];
        
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]){
            
            
            NSString *url = [@"tel://" stringByAppendingString:@"6302156979"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            
            
        }else {
            
            NSString *message1 = @"You cannot make calls from this device.";
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:message1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert1 show];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ContactUsView.call" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)email {
    @try {
        
        [rSkybox addEventToSession:@"emailToArc"];
        
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            [mailViewController setToRecipients:@[@"tdoza33@gmail.com"]];
            
            [self presentModalViewController:mailViewController animated:YES];
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ContactUsView.email" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    @try {
        
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
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ContactUsView.mailComposeController" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end
