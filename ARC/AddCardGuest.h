//
//  AddCardGuest.h
//  ARC
//
//  Created by Nick Wroblewski on 5/28/13.
//
//

#import <UIKit/UIKit.h>
#import "CardIO.h"
#import "LucidaBoldLabel.h"
#import "Invoice.h"
#import "LoadingViewController.h"

@class LoadingViewController;


@interface AddCardGuest : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) Invoice *myInvoice;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *totalPaymentLabel;
@property BOOL selectCardIo;
@property BOOL isIphone5;
@property BOOL isDelete;
@property BOOL isIos6;
@property BOOL shouldIgnoreValueChanged;
@property BOOL shouldIgnoreValueChangedExpiration;

@property (nonatomic, strong) NSArray *myItemsArray;
@property BOOL mySplitPercent;

@property (nonatomic, strong) UIButton *addCardButton;
@property NSTimer *myTimer;

@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;
@property (weak, nonatomic) IBOutlet UITextField *creditCardSecurityCodeText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardPinText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberText;
@property (weak, nonatomic) IBOutlet UITextField *expirationText;

@property (nonatomic, strong) UIView *hideKeyboardView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *creditDebitSegment;

- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;
- (IBAction)endText;
-(IBAction)changeExpiration:(UIButton *)sender;
-(IBAction)addCard;

-(IBAction)valueChanged:(id)sender;

-(IBAction)scanCard;


@end
