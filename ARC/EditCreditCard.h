//
//  EditCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCreditCard : UITableViewController


@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@property (nonatomic, strong) NSString *displayNumber;
@property (nonatomic, strong) NSString *displaySecurityCode;


- (IBAction)deleteCardAction;
- (IBAction)saveCardAction;

@property (weak, nonatomic) IBOutlet UIButton *deleteCardButton;

@property (nonatomic, strong) IBOutlet UITextField *cardNumberTextField;
@property (nonatomic, strong) IBOutlet UITextField *securityCodeTextField;
@property (nonatomic, strong) IBOutlet UILabel *expirationMonthLabel;
@property (nonatomic, strong) IBOutlet UILabel *expirationYearLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *cardTypesSegmentedControl;



@property BOOL didAuth;
@property BOOL cancelAuth;

@end
