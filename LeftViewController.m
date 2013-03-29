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
    [self.sideMenu toggleLeftSideMenu];
    
}
-(IBAction)profileSelected{
    
    UIViewController *creditCards = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu.navigationController pushViewController:creditCards animated:NO];
    [self.sideMenu toggleLeftSideMenu];
    
}
-(IBAction)billingSelected{
    
    
    UIViewController *creditCards = [self.storyboard instantiateViewControllerWithIdentifier:@"allCards"];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu.navigationController pushViewController:creditCards animated:NO];
    [self.sideMenu toggleLeftSideMenu];
 
    
}
-(IBAction)supportSelected{
    
    UIViewController *creditCards = [self.storyboard instantiateViewControllerWithIdentifier:@"supportVC"];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu.navigationController pushViewController:creditCards animated:NO];
    [self.sideMenu toggleLeftSideMenu];
    
}
-(IBAction)shareSelected{
    
    UIViewController *creditCards = [self.storyboard instantiateViewControllerWithIdentifier:@"share"];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu.navigationController pushViewController:creditCards animated:NO];
    [self.sideMenu toggleLeftSideMenu];
    
}
@end
