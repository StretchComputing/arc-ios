//
//  ViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"

@class LoadingViewController;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *registerButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) NSMutableData *serverData;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property BOOL autoSignIn;
-(IBAction)signIn;
-(IBAction)forgotPassword;

@end
