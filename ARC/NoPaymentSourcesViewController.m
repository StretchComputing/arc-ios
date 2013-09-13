//
//  NoPaymentSourcesViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 11/29/12.
//
//

#import "NoPaymentSourcesViewController.h"
#import "SteelfishTitleLabel.h"
#import "SteelfishBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "RegisterDwollaView.h"
#import "rSkybox.h"
#import "ArcAppDelegate.h"

@interface NoPaymentSourcesViewController ()

@end

@implementation NoPaymentSourcesViewController

-(void)cancel{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden = YES;
    if (self.fromDwolla) {
        self.fromDwolla = NO;
        if (self.dwollaSuccess) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully validated your Dwolla credentials!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Failed" message:@"dutch failed to validate your Dwolla credentials, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if (self.creditCardAdded) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully added a credit card!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.navigationController dismissModalViewControllerAnimated:YES];
        
    }
}

-(void)viewDidLoad{
    
    self.creditCardButton.text = @"Credit Card";
    self.dwollaButton.text = @"Dwolla";
    
    self.cancelButton.text = @"Cancel";
    self.cancelButton.textColor = [UIColor whiteColor];
    self.cancelButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
   
 //   self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
  //  self.topLineView.layer.shadowRadius = 1;
  //  self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;

    
}

-(void)creditCard{
    [self performSegueWithIdentifier:@"addCard" sender:self];
}
-(void)dwolla{
    [self performSegueWithIdentifier:@"confirmDwolla" sender:self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
            
            RegisterDwollaView *detailViewController = [segue destinationViewController];
            detailViewController.fromMain = YES;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SettingsView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)viewDidUnload {
    [self setCancelButton:nil];
    [self setCreditCardButton:nil];
    [self setDwollaButton:nil];
    [self setBackView:nil];
    [self setTopLineView:nil];
    [super viewDidUnload];
}
@end
