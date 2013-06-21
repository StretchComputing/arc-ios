//
//  EditServerController.h
//  ARC
//
//  Created by Nick Wroblewski on 11/8/12.
//
//

#import <UIKit/UIKit.h>
#import "LoadingViewController.h"

@class LoadingViewController;


@interface EditServerController : UIViewController


@property (nonatomic, strong) LoadingViewController *loadingViewController;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property int currentServer;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
@property BOOL isCallingServer;
-(IBAction)cancel;

@property (nonatomic, strong) NSMutableArray *serverListArray;
@property (nonatomic, strong) IBOutlet UINavigationBar *toolbar;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
- (IBAction)goBackOne;

@end
