//
//  CreatePinView.h
//  ARC
//
//  Created by Nick Wroblewski on 9/24/12.
//
//

#import <UIKit/UIKit.h>
#import "SteelfishBoldLabel.h"
#import "SteelfishTextView.h"
#import "LoadingViewController.h"
#import "NVUIGradientButton.h"
#import "SteelfishLabel.h"
#import "Invoice.h"

@class LoadingViewController;

@interface CreatePinView : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) Invoice *myInvoice;
@property BOOL isLoggedInUser;
@property BOOL fromCreateGuest;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL isEditPin;
@property BOOL fromRegister;
@property (nonatomic, strong) UITextField *hiddenText;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;
@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
@property (weak, nonatomic) IBOutlet SteelfishBoldLabel *instructionsLabel;
@property BOOL isDuplicate;
@property BOOL isFirstPin;

@property (strong, nonatomic) NSString *initialPin;
@property (strong, nonatomic) NSString *confirmPin;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *skipButton;

- (IBAction)skipAction;
@property (weak, nonatomic) IBOutlet SteelfishLabel *descriptionText;
@property BOOL isInsideApp;
@property (nonatomic, strong) NSString *creditDebitString;
@property (nonatomic, strong) NSString *expiration;
@property (nonatomic, strong) NSString *securityCode;
@property (nonatomic, strong) NSString *cardNumber;

@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (strong, nonatomic) IBOutlet UIView *backView;

@end
