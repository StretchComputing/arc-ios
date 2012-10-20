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

@interface HelpView : UITableViewController{
    
    CustomMoviePlayerViewController *moviePlayer;
}
- (IBAction)cancel:(id)sender;

@end
