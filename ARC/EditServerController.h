//
//  EditServerController.h
//  ARC
//
//  Created by Nick Wroblewski on 11/8/12.
//
//

#import <UIKit/UIKit.h>

@interface EditServerController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property int currentServer;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
@property BOOL isCallingServer;
-(IBAction)cancel;

@property (nonatomic, strong) IBOutlet UINavigationBar *toolbar;

@end
