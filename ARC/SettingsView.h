//
//  SettingsView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UITableViewController
- (IBAction)cancel:(id)sender;

@property (nonatomic, strong) NSMutableData *serverData;
@property (weak, nonatomic) IBOutlet UILabel *pointsDisplayLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *pointsProgressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
