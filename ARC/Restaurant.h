//
//  Restaurant.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"

@interface Restaurant : UIViewController <UITextFieldDelegate>
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameDisplay;

@property (nonatomic, strong) NSString *name;

@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;

@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;

- (IBAction)checkNumberHelp;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) NSMutableData *serverData;

@property (strong, nonatomic) Invoice *myInvoice;
@end
