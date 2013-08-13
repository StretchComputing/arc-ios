//
//  InvoiceView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "SteelfishBarButtonItem.h"
#import "SteelfishBoldLabel.h"
#import "NVUIGradientButton.h"
#import "SteelfishInputText.h"
#import "InvoiceHelpOverlay.h"
#import "SteelfishBoldInputText.h"
#import "SteelfishLabel.h"

@interface InvoiceView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, UIScrollViewAccessibilityDelegate, UIGestureRecognizerDelegate>
- (IBAction)splitMyPaymentEditChanged;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *howManySaveButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *howManyCancelButton;
- (IBAction)splitDollarPercentAction;
@property (strong, nonatomic) IBOutlet UIView *splitDollarPercentBackView;

@property (strong, nonatomic) IBOutlet NVUIGradientButton *cancelItemSplitButton;
@property (strong, nonatomic) IBOutlet SteelfishBoldInputText *splitDollarMyPaymentText;
@property (strong, nonatomic) IBOutlet UIView *splitViewDollar;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitDollarSaveButton;
- (IBAction)splitDollarSaveAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitDollarCancelButton;
- (IBAction)splitDollarCancelAction;

@property (nonatomic, strong) InvoiceHelpOverlay *helpOverlay;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitPercentageButton;
- (IBAction)splitPercentageAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitDollarButton;
- (IBAction)splitDollarAction;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *splitPeopleYouPayLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *cancelSplitPeople;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *splitItemMyPaymentLabel;
@property (strong, nonatomic) IBOutlet SteelfishBoldInputText *howManyText;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *howManyTitle;

@property int howManyItemIndex;
@property (nonatomic, strong) IBOutlet UIView *howManyView;
@property (nonatomic, strong) UIView *alphaBackView;
@property (nonatomic, strong) IBOutlet UIView *payView;
@property int moveY;
@property (nonatomic, strong) IBOutlet UIImageView *receiptView;
@property BOOL isRefresh;
@property BOOL isIos6;
@property int numberOfPeopleSelected;
@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property BOOL isPartialPayment;
@property BOOL isGoSplit;
@property BOOL isIphone5;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)showBalanceAction;
- (IBAction)goBackAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payBillButton;
- (IBAction)payBillAction;
@property (strong, nonatomic) IBOutlet UIView *subtotalBackView;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIView *splitView;
- (IBAction)cancelSplitAction;
@property (strong, nonatomic) IBOutlet UIScrollView *numberSliderScrollView;

- (IBAction)payFullSplitAction;
@property (nonatomic, strong) UIButton *alreadyPaidButton;
@property (nonatomic, strong) UIView *hideKeyboardView;
- (IBAction)payNow:(id)sender;
@property (strong, nonatomic) Invoice *myInvoice;
@property (weak, nonatomic) IBOutlet UIView *bottomHalfView;
- (IBAction)splitCheckAction:(id)sender;
@property (weak, nonatomic) IBOutlet SteelfishBoldLabel *alreadyPaidNameLabel;
@property (weak, nonatomic) IBOutlet SteelfishBoldLabel *alreadyPaidLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitCancelButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitFullButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitSaveButton;
- (IBAction)splitSaveAction;
@property double myItemizedTotal;

@property (nonatomic, strong) UIAlertView *overpayAlert;
@property double splitMyDue;
@property double splitItemMyDue;

@property (strong, nonatomic) IBOutlet UIView *splitTopLineView;
@property (weak, nonatomic) IBOutlet SteelfishBarButtonItem *splitCheckButton;
//@property (weak, nonatomic) IBOutlet SteelfishBarButtonItem *payBillButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *dividerLabel;
@property BOOL shouldRun;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UILabel *gratLabel;
- (IBAction)splitMyPaymentDidBegin:(id)sender;
@property (strong, nonatomic) IBOutlet SteelfishInputText *splitMyPaymentTextField;
@property BOOL isEditingMyPayment;
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

@property (nonatomic, strong) UIAlertView *payAllAlert;
@property int payAllSelectedIndex;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *gratNameLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;

@property (nonatomic, strong) NSMutableArray *myItemArray;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;
-(void)setUpView;

@property (nonatomic, strong) IBOutlet UITextView *overlayTextView;


//AlreadyPaid
@property (nonatomic, strong) IBOutlet UIView *alreadyPaid;
@property (nonatomic, strong) IBOutlet UITableView *alreadyPaidTableView;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *alreadyPaidViewLabel;
-(IBAction)cancelAlreadyPaid;
- (IBAction)showSplitView;


@property (nonatomic, strong) UIView *refreshHeaderView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;
@property BOOL isDragging;
@property BOOL isLoading;
@property BOOL shouldCallStop;

-(void)showFullTotal;
-(void)deselectAllItems;

@property BOOL didShowPaidItems;

@property BOOL isShowingAlreadyPaidAlert;
@property (nonatomic, strong) NSMutableArray *paidItemsArray;
//Split single Item
@property (nonatomic, strong) IBOutlet UIView *itemSplitView;
@property (nonatomic, strong) IBOutlet UILabel *itemSplitItemItemTotal;
@property (strong, nonatomic) IBOutlet SteelfishInputText *itemSplitMyPaymentText;
- (IBAction)closeItemSplitAction;

- (IBAction)itemSplitSaveAction;
@property (strong, nonatomic) IBOutlet UIScrollView *itemSplitScrollView;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *itemSplitName;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *itemSplitSaveButton;
@property int itemSplitIndex;



-(IBAction)saveHowManyView;
-(IBAction)cancelHowManyView;

/**** Selecting a MUTL-Amoutn Line Item
 
 3 options:  (currenet implementation is option #1)
 
 
 1.)  Single Click:  Alert, "are you paying for all?".   Yes = select whole line, no = break out into sub lines
      Touch & Hold:  Nothing
 
 2.)  Single Click:  Select whole line
      Touch & Hold:  Break out into sub lines
 
 3.)  Single Click:  Break out into sub lines
      Touch & Hold:  Nothing
 
 */




/*****  ITEM Dictionary Key/Values
 
 
 KEY                VALUE
 
 Amount               # of that item ordered
 Value                cost per item
 Descrption           name of item
 
 
 IsPaidFor            yes - this line item has already been paid for
                      no - has not been paid for
                      maybe - is partiallin paid for
 
 
 IsPayingFor          yes - paying for ALL of this line item (could be quantity 1 or more)
                      no - not paying for any of this item
                      maybe - paying for PART of a single item
 
 AmountPayingFor      amount of this single item being paid for (only applicable if IsPayingFor = maybe)
 
 IsTopLevel           yes - is a multiple Amount item, with single Amount breakouts of the same item listed below it  (is greyed out)
                      no - is not sub divided into single items
 
 IsSubLevel           yes - is a breakout of a multi-Amount line item    (indented - selectable with single click or touch and hold)
 
 
 EX:
 
 
 3   Fish Dinner     15.00              (IsTopLevel = YES)
    1 Fish Dinner     5.00              (IsSubLevel = YES)
    1 Fish Dinner     5.00              (IsSubLevel = YES)
    1 Fish Dinner     5.00              (IsSubLevel = YES)
 
 
 
 
 
 
 */
@end
