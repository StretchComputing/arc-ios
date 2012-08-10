//
//  EditCreditCard.m
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditCreditCard.h"
#import "CreditCard.h"
#import "ArcAppDelegate.h"
#import "SettingsView.h"
@interface EditCreditCard ()

@end

@implementation EditCreditCard

-(void)viewDidLoad{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *cards = [mainDelegate getCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
    
}

- (IBAction)deleteCardAction {
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
    
    SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
    tmp.creditCardDeleted = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
