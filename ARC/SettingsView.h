//
//  SettingsView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//  change

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "ArcClient.h"
#import "CorbelBoldLabel.h"
#import "LoadingViewController.h"

@class LoadingViewController;

@interface SettingsView : UITableViewController

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) IBOutlet CorbelBoldLabel *myProfileLabel;
@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property BOOL creditCardAdded;
@property BOOL creditCardDeleted;
@property BOOL creditCardEdited;
@property (weak, nonatomic) IBOutlet UIView *adminView;

@property (nonatomic, strong) ArcClient *getPointsBalanceArcClient;

@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) ACAccountStore *store;

@property BOOL isIos6;

- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lifetimePointsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *lifetimePointsProgressView;
- (IBAction)changeServer;

@property (nonatomic, strong) NSMutableData *serverData;
@property (weak, nonatomic) IBOutlet UILabel *pointsDisplayLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *pointsProgressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UISwitch *dwollaAuthSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
- (IBAction)facebookSwitchSelected;
- (IBAction)twitterSwitchSelected;


- (IBAction)dwollaAuthSwitchSelected;
@end
