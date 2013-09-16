//
//  ShareViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import "ShareViewController.h"
#import "rSkybox.h"
#import "SteelfishBoldLabel.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcClient.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SMContactsSelector.h"
#import "LeftViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referFriendComplete:) name:@"referFriendNotification" object:nil];

}

-(void)viewDidLoad{
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    if(NSClassFromString(@"SLComposeViewController")) {
        self.isIos6 = YES;
    }else{
        self.isIos6 = NO;
        
    }
    
    
    //self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
   // self.topLineView.layer.shadowRadius = 1;
   // self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
   
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        
        UITableViewCell *cell;
        
        if (indexPath.section == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"shareTopCell"];
            SteelfishBoldLabel *supportLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];

            if (indexPath.row == 0) {
                supportLabel.text = @"Invite Friends";
            }else{
                supportLabel.text = @"Rate dutch!";
            }

        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"shareBottomCell"];
            UIImageView *logoImage = (UIImageView *)[cell.contentView viewWithTag:1];
            UISwitch *onOffSwitch = (UISwitch *)[cell.contentView viewWithTag:2];

            if (indexPath.row == 0) {
                logoImage.image = [UIImage imageNamed:@"facebookconnect.jpg"];
                self.facebookSwitch = onOffSwitch;
                [self.facebookSwitch addTarget:self action:@selector(facebookValueChanged) forControlEvents:UIControlEventValueChanged];
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                if ([[prefs valueForKey:@"autoPostFacebook"] isEqualToString:@"yes"]) {
                    self.facebookSwitch.on = YES;
                }else{
                    self.facebookSwitch.on = NO;
                }
                
            
                
                
            }else{
                logoImage.image = [UIImage imageNamed:@"twittetrconnect.png"];
                self.twitterSwitch = onOffSwitch;
                [self.twitterSwitch addTarget:self action:@selector(twitterValueChanged) forControlEvents:UIControlEventValueChanged];
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                
                if ([[prefs valueForKey:@"autoPostTwitter"] isEqualToString:@"yes"]) {
                    self.twitterSwitch.on = YES;
                }else{
                    self.twitterSwitch.on = NO;
                }
            }
            
        }
        
        
 
        
        
        
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ShareViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

-(void)facebookValueChanged{
    
    @try {
        
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
            
            if (self.facebookSwitch.on) {
                self.facebookSwitch.on = NO;
                self.logInAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users can add credit cards. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
                [self.logInAlert show];
            }
           
        }else{
            
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
                                [prefs synchronize];

                                
                                
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
                    [prefs synchronize];

                }
                
                
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iOS 6 Required!" message:@"dutch only supports auto posting to facebook and twitter with iOS 6.  Please upgrade your device to access this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                self.facebookSwitch.on = NO;
            }

            
        }
        
        
               
    }
    @catch (NSException *exception) {
        
        
    }

}

-(void)twitterValueChanged{
    
    //change
    @try {
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
            
            if (self.twitterSwitch.on) {
                self.twitterSwitch.on = NO;
                self.logInAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users can add credit cards. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
                [self.logInAlert show];
            }
            
        }else{
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            if (self.isIos6) {
                
                if (self.twitterSwitch.on) {
                    
                    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                        
                        [ArcClient trackEvent:@"TWITTER_AUTO_ON"];
                        
                        [prefs setValue:@"yes" forKey:@"autoPostTwitter"];
                        [prefs synchronize];

                        
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Required" message:@"Please log into your Twitter account in your iPhone's settings to use this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                    }
                    
                }else{
                    
                    [ArcClient trackEvent:@"TWITTER_AUTO_OFF"];
                    
                    [prefs setValue:@"no" forKey:@"autoPostTwitter"];
                    [prefs synchronize];

                }
                
                
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iOS 6 Required!" message:@"dutch only supports auto posting to facebook and twitter with iOS 6.  Please upgrade your device to access this feature!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                self.twitterSwitch.on = NO;
                
            }

        }
        
               
        
        
    }
    @catch (NSException *exception) {
        
    }

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    @try {
        
            
            if (buttonIndex == 1) {
                //Go Profile
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp profileSelected];
            }
       
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ShareViewController.clickedButtonAtIndex" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            //Invite
            [self inviteFriend];
        }else{
            //Rate
            [ArcClient trackEvent:@"RATE_ARC"];
            
            //rate
            NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
            str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
            str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
            
            // Here is the app id from itunesconnect
            str = [NSString stringWithFormat:@"%@563542097", str];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }
}

-(void)openMenuAction{
    [self.navigationController.sideMenu toggleLeftSideMenu];
}


-(void)inviteFriend{
    
    
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    
    // Select your returned data type
    controller.requestData = DATA_CONTACT_EMAIL; // , DATA_CONTACT_TELEPHONE
    
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    
    //Window show in Modal or not
    controller.showModal = YES; //Mandatory: YES or NO
    //Show tick or not
    controller.showCheckButton = YES; //Mandatory: YES or NO
    [self presentModalViewController:controller animated:YES];
    
}


//********Invite a Friend Methods




-(void)referFriendComplete:(NSNotification *)notification{
    @try {
        
        [self.loadingViewController stopSpin];

        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        if ([status isEqualToString:@"success"]) {
            //success
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully invited your friend(s)!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Invite Failed." message:@"Sorry, we were unable to send your invite(s) at this time, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.referFriendComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type{
    
    if (numberRows == 0) {
        //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Addresses" message:@"None of the contacts you selected had email addresses entered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //[alert show];
    }else{
        
        self.loadingViewController.displayText.text = @"Inviting...";
        [self.loadingViewController startSpin];
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp referFriend:data];
    }
    
}




@end
