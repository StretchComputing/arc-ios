//
//  ViewCreditCards.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewCreditCards : UIViewController <UITableViewDelegate, UITableViewDataSource>

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
@end
