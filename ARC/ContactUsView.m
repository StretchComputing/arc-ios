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
#import "ArcAppDelegate.h"

@interface ContactUsView ()

@end

@implementation ContactUsView






-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
}

- (void)viewDidLoad
{

    @try {
        
        
        [rSkybox addEventToSession:@"viewContactUsPage"];
        
        SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Contact Us"];
        self.navigationItem.titleView = navLabel;
        
        SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Contact Us"];
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
        //630-215-6979
        //support@arcmobileapp.com
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *phoneNumber = @"";
        NSString *emailAddress = @"";
        
        if (![prefs valueForKey:@"arcPhoneNumber"]) {
            [prefs setValue:@"630-215-6979" forKey:@"arcPhoneNumber"];
        }
        
        if (![prefs valueForKey:@"arcMail"]) {
            [prefs setValue:@"support@arcmobileapp.com" forKey:@"arcMail"];
        }
        
        phoneNumber = [NSString stringWithFormat:@"Phone #: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"arcPhoneNumber"]];
        emailAddress = [NSString stringWithFormat:@"Email: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"]];
        
       
        self.phoneNumberLabel.text = phoneNumber;
        self.emailAddressLabel.text = emailAddress;
        
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
            
            NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcPhoneNumber"];
            
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];



            NSString *url = [@"tel://" stringByAppendingString:phoneNumber];
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
            [mailViewController setToRecipients:@[[[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"]]];
            
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

-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}

@end
