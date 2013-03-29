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
#import "LucidaBoldLabel.h"

@interface SupportViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)openMenuAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *callButton;
- (IBAction)callAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *emailButton;
- (IBAction)emailAction;

@property (weak, nonatomic) IBOutlet LucidaBoldLabel *phoneNumberLabel;

@property (weak, nonatomic) IBOutlet LucidaBoldLabel *emailAddressLabel;

@end
