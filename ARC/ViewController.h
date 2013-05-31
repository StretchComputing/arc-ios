//
//  ViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@class LoadingViewController;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) ACAccountStore *store;

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *registerButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property BOOL isIos6;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
- (IBAction)facebookAction;

@property (nonatomic, strong) NSMutableData *serverData;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

@property BOOL autoSignIn;
-(IBAction)signIn;
-(IBAction)forgotPassword;
-(IBAction)newUser;

@end
