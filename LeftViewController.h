//
//  LeftViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"

@interface LeftViewController : UIViewController

@property (nonatomic, strong) MFSideMenu *sideMenu;

-(IBAction)homeSelected;
-(IBAction)profileSelected;
-(IBAction)billingSelected;
-(IBAction)supportSelected;
-(IBAction)shareSelected;

@end
