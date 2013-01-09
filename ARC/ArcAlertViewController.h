//
//  ArcAlertViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 1/8/13.
//
//

#import <UIKit/UIKit.h>
#import "Home.h"

@interface ArcAlertViewController : UIViewController

@property (nonatomic, strong) NSString *alertText;
@property (nonatomic, strong) IBOutlet UIView *alertView;
@property (nonatomic, strong) IBOutlet UITextView *alertViewTextView;

@property int alertViewHeight;

-(IBAction)okAlertAction;

-(void)doInitSetup;


@end
