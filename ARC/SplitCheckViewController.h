//
//  SplitCheckViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 8/15/12.
//
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "CorbelButton.h"
#import "Invoice.h"
#import "CorbelTextView.h"


@interface SplitCheckViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate>


@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, strong) IBOutlet UIView *hintOverlayView;
@property (strong, nonatomic) IBOutlet CorbelTextView *overlayTextView;

@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property (nonatomic, strong) IBOutlet UILabel *dollarTipIncludedLabel;
@property (nonatomic, strong) IBOutlet UILabel *percentTipIncludedLabel;
@property (nonatomic, strong) IBOutlet UILabel *itemTipIncludedLabel;

//bill division
@property double taxPercentage;
@property double serviceChargePercentage;
@property double discountPercentage;
@property double percentYourPayment;

@property BOOL isIphone5;
@property (nonatomic, strong) UIView *hideKeyboardView;

@property (weak, nonatomic) IBOutlet UILabel *dollarAmountAlreadyPaidNameLabel;
@property int itemSplitItemIndex;

@property (strong, nonatomic) Invoice *myInvoice;

@property (weak, nonatomic) IBOutlet UIView *percentView;
@property (weak, nonatomic) IBOutlet UIView *dollarView;
@property (weak, nonatomic) IBOutlet UIView *itemView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;

- (IBAction)typeSegmentChanged;

-(IBAction)endText;
- (IBAction)dollarTipDidBegin;
- (IBAction)percentTipDidBegin;

@property (weak, nonatomic) IBOutlet UIToolbar *divisionTypeSegment;
@property (weak, nonatomic) IBOutlet CorbelButton *splitSaveButton;
@property (weak, nonatomic) IBOutlet CorbelButton *splitCancelButton;

@property (weak, nonatomic) IBOutlet UILabel *dollarTotalBillNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarTotalBillLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountPaidNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountDueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountDueLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarYourPaymentNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *dollarYourPaymentText;
@property (weak, nonatomic) IBOutlet UITextField *dollarTipText;
- (IBAction)dollarEditEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dollarTipSegment;
@property (weak, nonatomic) IBOutlet UILabel *dollarYourTotalPaymentLabel;
- (IBAction)dollarTipSegmentSelect:(id)sender;
- (IBAction)dollarPayNow:(id)sender;
- (IBAction)dollarYourPaymentEditEnd:(id)sender;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;
@property BOOL didSetTipDefault;

@property (nonatomic, strong) NSMutableArray *myItemArray;

//Percent
@property (weak, nonatomic) IBOutlet UILabel *percentTotalBillNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentTotalBillLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentAmountPaidNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentAmountPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentAmountDueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentAmountDueLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentYourPaymentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentYourTotalPaymentLabel;
@property (weak, nonatomic) IBOutlet UITextField *percentYourPaymentText;
@property (weak, nonatomic) IBOutlet UITextField *percentTipText;
@property (weak, nonatomic) IBOutlet UILabel *percentYourPaymentDollarAmount;
@property (weak, nonatomic) IBOutlet UISegmentedControl *percentTipSegment;

- (IBAction)percentTipDidBegin;
- (IBAction)percentYourPercentDidEnd;
- (IBAction)percentTipEditEnd;
- (IBAction)percentTipSegmentSelect;
-(IBAction)percentYourPercentSegmentSelect;

@property (weak, nonatomic) IBOutlet UILabel *percentFoodBevLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentServiceChargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentTaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarFoodBevLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarServiceChargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarTaxLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *percentYourPercentSegControl;

//Itemized
@property (weak, nonatomic) IBOutlet UILabel *itemYourTotalPaymentLabel;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *itemTipSegment;
@property (weak, nonatomic) IBOutlet UITextField *itemTipText;

@property double itemTotal;
@property (weak, nonatomic) IBOutlet UILabel *itemTaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemServiceChargeLabel;
@property (nonatomic, strong) NSString *paymentsAccepted;
- (IBAction)itemTipDidBegin;
- (IBAction)itemTipEditEnd;
- (IBAction)itemTipSegmentSelect;

//ItemSplitItem
@property (weak, nonatomic) IBOutlet UIView *itemSplitItemView;
- (IBAction)itemSplitItemCancel;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIAlertView *removeAlertView;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (IBAction)itemSplitItemSave;
@property (weak, nonatomic) IBOutlet UILabel *itemSplitItemItemTotal;
@property (weak, nonatomic) IBOutlet UITextField *itemSplitItemYourAmount;
- (IBAction)itemSplitItemYourAmountTextEnd;
@property (weak, nonatomic) IBOutlet UISegmentedControl *itemSplitItemSegControl;
- (IBAction)itemSplitItemSegmentSelect;
-(IBAction)refreshInvoice;


//Metrics
@property BOOL isSegmentDollar;
@property BOOL isSegmentItemized;
@property BOOL isSegmentPercentTip;
@property BOOL isSegmentPercentYour;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *numberOfPeople;
@property (nonatomic, strong) UIButton *numberOfPeopleButton;
@property int numberOfPeopleSelected;

-(IBAction)retapSegmentAction;

@property (nonatomic, strong) IBOutlet UITextView *cardsOverlayTextView;

@property (nonatomic, strong) IBOutlet UIScrollView *numberSliderScrollView;
@end
