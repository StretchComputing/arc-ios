//
//  PaymentHistoryViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 10/14/13.
//
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"

@class LoadingViewController;

@interface PaymentHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property int selectedRow;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) NSMutableArray *paymentsArray;
-(IBAction)goBack;
@end
