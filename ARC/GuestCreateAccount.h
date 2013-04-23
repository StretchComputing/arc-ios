//
//  GuestCreateAccount.h
//  ARC
//
//  Created by Nick Wroblewski on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "LucidaBoldLabel.h"
#import "NVUIGradientButton.h"

@interface GuestCreateAccount : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet NVUIGradientButton *noThanksButton;
- (IBAction)noThanksAction;
- (IBAction)registerAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *registerButton;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@end
