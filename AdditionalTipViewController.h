//
//  AdditionalTipViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/29/13.
//
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishTextView.h"
#import "NVUIGradientButton.h"

@interface AdditionalTipViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *actionSheet;

@property (strong, nonatomic) Invoice *myInvoice;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@property (nonatomic, strong) NSArray *myItemsArray;
@property double mySplitPercent;

@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *myTotalLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *tipSelectSegment;
@property (strong, nonatomic) IBOutlet SteelfishTextView *transactionNotesText;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *continueButton;
@property (strong, nonatomic) IBOutlet UITextField *tipTextField;
- (IBAction)continueAction:(id)sender;
- (IBAction)goBackAction;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIView *backView;
- (IBAction)endText;
- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)tipTextEditChanged;
@property (nonatomic, strong) UIView *hideKeyboardView;
- (IBAction)tipTextEditBegin;

@end
