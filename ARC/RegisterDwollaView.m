//
//  RegisterDwollaView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/28/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "RegisterDwollaView.h"
#import "RegisterView.h"
#import "DwollaPayment.h"
#import "SettingsView.h"
#import "rSkybox.h"

@interface RegisterDwollaView ()

@end

@implementation RegisterDwollaView

-(void)viewDidLoad{
    [rSkybox addEventToSession:@"viewRegisterDwollaScreen"];
    
    self.title = @"Dwolla Confirm";
    
    
    NSArray *scopes = @[@"send", @"balance", @"accountinfofull", @"contacts", @"funding",  @"request", @"transactions"];
    DwollaOAuth2Client *client = [[DwollaOAuth2Client alloc] initWithFrame:CGRectMake(0, 0, 320, 460) key:@"W3cjrotm6MNkwk2fW6BsHrE/F7mOr2NfCRljRh5Kj1G5jO+fAQ" secret:@"oC65p5DMOBYX6eOF2J7Q38pWWJT2BzuixQCVNq+eiAcEANRurZ" redirect:@"https://www.dwolla.com" response:@"code" scopes:scopes view:self.view reciever:self];
    [client login];
     
    
}

-(void)successfulLogin
{
    [rSkybox addEventToSession:@"successfulDwollaLogin"];
    
    if (self.fromRegister) {
        RegisterView *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2 ];
        tmp.fromDwolla = YES;
        tmp.dwollaSuccess = YES;
        
        [self.navigationController popViewControllerAnimated:NO];
    }else if (self.fromSettings){
        
        SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2 ];
        tmp.fromDwolla = YES;
        tmp.dwollaSuccess = YES;
        
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        
        DwollaPayment *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2 ];
        tmp.fromDwolla = YES;
        tmp.dwollaSuccess = YES;
        
        [self.navigationController popViewControllerAnimated:NO];
    }
   
     
    
  
}


-(void)failedLogin:(NSArray*)errors
{
    [rSkybox addEventToSession:@"failedDwollaLogin"];
    if (self.fromRegister) {
        RegisterView *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2 ];
        tmp.fromDwolla = YES;
        tmp.dwollaSuccess = NO;
        
        [self.navigationController popViewControllerAnimated:NO];
    }else if (self.fromSettings){
        
        SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2 ];
        tmp.fromDwolla = YES;
        tmp.dwollaSuccess = NO;
        
        [self.navigationController popViewControllerAnimated:NO];
        
    }else {
        
        DwollaPayment *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2 ];
        tmp.fromDwolla = YES;
        tmp.dwollaSuccess = NO;
        
        [self.navigationController popViewControllerAnimated:NO];
        
    }
 

    
}


@end
