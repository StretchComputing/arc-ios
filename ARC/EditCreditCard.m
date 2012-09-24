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
#import "ValidatePinView.h"

@interface EditCreditCard ()

@end

@implementation EditCreditCard

-(void)viewDidAppear:(BOOL)animated{
    
    if (self.cancelAuth) {
    
        [self.navigationController popViewControllerAnimated:NO];
        
    }else{
        if (!self.didAuth){
    
            ValidatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"validatePin"];
            tmp.cardNumber = self.creditCardNumber;
            tmp.securityCode = self.creditCardSecurityCode;
            
            [self.navigationController pushViewController:tmp animated:NO];
        }else{
            [self loadTable];
        }
    }
    
}
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

-(void)loadTable{
    
    self.cardNumberTextField.text = self.displayNumber;
    self.securityCodeTextField.text = self.displaySecurityCode;
    
    self.expirationMonthLabel.text = self.creditCardExpiration;
    self.expirationYearLabel.text = self.creditCardExpiration;
    
    if ([self.creditCardSample rangeOfString:@"Credit"].location != NSNotFound){
        self.cardTypesSegmentedControl.selectedSegmentIndex = 0;
    }
    
    if ([self.creditCardSample rangeOfString:@"Debit"].location != NSNotFound){
        self.cardTypesSegmentedControl.selectedSegmentIndex = 1;
    }
}

-(void)saveCardAction{
    
}
@end
