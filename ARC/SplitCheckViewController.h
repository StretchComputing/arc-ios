//
//  SplitCheckViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 8/15/12.
//
//

#import <UIKit/UIKit.h>
#import "Invoice.h"

@interface SplitCheckViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (strong, nonatomic) Invoice *myInvoice;
@property double amountDue;
@property double yourTotalPayment;
@property double yourPayment;

@property (weak, nonatomic) IBOutlet UIView *percentView;
@property (weak, nonatomic) IBOutlet UIView *dollarView;
@property (weak, nonatomic) IBOutlet UIView *itemView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;

- (IBAction)typeSegmentChanged;

-(IBAction)endText;
- (IBAction)dollarTipDidBegin;
- (IBAction)percentTipDidBegin;

@property (weak, nonatomic) IBOutlet UILabel *dollarTotalBillNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarTotalBillLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountPaidNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountPaidLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountDueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarAmountDueLabel;
@property (weak, nonatomic) IBOutlet UILabel *dollarYourPaymentNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *dollarYourPaymentText;
@property (weak, nonatomic) IBOutlet UITextField *dollarTipText;
- (IBAction)dollarEditBegin:(id)sender;
- (IBAction)dollarEditEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dollarTipSegment;
@property (weak, nonatomic) IBOutlet UILabel *dollarYourTotalPaymentLabel;
- (IBAction)dollarTipSegmentSelect:(id)sender;
- (IBAction)dollarPayNow:(id)sender;
- (IBAction)dollarYourPaymentEditEnd:(id)sender;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;











@end
