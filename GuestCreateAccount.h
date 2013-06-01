//
//  GuestCreateAccount.h
//  ARC
//
//  Created by Nick Wroblewski on 5/31/13.
//
//

#import <UIKit/UIKit.h>
#import "LucidaBoldLabel.h"
#import "Invoice.h"
#import "LoadingViewController.h"

@class Invoice, LoadingViewController;

@interface GuestCreateAccount : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) IBOutlet UIButton *noThanksButton;
- (IBAction)noThanksAction;
- (IBAction)registerAction;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) Invoice *myInvoice;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property BOOL isSignIn;
@property (nonatomic, strong) NSString *ccNumber;
@property (nonatomic, strong) NSString *ccSecurityCode;
@property (nonatomic, strong) NSString *ccExpiration;
@property (strong, nonatomic)  UIBarButtonItem *backButton;
- (IBAction)goBack;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *titleLabel;
@property (strong, nonatomic) IBOutlet CorbelBoldLabel *minCharText;

@property (strong, nonatomic) IBOutlet LucidaBoldLabel *createAccountText;
@end