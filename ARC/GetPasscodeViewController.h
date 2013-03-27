//
//  GetPasscodeViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 10/15/12.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"

@interface GetPasscodeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailText;
- (IBAction)submitAction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIButton *backAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *submitButton;
- (IBAction)goBackAction;

@end
