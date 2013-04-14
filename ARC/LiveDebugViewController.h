//
//  LiveDebugViewController.h
//  ARC
//
//  Created by Joseph Wroblewski on 4/14/13.
//
//

#import <UIKit/UIKit.h>

@interface LiveDebugViewController : UIViewController
- (IBAction)goBackAction;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *sendingActivity;
@property (strong, nonatomic) IBOutlet UILabel *streamStatusLabel;
@property (strong, nonatomic) IBOutlet UITextField *streamNameText;
@property (strong, nonatomic) IBOutlet UIButton *createStreamButton;
- (IBAction)createStreamAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *closeStreamButton;
- (IBAction)closeStreamAction:(id)sender;

@end
