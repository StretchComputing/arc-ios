//
//  ShareViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "SMContactsSelector.h"
#import "LoadingViewController.h"

@class  LoadingViewController;
@interface ShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SMContactsSelectorDelegate>

@property (nonatomic, strong) UIAlertView *logInAlert;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
- (IBAction)openMenuAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (nonatomic, strong) UISwitch *facebookSwitch;
@property (nonatomic, strong) UISwitch *twitterSwitch;
@property (nonatomic, strong) ACAccountStore *store;

@property BOOL isIos6;
@end
