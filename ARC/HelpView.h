//
//  HelpView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomMoviePlayerViewController.h"

@class CustomMoviePlayerViewController;

@interface HelpView : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    
    CustomMoviePlayerViewController *moviePlayer;
}
- (IBAction)cancel:(id)sender;
-(IBAction)contactUs;

-(IBAction)goBack;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
