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
#import <Social/Social.h>

@interface SettingsView ()

@end

@implementation SettingsView
@synthesize lifetimePointsProgressView;


-(void)viewWillDisappear:(BOOL)animated{
    
    [self.getPointsBalanceArcClient cancelConnection];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    self.myProfileLabel.text = @"Sign In!";
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    
    @try {
        
       
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointBalanceComplete:) name:@"getPointBalanceNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
        
        ArcClient *tmp = [[ArcClient alloc] init];
        if (![tmp admin]) {
            self.adminView.hidden = YES;
        }else{
            self.adminView.hidden = NO;
        }
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([[prefs valueForKey:@"autoPostFacebook"] isEqualToString:@"yes"]) {
            self.facebookSwitch.on = YES;
        }else{
            self.facebookSwitch.on = NO;
        }
        
        if ([[prefs valueForKey:@"autoPostTwitter"] isEqualToString:@"yes"]) {
            self.twitterSwitch.on = YES;
        }else{
            self.twitterSwitch.on = NO;
        }
        
        
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your card was added successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
        if (self.creditCardDeleted){
            self.creditCardDeleted = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your card was deleted successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
        if (self.creditCardEdited){
            self.creditCardEdited = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your card was changed successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        
        if(NSClassFromString(@"SLComposeViewController")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;

        }
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Profile"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Profile"];
		self.navigationItem.backBarButtonItem = temp;
        
        [rSkybox addEventToSession:@"viewSettingsPage"];
       
        
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        
        
        
        UIView *backView = [[UIView alloc] initWithFrame:self.view.bounds];
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
        
        if (section == 2){
            
            if (row == 0) {
                
                [ArcClient trackEvent:@"RATE_ARC"];

                //rate
                NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
                str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
                str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
                
                // Here is the app id from itunesconnect
                str = [NSString stringWithFormat:@"%@563542097", str];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            }else if (row == 1){
               //Customer Service Button clicked
                
            
            }else if (row == 2){
                //logout
                ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                mainDelegate.logout = @"true";
                [self.navigationController dismissModalViewControllerAnimated:NO];
            }
          
        }
        
        if ((section == 0) && (row == 2)) {
            
            UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"referFriend"];
            [self.navigationController presentModalViewController:tmp animated:YES];
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
        self.getPointsBalanceArcClient = [[ArcClient alloc] init];
        [self.getPointsBalanceArcClient getPointBalance:loginDict];
        
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
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            NSDictionary *apiResponse = [[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"];
            
            int balance = [[apiResponse valueForKey:@"Current"] intValue];
            int lifetime = [[apiResponse valueForKey:@"Lifetime"] intValue];
            
            self.pointsDisplayLabel.text = [NSString stringWithFormat:@"Current Points: %d   -   Level %d", balance, 1];
            
            self.lifetimePointsLabel.text = [NSString stringWithFormat:@"Lifetime Points: %d", lifetime];
            self.pointsProgressView.progress = (float)balance/1000.00;
            self.lifetimePointsProgressView.progress = (float)lifetime/100000.0;
        } else if([status isEqualToString:@"error"]){
           // int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            errorMsg = ARC_ERROR_MSG;
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            // set both labels to the error message otherwise we would be displaying the wrong # of points
            self.pointsDisplayLabel.text = errorMsg;
            self.lifetimePointsLabel.text = errorMsg;
        }
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
        [ArcClient trackEvent:@"DWOLLA_DEACTIVATED"];
    }else{
        self.dwollaAuthSwitch.on = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
            
            RegisterDwollaView *detailViewController = [segue destinationViewController];
            detailViewController.fromSettings = YES;
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)facebookSwitchSelected{
    
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if (self.isIos6) {
            
            if (self.facebookSwitch.on) {
                
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                    
                    self.store = [[ACAccountStore alloc] init];
                    
                    ACAccountType *accType = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                    
                    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    @"515025721859862", ACFacebookAppIdKey,
                                                    [NSArray arrayWithObjects:@"email", nil], ACFacebookPermissionsKey, ACFacebookAudienceFriends, ACFacebookAudienceKey, nil];
                    
                    [self.store requestAccessToAccountsWithType:accType options:options completion:^(BOOL granted, NSError *error) {
                        
                        if (granted && error == nil) {
                           // NSLog(@"Granted");
                            
                            [ArcClient trackEvent:@"FACEBOOK_AUTO_ON"];

                            [prefs setValue:@"yes" forKey:@"autoPostFacebook"];
                            
                            
                        } else {
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"Your Facebook account could not be authenticated.  Please make sure your device is logged into facebook, and turned 'On' for ARC.  Thank you!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                [alert show];
                                
                                self.facebookSwitch.on = NO;
                                
                            });
                            
                            
                            //NSLog(@"Error: %@", [error description]);
                            //NSLog(@"Access denied");
                        }
                    }];
                    
                    
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Required" message:@"Please log into your Facebook account in your iPhone's settings to use this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    self.facebookSwitch.on = NO;
                }
                
            }else{
                [ArcClient trackEvent:@"FACEBOOK_AUTO_OFF"];

                [prefs setValue:@"no" forKey:@"autoPostFacebook"];
            }
            
            
            [prefs synchronize];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iOS 6 Required!" message:@"Arc only supports auto posting to facebook and twitter with iOS 6.  Please upgrade your device to access this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.facebookSwitch.on = NO;
        }

    }
    @catch (NSException *exception) {
        

    }

}
- (IBAction)twitterSwitchSelected{
    
    //change
    @try {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if (self.isIos6) {
            
            if (self.twitterSwitch.on) {
                
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                    
                    [ArcClient trackEvent:@"TWITTER_AUTO_ON"];

                    [prefs setValue:@"yes" forKey:@"autoPostTwitter"];
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Required" message:@"Please log into your Twitter account in your iPhone's settings to use this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                
            }else{
                
                [ArcClient trackEvent:@"TWITTER_AUTO_OFF"];

                [prefs setValue:@"no" forKey:@"autoPostTwitter"];
            }
            
            
            [prefs synchronize];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iOS 6 Required!" message:@"Arc only supports auto posting to facebook and twitter with iOS 6.  Please upgrade your device to access this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            self.twitterSwitch.on = NO;

        }
        
        

    }
    @catch (NSException *exception) {
        
    }
      
    
}



-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}

- (IBAction)changeServer {
}
- (void)viewDidUnload {
    [self setMyProfileLabel:nil];
    [super viewDidUnload];
}
@end
