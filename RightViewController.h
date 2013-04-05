//
//  RightViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LucidaBoldLabel.h"
#import "MFSideMenu.h"

@interface RightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) MFSideMenu *sideMenu;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *totalDueLabel;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *alreadyPaidLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payRemainingButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *learnToSplitButton;
@property (strong, nonatomic) IBOutlet UITableView *alreadyPaidTable;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *totalRemainingLabel;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *noPaymentsLabel;

@property (nonatomic, strong) NSArray *paymentsArray;
@end
