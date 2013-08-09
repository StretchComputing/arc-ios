//
//  CreditCardPayment.h
//  ARC
//
//  Created by Nick Wroblewski on 7/4/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaAPI.h"
#import "Invoice.h"
#import "SteelfishBoldLabel.h"
#import "LoadingViewController.h"

@class LoadingViewController;

@interface CreditCardPayment : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) NSMutableArray *myItemsArray;
@property double mySplitPercent;

@property int paymentPointsReceived;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) NSString *ticketId;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *payButton;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *totalPaymentText;

- (IBAction)touchBoxesAction;

@property (weak, nonatomic) IBOutlet UIButton *touchBoxesButton;
@property BOOL didEditCard;
@property BOOL fromDwolla;
@property BOOL dwollaSuccess;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, strong) NSMutableData *serverData;

- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *notesText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) NSMutableArray *fundingSources;
@property (strong, nonatomic) NSString *fundingSourceStatus;
@property (nonatomic, strong) NSString *selectedFundingSourceId;

@property (strong, nonatomic) Invoice *myInvoice;

@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@property (nonatomic, strong) UITextField *hiddenText;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;
@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;


@property BOOL isIphone5;
@property (nonatomic, strong) UIButton *keyboardSubmitButton;
@property (nonatomic, strong) UIView *hideKeyboardView;

@property (nonatomic, strong) IBOutlet UITextView *overlayTextView;


@end