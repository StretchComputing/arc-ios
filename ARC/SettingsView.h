//
//  SettingsView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UITableViewController

@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property BOOL creditCardAdded;
@property BOOL creditCardDeleted;

- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lifetimePointsLabel;

@property (nonatomic, strong) NSMutableData *serverData;
@property (weak, nonatomic) IBOutlet UILabel *pointsDisplayLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *pointsProgressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UISwitch *dwollaAuthSwitch;
- (IBAction)dwollaAuthSwitchSelected;
@end
