//
//  SupportViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/27/13.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "SteelfishBoldLabel.h"

@interface SupportViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)openMenuAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *callButton;
- (IBAction)callAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *emailButton;
- (IBAction)emailAction;

@property (weak, nonatomic) IBOutlet SteelfishBoldLabel *phoneNumberLabel;

@property (weak, nonatomic) IBOutlet SteelfishBoldLabel *emailAddressLabel;

@end
