//
//  ConfirmPaymentViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"
#import "LucidaBoldLabel.h"

@class LoadingViewController;

@interface ConfirmPaymentViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) Invoice *myInvoice;

@property int incorrectPinCount;

@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@property int paymentPointsReceived;

@property (nonatomic, strong) NSString *transactionNotes;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) UITextField *hiddenText;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;
@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *confirmButton;
- (IBAction)confirmAction;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *paymentLabel;
- (IBAction)goBackAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (strong, nonatomic) IBOutlet LucidaBoldLabel *myTotalLabel;
@property double mySplitPercent;
@property (nonatomic, strong) NSArray *myItemsArray;
@property (nonatomic, strong) NSTimer *myTimer;
@end
