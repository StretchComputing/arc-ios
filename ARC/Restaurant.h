//
//  Restaurant.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "CorbelBarButtonItem.h"


@interface Restaurant : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFive;
@property (weak, nonatomic) IBOutlet UITextField *checkNumSix;

@property BOOL helpShowing;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameDisplay;

@property (nonatomic, strong) NSString *name;

@property (weak, nonatomic) IBOutlet UIImageView *checkHelpImageView;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;

@property BOOL wentInvoice;

@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;

@property (nonatomic, strong) NSString *merchantId;

- (IBAction)checkNumberHelp;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) NSMutableData *serverData;

@property (strong, nonatomic) Invoice *myInvoice;

@property (nonatomic, strong) UITextField *hiddenText;

@end
