//
//  PrivacyTermsViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 12/4/12.
//
//

#import "ViewController.h"

@interface PrivacyTermsViewController : UIViewController


-(IBAction)doneReading;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property BOOL isPrivacy;



@end
