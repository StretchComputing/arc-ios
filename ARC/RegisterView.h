//
//  RegisterView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegisterView : UITableViewController <UIPickerViewDelegate>

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



@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)login:(UIBarButtonItem *)sender;
- (IBAction)registerNow:(id)sender;


- (IBAction)editBegin:(id)sender;
- (IBAction)editEnd:(id)sender;

-(IBAction)changeExpiration:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UITextField *firstNameText;
@property (weak, nonatomic) IBOutlet UITextField *lastNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *dwollaSegControl;
@property (nonatomic, strong) NSMutableData *serverData;

@property BOOL dwollaSuccess;
@property BOOL registerSuccess;
@property BOOL fromDwolla;




@end
