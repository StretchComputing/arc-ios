//
//  EditCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"
#import "SteelfishTextFieldCreditCardiOS6.h"

@class LoadingViewController;

@interface EditCreditCard : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property BOOL pinDidChange;
@property BOOL isFromPayment;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL isIos6;
@property BOOL shouldIgnoreValueChanged;
@property BOOL shouldIgnoreValueChangedExpiration;
@property BOOL cancelAuthLock;
@property BOOL deleteCardNow;

@property (nonatomic, strong, getter = getMyNewPin) NSString *newPin;

@property (nonatomic, strong) IBOutlet UITextField *expirationText;
@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;
@property (nonatomic, strong) NSString *oldPin;
@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property BOOL isIphone5;

@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIView *backView;

@property (strong, nonatomic) IBOutlet UITextField *cardNameText;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *editPinButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *saveChangesButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *deleteButton;

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

@property BOOL isDelete;

- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;
- (IBAction)endText;
-(IBAction)changeExpiration:(UIButton *)sender;

-(IBAction)editPin;

-(IBAction)valueChanged:(id)sender;

@property BOOL didAuth;
@property BOOL cancelAuth;

@end
