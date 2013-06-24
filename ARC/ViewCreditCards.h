//
//  ViewCreditCards.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"
#import "NVUIGradientButton.h"

@class LoadingViewController;

@interface ViewCreditCards : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;
@property BOOL deleteCardNow;
@property int selectedRow;
@property BOOL showCardLocked;
- (IBAction)openMenuAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property BOOL creditCardAdded;
@property (nonatomic, strong) UIAlertView *logInAlert;

@property BOOL isEditingTip;


@property (strong, nonatomic) IBOutlet UITextField *defaultTipText;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *defaultTipClearButton;
- (IBAction)defaultTipClearAction;

@property (strong, nonatomic) IBOutlet UISegmentedControl *defaultTipSegmentControl;

- (IBAction)defaultTipSegmentControlValueChanged;

@property (nonatomic, strong) IBOutlet UIView *defaultTipView;
@property BOOL duplicateCard;
- (IBAction)defaultTipEditBegin;
- (IBAction)defaultTipEditChanged;

@end
