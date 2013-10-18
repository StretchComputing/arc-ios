//
//  PaymentHistoryDetail.h
//  ARC
//
//  Created by Nick Wroblewski on 10/14/13.
//
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"
#import "NVUIGradientButton.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishLabel.h"
#import "SteelfishTextView.h"

@class LoadingViewController;

@interface PaymentHistoryDetail : UIViewController

@property (nonatomic, strong) NSDictionary *paymentDictionary;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
-(IBAction)goBack;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *resendButton;
-(IBAction)resendAction;

@property (strong, nonatomic) IBOutlet SteelfishTextView *notesTextView;
@property (strong, nonatomic) IBOutlet SteelfishLabel *confirmationLabel;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *totalAmountLabel;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *merchantNameLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *dateLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *baseAmountLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *tipLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *paymentLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *checkNumberLabel;


@end
