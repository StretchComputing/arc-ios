//
//  ResetPasswordViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 10/15/12.
//
//

#import "ResetPasswordViewController.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController


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
    
    [self.passcodeText becomeFirstResponder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
}

-(void)viewDidLoad{
    
    self.submitButton.text = @"Submit";
    self.submitButton.textColor = [UIColor whiteColor];
    self.submitButton.textShadowColor = [UIColor darkGrayColor];
    self.submitButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1];
    ////self.signInButton.highlightedTintColor = [UIColor colorWithRed:(CGFloat)190/255 green:0 blue:0 alpha:1];
    
    
 //   self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
  //  self.topLineView.layer.shadowRadius = 1;
  //  self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Password Reset"];
    self.navigationItem.titleView = navLabel;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    double x = 1.8;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordResetComplete:) name:@"resetPasswordNotification" object:nil];
}


-(void)passwordResetComplete:(NSNotification *)notification{
    @try {
        
        self.passwordText.enabled = YES;
        self.confirmText.enabled = YES;
        self.passcodeText.enabled = YES;
        self.submitButton.enabled = YES;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        //NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            
            //NSString *newToken = [apiResponse valueForKey:@"Results"];
            //[[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"customerToken"];
            
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"resetPasswordSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
            
            
        } else {
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INCORRECT_PASSCODE) {
                errorMsg = @"Incorrect passcode. Please try again.";
            } else {
                errorMsg = @"Request failed, please try again.";
            }
        }
        
        if([errorMsg length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ResetPasswordViewController.merchantListComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (IBAction)submitAction {
    
    if (([self.passcodeText.text length] > 0) && ([self.passwordText.text length] > 0) && ([self.confirmText.text length] > 0)) {
        
        if ([self.passwordText.text isEqualToString:self.confirmText.text]) {
            NSDictionary *params = @{@"eMail" : self.emailAddress, @"NewPassword" : self.confirmText.text, @"PassCode" : self.passcodeText.text};
            
            [self.activity startAnimating];
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp resetPassword:params];
            self.passwordText.enabled = NO;
            self.confirmText.enabled = NO;
            self.passcodeText.enabled = NO;
            self.submitButton.enabled = NO;
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose Password" message:@"Your password and confirmation do not match, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
      
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Missing" message:@"Please enter your email address, then click Submit" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}


- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
