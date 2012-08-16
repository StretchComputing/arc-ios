//
//  ContactUsView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface ContactUsView : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)call;
- (IBAction)email;
@property (nonatomic, weak) IBOutlet UILabel *sloganLabel;

@end
