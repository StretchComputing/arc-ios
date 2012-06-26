//
//  RegisterView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaOAuthEngine.h"
#import "DwollaAuthorizationController.h"

@interface RegisterView : UITableViewController <DwollaOAuthEngineDelegate, DwollaAuthorizationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)login:(UIBarButtonItem *)sender;
- (IBAction)registerNow:(id)sender;
- (IBAction)endText;

@property (nonatomic, strong) DwollaOAuthEngine *authEngine;
@property (nonatomic, strong) UIViewController *dwollaView;


@property (weak, nonatomic) IBOutlet UITextField *firstNameText;
@property (weak, nonatomic) IBOutlet UITextField *lastNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (nonatomic, strong) NSMutableData *serverData;

@end
