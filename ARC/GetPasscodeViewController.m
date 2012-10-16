//
//  GetPasscodeViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 10/15/12.
//
//

#import "GetPasscodeViewController.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "ResetPasswordViewController.h"

@interface GetPasscodeViewController ()

@end

@implementation GetPasscodeViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.emailText becomeFirstResponder];
}
-(void)cancel{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)viewDidLoad{
    
    UIBarButtonItem *tmp = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = tmp;
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Password Reset"];
    self.navigationItem.titleView = navLabel;
    
    CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Reset"];
    self.navigationItem.backBarButtonItem = temp;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    double x = 1.8;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(merchantListComplete:) name:@"getPasscodeNotification" object:nil];
}

-(void)merchantListComplete:(NSNotification *)notification{
    @try {
        self.emailText.enabled = YES;
        self.submitButton.enabled = YES;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
    
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            
            [self performSegueWithIdentifier:@"goReset" sender:self];
            
                       
           
        } else {
            errorMsg = @"Arc error, please try again.";
        }
        
        if([errorMsg length] > 0) {
            self.errorLabel.text = errorMsg;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GetPasscodeViewController.merchantListComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (IBAction)submitAction {
    
    if ([self.emailText.text length] > 0) {
        NSDictionary *params = @{@"eMail" : self.emailText.text};
        [self.activity startAnimating];
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp getPasscode:params];
     
        self.emailText.enabled = NO;
        self.submitButton.enabled = NO;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Missing" message:@"Please enter your email address, then click Submit" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
   
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    @try {
        if ([[segue identifier] isEqualToString:@"goReset"]) {
            
            ResetPasswordViewController *detailViewController = [segue destinationViewController];
            detailViewController.emailAddress = self.emailText.text;
            
          
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GetPasscodeViewController.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


@end