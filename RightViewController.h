//
//  RightViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LucidaBoldLabel.h"
#import "MFSideMenu.h"
#import "InvoiceView.h"
#import "Invoice.h"

@class InvoiceView, Invoice;

@interface RightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) Invoice *myInvoice;
@property (nonatomic, strong) InvoiceView *invoiceController;
@property (nonatomic, strong) MFSideMenu *sideMenu;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *totalDueLabel;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *alreadyPaidLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payRemainingButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *learnToSplitButton;
@property (strong, nonatomic) IBOutlet UITableView *alreadyPaidTable;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *totalRemainingLabel;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *noPaymentsLabel;

@property (nonatomic, strong) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *seeWhoPaidLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *splitRemainingButton;
@property (nonatomic, strong) NSArray *paymentsArray;
- (IBAction)splitRemainingAction;
@property (strong, nonatomic) IBOutlet UIView *splitView;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *saveSplitButton;
- (IBAction)cancelSplitAction;
@property (strong, nonatomic) IBOutlet UIScrollView *numberSliderScrollView;
@property int numberOfPeopleSelected;
- (IBAction)saveSplitAction;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *splitYourPaymentLabel;
@property (strong, nonatomic) IBOutlet UIView *splitTopLineView;
-(IBAction)payRemainingAction;
@end
