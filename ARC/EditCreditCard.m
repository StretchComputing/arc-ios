//
//  EditCreditCard.m
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "EditCreditCard.h"
#import "CreditCard.h"
#import "ArcAppDelegate.h"
#import "SettingsView.h"
#import "rSkybox.h"

@interface EditCreditCard ()

@end

@implementation EditCreditCard

-(void)viewDidLoad{
    @try {
        
        [rSkybox addEventToSession:@"viewEditCreditCardScreen"];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *cards = [mainDelegate getCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCards.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)deleteCardAction {
    @try {
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
        
        SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
        tmp.creditCardDeleted = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCards.deleteCardAction" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


@end
