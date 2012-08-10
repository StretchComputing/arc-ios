//
//  SettingsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"
#import "ArcAppDelegate.h"
#import "NewJSON.h"
#import "ArcAppDelegate.h"
#import "DwollaAPI.h"
#import "RegisterDwollaView.h"
#import "ArcClient.h"

@interface SettingsView ()

@end

@implementation SettingsView
@synthesize serverData;
@synthesize pointsDisplayLabel;
@synthesize pointsProgressView;
@synthesize activity;
@synthesize dwollaAuthSwitch, fromDwolla, dwollaSuccess, creditCardAdded, creditCardDeleted;

-(void)viewWillAppear:(BOOL)animated{
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    if (self.creditCardAdded){
        self.creditCardAdded = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your credit card was added successfully!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    if (self.creditCardDeleted){
        self.creditCardDeleted = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your credit card was deleted successfully!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    

    
}
- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointBalanceComplete:) name:@"getPointBalanceNotification" object:nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0427221 green:0.380456 blue:0.785953 alpha:1.0];

    self.serverData = [NSMutableData data];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    if ((section == 2) && (row == 2)) {
       
        ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
        mainDelegate.logout = @"true";
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
}


-(void)getPointsBalance{
    
    @try{
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:customerId forKey:@"customerId"];
        
		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getPointBalance:loginDict];
        
        [self.activity startAnimating];
    }
    @catch (NSException *e) {
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)pointBalanceComplete:(NSNotification *)notification{
    NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
    
    NSString *status = [responseInfo valueForKey:@"status"];
    
    [self.activity stopAnimating];
    
    if ([status isEqualToString:@"1"]) {
        //success
        int balance = [[responseInfo valueForKey:@"balance"] intValue];
        
        self.pointsDisplayLabel.text = [NSString stringWithFormat:@"Current Points: %d   -   Level %d", balance, 1];
        
        self.pointsProgressView.progress = (float)balance/900.00;
    }else{
        //self.errorLabel.text = @"*Error getting point balance payment.";
    }
}


- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)dwollaAuthSwitchSelected {
    
    if (self.dwollaAuthSwitch.on) {
       
        [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
        
    }else{
       
        [DwollaAPI clearAccessToken];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
        
        RegisterDwollaView *detailViewController = [segue destinationViewController];
        detailViewController.fromRegister = YES;
    } 
}

@end
