//
//  AddCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const VISA;
extern NSString *const MASTER_CARD;
extern NSString *const DISCOVER;
extern NSString *const DINERS_CLUB;
extern NSString *const AMERICAN_EXPRESS;

@interface AddCreditCard : UITableViewController <UIPickerViewDelegate, UITextFieldDelegate>

@property BOOL isIphone5;
@property BOOL isDelete;

@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;
@property (weak, nonatomic) IBOutlet UITextField *creditCardSecurityCodeText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardPinText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberText;
@property (weak, nonatomic) IBOutlet UITextField *expirationText;

@property (nonatomic, strong) UIView *hideKeyboardView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *creditDebitSegment;

- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;
- (IBAction)endText;
-(IBAction)changeExpiration:(UIButton *)sender;
-(IBAction)addCard;

-(IBAction)valueChanged:(id)sender;

@end
