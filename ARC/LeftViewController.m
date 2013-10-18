//
//  LeftViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "LeftViewController.h"
#import "HomeNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeNew.h"
#import "rSkybox.h"
#import "ArcClient.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

-(void)didBeginOpen:(NSNotification *)notification{
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"] length] > 0) {
        self.profileLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"];
    }else{
        self.profileLabel.text = @"Guest - Log In/Create";
    }
}

-(void)viewDidLoad{
    
    self.versionLabel.text = [NSString stringWithFormat:@"version %@", ARC_VERSION_NUMBER];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginOpen:) name:@"LeftMenuDidBeginOpen" object:nil];
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 4;
    self.topLineView.layer.shadowOpacity = 0.7;
}


-(IBAction)homeSelected{
    
    
    if ([self.sideMenu.navigationController.viewControllers count] == 1) {
        //Home is only one on the stack
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshMerchants" object:self userInfo:@{}];
        
      
    }else{
        [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];

    }
    self.sideMenu.navigationController.navigationBarHidden = YES;
    [self.sideMenu toggleLeftSideMenu];
    
}
-(IBAction)profileSelected{
    
    [self goToScreenWithIdentifier:@"profile"];

 
    
}
-(IBAction)billingSelected{
    
    [self goToScreenWithIdentifier:@"allCards"];

    

    
}
-(IBAction)supportSelected{
    

    
    [self goToScreenWithIdentifier:@"supportVC"];


    
}
-(IBAction)shareSelected{
    
    
    [self goToScreenWithIdentifier:@"share"];
    
}

-(void)goToScreenWithIdentifier:(NSString *)identifier{
    
    UIViewController *creditCards = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu.navigationController pushViewController:creditCards animated:NO];
    self.sideMenu.navigationController.navigationBarHidden = YES;
    
    if (self.sideMenu.menuState == MFSideMenuStateLeftMenuOpen) {
        [self.sideMenu toggleLeftSideMenu];

    }
    
}

@end
