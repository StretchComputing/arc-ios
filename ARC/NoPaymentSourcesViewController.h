//
//  NoPaymentSourcesViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 11/29/12.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"

@interface NoPaymentSourcesViewController : UIViewController


-(IBAction)creditCard;
-(IBAction)dwolla;

-(IBAction)cancel;

@property (strong, nonatomic) IBOutlet NVUIGradientButton *cancelButton;

@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property BOOL creditCardAdded;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *creditCardButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *dwollaButton;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@end
