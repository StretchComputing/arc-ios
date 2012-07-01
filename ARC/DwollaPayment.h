//
//  DwollaPayment.h
//  ARC
//
//  Created by Nick Wroblewski on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaAPI.h"

@interface DwollaPayment : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property int invoiceId;
@property double totalAmount;
@property double gratuity;

@property (nonatomic, strong) NSMutableData *serverData;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;

@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *notesText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) NSMutableArray *fundingSources;
@property (strong, nonatomic) NSString *fundingSourceStatus;
@property (nonatomic, strong) NSString *selectedFundingSourceId;

@end
