//
//  LeftViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishLabel.h"

@interface LeftViewController : UIViewController

@property (nonatomic, strong) MFSideMenu *sideMenu;

-(IBAction)homeSelected;
-(IBAction)profileSelected;
-(IBAction)billingSelected;
-(IBAction)supportSelected;
-(IBAction)shareSelected;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *profileLabel;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet SteelfishLabel *versionLabel;

@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *profileSubLabel;
@end
