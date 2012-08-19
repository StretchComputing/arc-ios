//
//  Home.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Home : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property BOOL successReview;
@property BOOL skipReview;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSMutableData *serverData;

@property (nonatomic, strong) NSMutableArray *allMerchants;
@property (nonatomic, strong) NSMutableArray *matchingMerchants;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;

-(IBAction)endText;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@end
