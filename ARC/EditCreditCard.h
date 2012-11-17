//
//  EditCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCreditCard : UITableViewController

@property BOOL pinDidChange;
@property BOOL isFromPayment;
@property (nonatomic, strong, getter = getMyNewPin) NSString *newPin;

@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;
@property (nonatomic, strong) NSString *oldPin;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property BOOL isIphone5;

@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;

@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@property (nonatomic, strong) NSString *displayNumber;
@property (nonatomic, strong) NSString *displaySecurityCode;

@property (nonatomic, strong) UIView *hideKeyboardView;

- (IBAction)deleteCardAction;
- (IBAction)saveCardAction;

@property (weak, nonatomic) IBOutlet UIButton *deleteCardButton;

@property (nonatomic, strong) IBOutlet UITextField *cardNumberTextField;
@property (nonatomic, strong) IBOutlet UITextField *securityCodeTextField;
@property (nonatomic, strong) IBOutlet UILabel *expirationMonthLabel;
@property (nonatomic, strong) IBOutlet UILabel *expirationYearLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *cardTypesSegmentedControl;

- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;
- (IBAction)endText;
-(IBAction)changeExpiration:(UIButton *)sender;

-(IBAction)editPin;

@property BOOL didAuth;
@property BOOL cancelAuth;

@end
