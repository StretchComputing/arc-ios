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

@interface InitialController ()

@end

@implementation InitialController


-(void)viewDidAppear:(BOOL)animated{
    
    @try {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs stringForKey:@"customerId"];
        NSString *customerToken = [prefs stringForKey:@"customerToken"];
        
        
        ArcClient *client = [[ArcClient alloc] init];
        //[client getServer];
        
        if (![customerId isEqualToString:@""] && (customerId != nil) && ![customerToken isEqualToString:@""] && (customerToken != nil)) {
            //[self performSegueWithIdentifier: @"signInNoAnimation" sender: self];
            //self.autoSignIn = YES;
            
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
            [self presentModalViewController:home animated:NO];
        }else{
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInPage"];
            [self presentModalViewController:home animated:NO];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}
-(void)viewDidLoad{
    
    
}
@end
