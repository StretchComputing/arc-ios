//
//  PrivacyTermsViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 12/4/12.
//
//

#import "PrivacyTermsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"

@interface PrivacyTermsViewController ()

@end

@implementation PrivacyTermsViewController

-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];

    NSString *urlString;
    
    if (self.isPrivacy) {
        self.topLabel.text = @"Privacy";
        urlString = @"http://arc.dagher.mobi/html/docs/privacy.html";
    }else{
        self.topLabel.text = @"Terms of Use";
        urlString = @"http://arc.dagher.mobi/html/docs/terms.html";
    }
    
    NSURL *targetURL = [NSURL URLWithString:urlString];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:targetURL];
	
	//Load the request in the UIWebView.
	[self.webview loadRequest:requestObj];
}

-(void)viewDidLoad{

    self.navigationController.navigationBarHidden = YES;
    
   // self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
  //  self.topLineView.layer.shadowRadius = 1;
  //  self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
}

-(void)doneReading{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
