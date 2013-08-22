//
//  InitHelpPageViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "InitHelpPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PrivacyTermsViewController.h"
#import "rSkybox.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import "ArcIdentifier.h"

@interface InitHelpPageViewController ()

@end

@implementation InitHelpPageViewController

-(void)viewDidAppear:(BOOL)animated{
    
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"didShowInitHelp"] length] > 0) {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowInitHelp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.helpView.frame;
            frame.origin.x = 30;
            self.helpView.frame = frame;
        }];
        
        [self performSelector:@selector(doneHelp) withObject:nil afterDelay:3.5];
        
    }
    
   
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if (!self.isGoingPrivacyTerms) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }else{
        self.isGoingPrivacyTerms = NO;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotificationGuest" object:nil];
    
    //self.loadingViewController.view.hidden = NO;
    //self.loadingViewController.displayText.text = @"
    
    NSString *identifier = [ArcIdentifier getArcIdentifier];
    
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *loginDict = [[NSDictionary alloc] init];
    [ tempDictionary setObject:identifier forKey:@"userName"];
    [ tempDictionary setObject:identifier forKey:@"password"];
    
    loginDict = tempDictionary;
    ArcClient *client = [[ArcClient alloc] init];
    [client getGuestToken:loginDict];
    
    
    
}

-(void)doneHelp{
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.helpView.frame;
        frame.origin.x = 320;
        self.helpView.frame = frame;
    }];
}
- (void)viewDidLoad
{
    
    
    
    self.helpView.layer.cornerRadius = 7.0;
    self.helpView.layer.masksToBounds = YES;
    
    [super viewDidLoad];
	
    self.myScrollView.delegate = self;
    self.startUsingButton.text = @"Start using dutch!";
    
    self.startUsingButton.tintColor =  dutchDarkBlueColor;
    self.startUsingButton.textColor = [UIColor whiteColor];
    
    @try {
        self.pageControl.pageIndicatorTintColor = dutchTopLineColor;
        self.pageControl.currentPageIndicatorTintColor = dutchDarkBlueColor;
    }
    @catch (NSException *exception) {
        
    }
   
    [self.myScrollView setContentSize:CGSizeMake(960, 0)];
    
    self.helpImage1.layer.borderColor = [[UIColor blackColor] CGColor];
    self.helpImage1.layer.borderWidth = 2.0;
  //  self.helpImage1.layer.masksToBounds = YES;

   // self.helpImage1.layer.cornerRadius = 7.0;
    
    self.helpImage2.layer.borderColor = [[UIColor blackColor] CGColor];
    self.helpImage2.layer.borderWidth = 2.0;
    //self.helpImage2.layer.masksToBounds = YES;

   // self.helpImage2.layer.cornerRadius = 7.0;
    
    self.helpImage3.layer.borderColor = [[UIColor blackColor] CGColor];
    self.helpImage3.layer.borderWidth = 2.0;
   // self.helpImage3.layer.masksToBounds = YES;
   // self.helpImage3.layer.cornerRadius = 5.0;
    
    
    self.helpImage1.layer.shadowOffset = CGSizeMake(-2, 2);
    self.helpImage1.layer.shadowRadius = 1;
    self.helpImage1.layer.shadowOpacity = 0.5;
    
    self.helpImage2.layer.shadowOffset =  CGSizeMake(-2, 2);
    self.helpImage2.layer.shadowRadius = 1;
    self.helpImage2.layer.shadowOpacity = 0.5;
    
    self.helpImage3.layer.shadowOffset =  CGSizeMake(-2, 2);
    self.helpImage3.layer.shadowRadius = 1;
    self.helpImage3.layer.shadowOpacity = 0.5;
    
    
    
    self.topLine.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLine.layer.shadowRadius = 1;
    self.topLine.layer.shadowOpacity = 0.2;
    self.topLine.backgroundColor = dutchTopLineColor;
    self.view.backgroundColor = dutchTopNavColor;
    
    
    self.bottomLine.layer.shadowOffset = CGSizeMake(0, 1);
    self.bottomLine.layer.shadowRadius = 1;
    self.bottomLine.layer.shadowOpacity = 0.2;
    self.bottomLine.backgroundColor = dutchTopLineColor;

    
    self.vertLine1.layer.shadowOffset = CGSizeMake(1, 0);
    self.vertLine1.layer.shadowRadius = 1;
    self.vertLine1.layer.shadowOpacity = 0.5;
    
    self.vertLine2.layer.shadowOffset = CGSizeMake(1, 0);
    self.vertLine2.layer.shadowRadius = 1;
    self.vertLine2.layer.shadowOpacity = 0.5;
    
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 30, 320, self.view.frame.size.height + 100);
    self.loadingViewController.view.hidden = YES;
    [self.view addSubview:self.loadingViewController.view];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int offset = scrollView.contentOffset.x;
    
    if (offset == 0) {
        self.pageControl.currentPage = 0;
    }else if (offset == 320){
        self.pageControl.currentPage = 1;
    }else if (offset == 640){
        self.pageControl.currentPage = 3;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        @try {
            
            
            
            if ([[segue identifier] isEqualToString:@"goPrivacy"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = YES;
                self.isGoingPrivacyTerms = YES;
                
            }
            
            if ([[segue identifier] isEqualToString:@"goTerms"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = NO;
                self.isGoingPrivacyTerms = YES;
                
            }
        }
        @catch (NSException *e) {
            [rSkybox sendClientLog:@"InitialHelpPageVC.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitialHelpPageVC.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)startUsingAction{
    
    if (self.didFailToken) {
        
        NSString *identifier = [ArcIdentifier getArcIdentifier];
        
        self.loadingViewController.view.hidden = NO;
        self.loadingViewController.displayText.text = @"Starting dutch...";
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:identifier forKey:@"userName"];
        [ tempDictionary setObject:identifier forKey:@"password"];
        
        loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getGuestToken:loginDict];
        
        
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didAgreeTerms"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"guestToken"] length] > 0) {
            
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
            home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:home animated:YES];
            
        }else{
            if (self.doesHaveGuestToken || self.guestTokenError) {
                
                if (self.guestTokenError) {
                    
                    self.didPushStart = YES;
                    self.loadingViewController.view.hidden = NO;
                    self.loadingViewController.displayText.text = @"Loading dutch...";
                    
                    NSString *identifier = [ArcIdentifier getArcIdentifier];
                    
                    
                    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                    NSDictionary *loginDict = [[NSDictionary alloc] init];
                    [ tempDictionary setObject:identifier forKey:@"userName"];
                    [ tempDictionary setObject:identifier forKey:@"password"];
                    
                    loginDict = tempDictionary;
                    ArcClient *client = [[ArcClient alloc] init];
                    [client getGuestToken:loginDict];
                    
                    
                    
                }else{
                    UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
                    home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentModalViewController:home animated:YES];
                }
                
            }else{
                
                //Call is still loading
                self.didPushStart = YES;
                self.loadingViewController.view.hidden = NO;
                self.loadingViewController.displayText.text = @"Loading dutch...";
            }
        }

    }
       
}


-(void)signInComplete:(NSNotification *)notification{
    @try {
        
        
        self.loadingViewController.view.hidden = YES;
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        // NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success            
            self.didFailToken = NO;
            if (self.didPushStart) {
                
                UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
                home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:home animated:YES];
                
                
            }else{
                self.doesHaveGuestToken = YES;
            }
            
            //UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InitHelpPage"];
            //[self presentModalViewController:home animated:NO];
            
            
            
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
            
            self.didFailToken = YES;
            //self.errorLabel.text = errorMsg;
            
            self.guestTokenError = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading Error" message:@"We experienced an error loading your guest account, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitialHelpPageVC.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}
@end
