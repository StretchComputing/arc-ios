//
//  RegisterViewNew.h
//  ARC
//
//  Created by Nick Wroblewski on 8/24/12.
//
//

#import <UIKit/UIKit.h>
#import "CorbelBarButtonItem.h"
#import "CardIO.h"
#import <Accounts/Accounts.h>
#import "LoadingViewController.h"
#import "NVUIGradientButton.h"
#import "LucidaBoldLabel.h"

@class LoadingViewController;

@interface RegisterViewNew : UIViewController <UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CardIOPaymentViewControllerDelegate>


@property (nonatomic, strong) IBOutlet UIView *topLineView;
@property (nonatomic, strong) IBOutlet UIView *backView;

@property (nonatomic, strong) IBOutlet NVUIGradientButton *nextButton;
@property (nonatomic, strong, getter = getRegButton) IBOutlet NVUIGradientButton *newRegisterButton;

@property (nonatomic, strong) IBOutlet LucidaBoldLabel *regTitleLabel;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) ACAccountStore *store;
@property (nonatomic, strong) UIButton *keyboardSubmitButton;
@property (nonatomic, strong) UIView *hideKeyboardView;
@property (nonatomic, strong) CorbelBarButtonItem *registerButton;
@property BOOL isIos6;
@property BOOL isDelete;
@property (nonatomic, strong) IBOutlet UIButton *facebookButton;


@property CGPoint scrollViewOffset;

@property BOOL didFirstRun;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *loginButton;

@property BOOL isIphone5;

@property int pageNumber;
@property (nonatomic, strong) IBOutlet UIScrollView *myScrollView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) IBOutlet UITableView *myTableViewTwo;
@property (nonatomic, strong) IBOutlet UITableView *myTableViewThree;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity;


- (IBAction)goNext;
@property BOOL fromCreditCard;

@property BOOL registerSuccess;


@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)login:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet UIButton *facebookSignupButton;
- (IBAction)signUpFacebookAction;

@property BOOL shouldIgnoreValueChanged;
@property BOOL shouldIgnoreValueChangedExpiration;

@property (weak, nonatomic)  UITextField *emailText;
@property (weak, nonatomic)  UITextField *passwordText;
@property (weak, nonatomic)  UITextField *firstNameText;
@property (weak, nonatomic)  UITextField *lastNameText;
@property (weak, nonatomic)  UITextField *creditCardSecurityCodeText;
@property (weak, nonatomic)  UITextField *creditCardNumberText;
@property (nonatomic, strong) UITextField *expirationText;


-(IBAction)scanCard;
-(IBAction)goTo3;


@end