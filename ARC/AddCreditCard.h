//
//  AddCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"
#import "NVUIGradientButton.h"
#import "SteelfishTextFieldCreditCardiOS6.h"
#import "LoadingViewController.h"

extern NSString *const VISA;
extern NSString *const MASTER_CARD;
extern NSString *const DISCOVER;
extern NSString *const DINERS_CLUB;
extern NSString *const AMERICAN_EXPRESS;

@class LoadingViewController;

@interface AddCreditCard : UIViewController <UIPickerViewDelegate, UITextFieldDelegate, CardIOPaymentViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL selectCardIo;
@property BOOL isIphone5;
@property BOOL isDelete;
@property BOOL isIos6;
@property BOOL shouldIgnoreValueChanged;
@property BOOL shouldIgnoreValueChangedExpiration;

@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;
@property (weak, nonatomic) IBOutlet UITextField *creditCardSecurityCodeText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardPinText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardNumberText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *expirationText;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *addCardButton;

@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIView *backView;

@property (nonatomic, strong) UIView *hideKeyboardView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *creditDebitSegment;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;
- (IBAction)endText;
-(IBAction)changeExpiration:(UIButton *)sender;
-(IBAction)addCard;

-(IBAction)valueChanged:(id)sender;

-(IBAction)scanCard;
-(IBAction)goBackOne;


@end
