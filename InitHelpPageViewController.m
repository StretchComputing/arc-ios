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
    self.startUsingButton.text = @"Start Using Arc!";
    
    self.startUsingButton.tintColor =  [UIColor colorWithRed:21.0/255.0 green:80.0/225.0 blue:125.0/255.0 alpha:1.0];
    self.startUsingButton.textColor = [UIColor whiteColor];
    
    @try {
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/225.0 blue:125.0/255.0 alpha:1.0];
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/225.0 blue:125.0/255.0 alpha:1.0];
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
- (void)viewDidUnload {
    [self setStartUsingButton:nil];
    [self setPageControl:nil];
    [self setHelpView:nil];
    [super viewDidUnload];
}
@end
