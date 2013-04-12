//
//  LeftViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "LeftViewController.h"
#import "HomeNavigationController.h"
@interface LeftViewController ()

@end

@implementation LeftViewController

-(void)viewdidLoad{
    
}

-(IBAction)homeSelected{
    
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
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
