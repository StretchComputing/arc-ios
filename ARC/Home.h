//
//  Home.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//  Made a change

#import <UIKit/UIKit.h>
#import "SMContactsSelector.h"
#import "CorbelTextView.h"

@interface Home : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SMContactsSelectorDelegate>

@property BOOL successReview;
@property BOOL skipReview;

@property BOOL didShowPayment;

@property (nonatomic, strong) IBOutlet UIView *hintOverlayView;
@property (strong, nonatomic) IBOutlet CorbelTextView *overlayTextView;

@property int retryCount;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

@property BOOL isDragging;
@property BOOL isLoading;
@property BOOL shouldCallStop;
@property BOOL isIos6;
@property (nonatomic, weak) IBOutlet UIButton *refreshListButton;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSMutableData *serverData;

@property (nonatomic, strong) NSMutableArray *allMerchants;
@property (nonatomic, strong) NSMutableArray *matchingMerchants;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;
- (IBAction)refreshMerchants:(id)sender;

-(IBAction)endText;
-(IBAction)inviteFriend;

@property (nonatomic, weak) IBOutlet UITextField *searchTextField;


@property (nonatomic, strong) UIView *refreshHeaderView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;
-(IBAction)refreshList;

@property (nonatomic, strong) NSMutableArray *multipleEmailArray;

-(void)hideAlert;
@end
