//
//  InvoiceView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"

@interface InvoiceView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property double amountDue;
- (IBAction)payNow:(id)sender;
@property (strong, nonatomic) Invoice *myInvoice;
@property (weak, nonatomic) IBOutlet UIView *bottomHalfView;
- (IBAction)splitCheckAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *dividerLabel;

@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UILabel *gratLabel;

@property (weak, nonatomic) IBOutlet UILabel *discLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *discNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *tipText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegment;
- (IBAction)segmentSelect;
@property (weak, nonatomic) IBOutlet UILabel *amountNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *gratNameLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;

@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@end
