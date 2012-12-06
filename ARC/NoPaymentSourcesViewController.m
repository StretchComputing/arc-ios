//
//  NoPaymentSourcesViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 11/29/12.
//
//

#import "NoPaymentSourcesViewController.h"
#import "CorbelTitleLabel.h"
#import "CorbelBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "RegisterDwollaView.h"
#import "rSkybox.h"

@interface NoPaymentSourcesViewController ()

@end

@implementation NoPaymentSourcesViewController

-(void)cancel{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    if (self.fromDwolla) {
        self.fromDwolla = NO;
        if (self.dwollaSuccess) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully validated your Dwolla credentials!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Failed" message:@"ARC failed to validate your Dwolla credentials, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];

    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    double x = 1.0;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Payment Info"];
    self.navigationItem.titleView = navLabel;
    
    CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Payment"];
    self.navigationItem.backBarButtonItem = temp;
    
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


@end
