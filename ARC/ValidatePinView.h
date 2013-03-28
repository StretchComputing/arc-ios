//
//  ValidatePinView.h
//  ARC
//
//  Created by Nick Wroblewski on 9/24/12.
//
//

#import <UIKit/UIKit.h>
#import "LucidaBoldLabel.h"
#import "CorbelTextView.h"

@interface ValidatePinView : UIViewController <UITextFieldDelegate>

@property BOOL fromRegister;
@property (nonatomic, strong) UITextField *hiddenText;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;
@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
@property (weak, nonatomic) IBOutlet LucidaBoldLabel *instructionsLabel;


@property (nonatomic, strong) IBOutlet UIButton *deleteCardButton;
-(IBAction)deleteCardAction;

@property BOOL isFirstPin;

@property (strong, nonatomic) NSString *initialPin;
@property (strong, nonatomic) NSString *confirmPin;

@property (weak, nonatomic) IBOutlet CorbelTextView *descriptionText;

@property (nonatomic, strong) NSString *creditDebitString;
@property (nonatomic, strong) NSString *expiration;
@property (nonatomic, strong) NSString *securityCode;
@property (nonatomic, strong) NSString *cardNumber;

-(IBAction)cancel;

@property int numAttempts;
@property (nonatomic, strong) UIView *navBackView1;
@property (nonatomic, strong) UIView *navBackView;
@property (nonatomic, strong) UIView *navLineView;
@property (nonatomic, strong) UIButton *navButton;

@property (nonatomic, strong) LucidaBoldLabel *navLabel;








@end
