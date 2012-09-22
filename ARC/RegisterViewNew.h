//
//  RegisterViewNew.h
//  ARC
//
//  Created by Nick Wroblewski on 8/24/12.
//
//

#import <UIKit/UIKit.h>


@interface RegisterViewNew : UIViewController <UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>


@property BOOL isCreditCard;
@property BOOL isIphone5;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) NSString *expirationMonth;
@property (nonatomic, strong) NSString *expirationYear;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) UIPickerView *pickerView;
@property BOOL isExpirationMonth;
@property (weak, nonatomic) UILabel *creditCardExpirationMonthLabel;
@property (weak, nonatomic) UILabel *creditCardExpirationYearLabel;
- (IBAction)endText;
@property (weak, nonatomic)  UITextField *creditCardSecurityCodeText;
@property (weak, nonatomic)  UITextField *creditCardPinText;
@property (weak, nonatomic)  UITextField *creditCardNumberText;
@property (nonatomic, strong) UIView *hideKeyboardView;



@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)login:(UIBarButtonItem *)sender;
- (IBAction)registerNow:(id)sender;

@property (nonatomic, weak) IBOutlet UISegmentedControl *creditDebitSegment;


-(void)changeExpiration;


@property (weak, nonatomic)  UITextField *firstNameText;
@property (weak, nonatomic)  UITextField *lastNameText;
@property (weak, nonatomic)  UITextField *emailText;
@property (weak, nonatomic)  UITextField *birthDateText;

@property (weak, nonatomic)  UITextField *passwordText;
@property (weak, nonatomic)  UISegmentedControl *genderSegment;
@property (weak, nonatomic)  UIView *activityView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *dwollaSegControl;
@property (nonatomic, strong) NSMutableData *serverData;

@property BOOL dwollaSuccess;
@property BOOL registerSuccess;
@property BOOL fromDwolla;




@end