//
//  InitialController.m
//  ARC
//
//  Created by Nick Wroblewski on 8/24/12.
//
//

#import "InitialController.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcIdentifier.h"
@interface InitialController ()

@end

@implementation InitialController


-(void)viewDidAppear:(BOOL)animated{
    
    @try {
        self.loadingView.hidden = YES;
        self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
        self.topLineView.layer.shadowRadius = 1;
        self.topLineView.layer.shadowOpacity = 0.5;
        
        self.topView.layer.cornerRadius = 7.0;
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs stringForKey:@"customerId"];
        NSString *customerToken = [prefs stringForKey:@"customerToken"];
        
        NSString *guestId = [prefs stringForKey:@"guestId"];
        NSString *guestToken = [prefs stringForKey:@"guestToken"];
        
        
        if (![customerId isEqualToString:@""] && (customerId != nil) && ![customerToken isEqualToString:@""] && (customerToken != nil)) {
            //[self performSegueWithIdentifier: @"signInNoAnimation" sender: self];
            //self.autoSignIn = YES;
            
            if (![guestId isEqualToString:@""] && (guestId != nil) && ![guestToken isEqualToString:@""] && (guestToken != nil)) {
                
                
            }else{
                /*
                 NSString *identifier = [ArcIdentifier getArcIdentifier];
                 
                 
                 NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                 NSDictionary *loginDict = [[NSDictionary alloc] init];
                 [ tempDictionary setObject:identifier forKey:@"userName"];
                 [ tempDictionary setObject:identifier forKey:@"password"];
                 
                 loginDict = tempDictionary;
                 ArcClient *client = [[ArcClient alloc] init];
                 [client getGuestToken:loginDict];
                 */
            }
            
            
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp updatePushToken];
            
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
            home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:home animated:YES];
        }else{
            
            if (![guestId isEqualToString:@""] && (guestId != nil) && ![guestToken isEqualToString:@""] && (guestToken != nil) && [[[NSUserDefaults standardUserDefaults] valueForKey:@"didAgreeTerms"] length] > 0) {
                //UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InitHelpPage"];
                //[self presentModalViewController:home animated:NO];
                
                //UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
               // [self presentModalViewController:home animated:NO];
                
                UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
                home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:home animated:YES];

            }else{
                
                
                //Go to initHelpPage, where GuestTOken is retrieved
                
                UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InitHelpPage"];
                [self presentModalViewController:home animated:NO];
                
                /*
                 self.loadingView.hidden = NO;
                 
                 NSString *identifier = [ArcIdentifier getArcIdentifier];
                 
                 
                 NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                 NSDictionary *loginDict = [[NSDictionary alloc] init];
                 [ tempDictionary setObject:identifier forKey:@"userName"];
                 [ tempDictionary setObject:identifier forKey:@"password"];
                 
                 loginDict = tempDictionary;
                 ArcClient *client = [[ArcClient alloc] init];
                 [client getGuestToken:loginDict];
                 */
                
            }
            
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(void)viewDidLoad{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotificationGuest" object:nil];

    
    self.mottoLabel.font = [UIFont fontWithName:@"Chalet-Tokyo" size:21];
    
}



-(void)signInComplete:(NSNotification *)notification{
    @try {
        
     
        self.loadingView.hidden = YES;
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
   
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InitHelpPage"];
            [self presentModalViewController:home animated:NO];
            
            //[self goHomePage];
            //[[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didJustLogin"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            
            // [self performSelector:@selector(checkPayment) withObject:nil afterDelay:1.5];
            
            //Do the next thing (go home?)
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INCORRECT_LOGIN_INFO) {
                errorMsg = @"Invalid Email and/or Password";
            } else {
                // TODO -- programming error client/server coordination -- rskybox call
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.errorLabel.text = errorMsg;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitialController.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}




@end
