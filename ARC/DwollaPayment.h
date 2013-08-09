//
//  DwollaPayment.h
//  ARC
//
//  Created by Nick Wroblewski on 6/27/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaAPI.h"
#import "Invoice.h"
#import "SteelfishBoldLabel.h"
#import "LoadingViewController.h"

@interface DwollaPayment : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;

@property (nonatomic, strong) NSTimer *myTimer;
@property int paymentPointsReceived;
@property double mySplitPercent;
@property (nonatomic, strong) NSMutableArray *myItemsArray;
@property double dwollaBalance;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *dwollaBalanceText;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *totalPaymentText;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *dwollaBalanceActivity;
- (IBAction)touchBoxesAction;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *payButton;
@property (strong, nonatomic) Invoice *myInvoice;

@property BOOL fromDwolla;
@property BOOL dwollaSuccess;

@property BOOL waitingSources;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, strong) NSMutableData *serverData;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;

@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *notesText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) NSMutableArray *fundingSources;
@property (strong, nonatomic) NSString *fundingSourceStatus;
@property (nonatomic, strong) NSString *selectedFundingSourceId;

@property (nonatomic, strong) UITextField *hiddenText;


@property BOOL isIphone5;
@property (nonatomic, strong) UIButton *keyboardSubmitButton;
@property (nonatomic, strong) UIView *hideKeyboardView;

@end
