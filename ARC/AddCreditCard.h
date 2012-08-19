//
//  AddCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCreditCard : UITableViewController <UIPickerViewDelegate>

@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditCardExpirationYearLabel;
- (IBAction)endText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardSecurityCodeText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardPinText;
@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberText;
@property (nonatomic, strong) UIView *hideKeyboardView;


- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;

-(IBAction)changeExpiration:(UIButton *)sender;
-(IBAction)addCard;

@end
