






#import <UIKit/UIKit.h>
#import "CardIO.h"
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"
#import "SteelfishBoldLabel.h"
#import "Invoice.h"
#import "SteelfishTextFieldCreditCardiOS6.h"

@class LoadingViewController;

@interface AddCreditCardGuest : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate, CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL selectCardIo;
@property BOOL isIphone5;
@property BOOL isDelete;
@property BOOL isIos6;
@property BOOL shouldIgnoreValueChanged;
@property BOOL shouldIgnoreValueChangedExpiration;

@property BOOL isGuest;
@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardSecurityCodeText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardPinText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardNumberText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *expirationText;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *addCardButton;

@property (nonatomic, strong) UIView *loadingTopView;
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) UIView *hideKeyboardView;
@property (nonatomic, strong) NSString *transactionNotes;
@property (weak, nonatomic) IBOutlet UISegmentedControl *creditDebitSegment;
@property (nonatomic, strong) Invoice *myInvoice;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *totalPaymentLabel;
@property (nonatomic, strong) NSString *totalPayment;
- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;
- (IBAction)endText;
-(IBAction)changeExpiration:(UIButton *)sender;
-(IBAction)addCard;

@property double mySplitPercent;
@property (nonatomic, strong) NSArray *myItemsArray;
-(IBAction)valueChanged:(id)sender;

-(IBAction)scanCard;


@end