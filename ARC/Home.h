//
//  Home.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//  Made a change

#import <UIKit/UIKit.h>

@interface Home : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property BOOL successReview;
@property BOOL skipReview;

@property int retryCount;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

@property BOOL isDragging;
@property BOOL isLoading;
@property BOOL shouldCallStop;
@property BOOL isIos6;


@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSMutableData *serverData;

@property (nonatomic, strong) NSMutableArray *allMerchants;
@property (nonatomic, strong) NSMutableArray *matchingMerchants;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;
- (IBAction)refreshMerchants:(id)sender;

-(IBAction)endText;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;


@property (nonatomic, strong) UIView *refreshHeaderView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;


@end
