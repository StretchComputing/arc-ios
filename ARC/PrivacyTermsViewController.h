//
//  PrivacyTermsViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 12/4/12.
//
//

#import "ViewController.h"
#import "LucidaBoldLabel.h"

@interface PrivacyTermsViewController : UIViewController


-(IBAction)doneReading;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property BOOL isPrivacy;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet LucidaBoldLabel *topLabel;


@property (strong, nonatomic) IBOutlet UIView *backView;

@end
