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
@interface InitHelpPageViewController ()

@end

@implementation InitHelpPageViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
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
    self.topLine.layer.shadowOpacity = 0.5;
    
    self.bottomLine.layer.shadowOffset = CGSizeMake(0, -1);
    self.bottomLine.layer.shadowRadius = 1;
    self.bottomLine.layer.shadowOpacity = 0.5;
    
    
    self.vertLine1.layer.shadowOffset = CGSizeMake(1, 0);
    self.vertLine1.layer.shadowRadius = 1;
    self.vertLine1.layer.shadowOpacity = 0.5;
    
    self.vertLine2.layer.shadowOffset = CGSizeMake(1, 0);
    self.vertLine2.layer.shadowRadius = 1;
    self.vertLine2.layer.shadowOpacity = 0.5;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        @try {
            
          
            
            if ([[segue identifier] isEqualToString:@"goPrivacy"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = YES;
                
            }
            
            if ([[segue identifier] isEqualToString:@"goTerms"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = NO;
                
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
    UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
    home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:home animated:YES];
}
@end
