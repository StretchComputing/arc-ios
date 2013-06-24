//
//  LeftViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
#import "LucidaBoldLabel.h"

@interface LeftViewController : UIViewController

@property (nonatomic, strong) MFSideMenu *sideMenu;

-(IBAction)homeSelected;
-(IBAction)profileSelected;
-(IBAction)billingSelected;
-(IBAction)supportSelected;
-(IBAction)shareSelected;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *profileLabel;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (strong, nonatomic) IBOutlet LucidaBoldLabel *profileSubLabel;
@end
