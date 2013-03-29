//
//  ProfileViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/27/13.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "CorbelTextView.h"

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet NVUIGradientButton *signOutButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *createAccountButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *logInButton;
- (IBAction)signOutAction;
- (IBAction)logInAction;
- (IBAction)createAction;
@property (strong, nonatomic)  UITextField *emailTextField;
- (IBAction)viewChangeServerAction;
@property (strong, nonatomic)  UITextField *passwordTextField;
- (IBAction)endText;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *viewChangeServerButton;
@property (strong, nonatomic, getter = getProfileText) IBOutlet CorbelTextView *newProfileText;
@property BOOL isLoggedIn;
-(IBAction)openMenuAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@end
