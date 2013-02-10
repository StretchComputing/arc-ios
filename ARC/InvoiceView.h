//
//  InvoiceView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "CorbelBarButtonItem.h"
#import "CorbelBoldLabel.h"
#import "LucidaBoldLabel.h"

@interface InvoiceView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate>

@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property BOOL isPartialPayment;
@property BOOL isGoSplit;
@property BOOL isIphone5;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, strong) UIView *hideKeyboardView;
- (IBAction)payNow:(id)sender;
@property (strong, nonatomic) Invoice *myInvoice;
@property (weak, nonatomic) IBOutlet UIView *bottomHalfView;
- (IBAction)splitCheckAction:(id)sender;
@property (weak, nonatomic) IBOutlet CorbelBoldLabel *alreadyPaidNameLabel;
@property (weak, nonatomic) IBOutlet LucidaBoldLabel *alreadyPaidLabel;

@property (weak, nonatomic) IBOutlet CorbelBarButtonItem *splitCheckButton;
@property (weak, nonatomic) IBOutlet CorbelBarButtonItem *payBillButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *dividerLabel;

@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UILabel *gratLabel;

@property (nonatomic, strong) NSString *paymentsAccepted;

@property (weak, nonatomic) IBOutlet UILabel *discLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *discNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *tipText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegment;
- (IBAction)segmentSelect;
-(IBAction)refreshInvoice;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (weak, nonatomic) IBOutlet UILabel *amountNameLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *gratNameLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;

@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;
-(void)setUpView;

@property (nonatomic, strong) IBOutlet UITextView *overlayTextView;
@end
