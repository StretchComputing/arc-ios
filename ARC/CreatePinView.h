//
//  CreatePinView.h
//  ARC
//
//  Created by Nick Wroblewski on 9/24/12.
//
//

#import <UIKit/UIKit.h>
#import "LucidaBoldLabel.h"
#import "CorbelTextView.h"
#import "LoadingViewController.h"

@class LoadingViewController;

@interface CreatePinView : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL isEditPin;
@property BOOL fromRegister;
@property (nonatomic, strong) UITextField *hiddenText;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;
@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
@property (weak, nonatomic) IBOutlet LucidaBoldLabel *instructionsLabel;

@property BOOL isFirstPin;

@property (strong, nonatomic) NSString *initialPin;
@property (strong, nonatomic) NSString *confirmPin;

@property (weak, nonatomic) IBOutlet CorbelTextView *descriptionText;
@property BOOL isInsideApp;
@property (nonatomic, strong) NSString *creditDebitString;
@property (nonatomic, strong) NSString *expiration;
@property (nonatomic, strong) NSString *securityCode;
@property (nonatomic, strong) NSString *cardNumber;

@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (strong, nonatomic) IBOutlet UIView *backView;

@end
