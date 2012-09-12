//
//  SettingsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "SettingsView.h"
#import "ArcAppDelegate.h"
#import "ArcAppDelegate.h"
#import "DwollaAPI.h"
#import "RegisterDwollaView.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"

@interface SettingsView ()

@end

@implementation SettingsView
@synthesize lifetimePointsProgressView;

-(void)viewWillAppear:(BOOL)animated{
    @try {
        
        [self performSelector:@selector(getPointsBalance)];
        
        NSString *dwollaAuthToken = @"";
        @try {
            dwollaAuthToken = [DwollaAPI getAccessToken];
        }
        @catch (NSException *exception) {
            dwollaAuthToken = nil;
        }
        
        if ((dwollaAuthToken == nil) || [dwollaAuthToken isEqualToString:@""]) {
            self.dwollaAuthSwitch.on = NO;
        }else{
            self.dwollaAuthSwitch.on = YES;
        }
        
        if (self.fromDwolla) {
            self.fromDwolla = NO;
            
            NSString *title = @"";
            NSString *message = @"";
            if (self.dwollaSuccess) {
                
                title = @"Success!";
                message = @"Congratulations! You are now authorized for Dwolla!";
                
            }else{
                
                title = @"Authorization Error";
                message = @"You were not successfully authorized for Dwolla.  Please try again";
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
        if (self.creditCardAdded){
            self.creditCardAdded = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your credit card was added successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
        if (self.creditCardDeleted){
            self.creditCardDeleted = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your credit card was deleted successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView:viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

- (void)viewDidLoad
{
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Profile"];
        self.navigationItem.titleView = navLabel;
        
        
        [rSkybox addEventToSession:@"viewSettingsPage"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointBalanceComplete:) name:@"getPointBalanceNotification" object:nil];
        
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        
        
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = backView.bounds;
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [backView.layer insertSublayer:gradient atIndex:0];
        
        self.tableView.backgroundView = backView;
        
        
        self.serverData = [NSMutableData data];
        [super viewDidLoad];
        // Do any additional setup after loading the view.
  }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        
        NSUInteger row = [indexPath row];
        NSUInteger section = [indexPath section];
        
        if ((section == 2) && (row == 0)) {
            
            ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
            mainDelegate.logout = @"true";
            [self.navigationController dismissModalViewControllerAnimated:NO];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)getPointsBalance{
    
    @try{
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:customerId forKey:@"customerId"];
        
        [self.activity startAnimating];

		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getPointBalance:loginDict];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.getPointsBalance" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)pointBalanceComplete:(NSNotification *)notification{
    @try {
        
        [rSkybox addEventToSession:@"pointBalanceComplete"];
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        if ([status isEqualToString:@"1"]) {
            //success
            NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
            int balance = [[apiResponse valueForKey:@"Current"] intValue];
            int lifetime = [[apiResponse valueForKey:@"Lifetime"] intValue];
            
            self.pointsDisplayLabel.text = [NSString stringWithFormat:@"Current Points: %d   -   Level %d", balance, 1];
            
            self.lifetimePointsLabel.text = [NSString stringWithFormat:@"Lifetime Points: %d", lifetime];
            self.pointsProgressView.progress = (float)balance/900.00;
            self.lifetimePointsProgressView.progress = (float)lifetime/100000.0;
        }else{
            
            int balance = 0;
            int lifetime = 0;
            
            self.pointsDisplayLabel.text = [NSString stringWithFormat:@"Current Points: %d   -   Level %d", balance, 1];
            
            self.lifetimePointsLabel.text = [NSString stringWithFormat:@"Lifetime Points: %d", lifetime];
            self.pointsProgressView.progress = 0.0/900.00;
            self.lifetimePointsProgressView.progress = 0.0/100000.0;

            //self.errorLabel.text = @"*Error getting point balance payment.";
        }
        
       [ArcClient trackEvent:@"View Profile"];
}
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.pointBalanceComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)dwollaAuthSwitchSelected {
    @try {
        
        if (self.dwollaAuthSwitch.on) {
            
            [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Dwolla?"  message:@"Are you sure you want to delete your Dwolla info from ARC?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert show];
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.dwollaAuthSwitchSelected" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [DwollaAPI clearAccessToken];
        [ArcClient trackEvent:@"Dwolla Deactivated"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
            
            RegisterDwollaView *detailViewController = [segue destinationViewController];
            detailViewController.fromRegister = YES;
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)viewDidUnload {
    [self setLifetimePointsProgressView:nil];
    [super viewDidUnload];
}
@end
