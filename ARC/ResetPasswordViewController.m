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

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.passcodeText becomeFirstResponder];
}
-(void)viewDidLoad{
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Password Reset"];
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
        NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"resetPasswordSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
            
            
        } else {
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INCORRECT_PASSCODE) {
                errorMsg = @"Incorrect passcode. Please try again.";
            } else {
                errorMsg = @"Arc error, please try again.";
            }
        }
        
        if([errorMsg length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Arc Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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


@end
