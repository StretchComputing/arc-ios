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
#import "ArcClient.h"

@interface EditCreditCard ()

@end

@implementation EditCreditCard

-(void)viewDidLoad{
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Edit Card"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Edit Card"];
		self.navigationItem.backBarButtonItem = temp;
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *cards = [mainDelegate getCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)deleteCardAction {
    @try {
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
        
        SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
        tmp.creditCardDeleted = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        NSString *action = [NSString stringWithFormat:@"%@_CARD_DELETE", [self getCardType]];
        [ArcClient trackEvent:action];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.deleteCardAction" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (NSString *)getCardType {
    @try {
        NSString *creditDebitString = @"";
        NSString *sample = [self.creditCardSample lowercaseString];
        if ([sample rangeOfString:@"credit"].location == NSNotFound) {
            creditDebitString = @"DEBIT";
        } else {
            creditDebitString = @"CREDIT";
        }
        return creditDebitString;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.getCardType" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end
