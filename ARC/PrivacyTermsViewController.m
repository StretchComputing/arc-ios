//
//  PrivacyTermsViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 12/4/12.
//
//

#import "PrivacyTermsViewController.h"

@interface PrivacyTermsViewController ()

@end

@implementation PrivacyTermsViewController

-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];

    NSString *documentPath;
    
    if (self.isPrivacy) {
        self.title = @"Privacy";
        documentPath = [[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"pdf"];
    }else{
        self.title = @"Terms of Use";
        documentPath = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"pdf"];
    }
    
    NSURL *targetURL = [NSURL fileURLWithPath:documentPath];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:targetURL];
	
	//Load the request in the UIWebView.
	[self.webview loadRequest:requestObj];
}

-(void)viewDidLoad{


}

-(void)doneReading{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
@end