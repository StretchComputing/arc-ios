//
//  GetPasscodeViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 10/15/12.
//
//

#import <UIKit/UIKit.h>

@interface GetPasscodeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailText;
- (IBAction)submitAction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end
