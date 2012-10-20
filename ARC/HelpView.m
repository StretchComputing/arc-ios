//
//  HelpView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "HelpView.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "ArcClient.h"
#import <MediaPlayer/MediaPlayer.h>

@interface HelpView ()

@end

@implementation HelpView

- (void)viewDidLoad
{
        
    @try {
        [rSkybox addEventToSession:@"viewHelpPage"];
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Help"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Help"];
		self.navigationItem.backBarButtonItem = temp;
        
        
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = backView.bounds;
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [backView.layer insertSublayer:gradient atIndex:0];
        
        self.tableView.backgroundView = backView;
        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        [ArcClient trackEvent:@"MAIN_HELP_VIEW"];
       
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"HelpView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Play movie from URL
    NSURL *movieURL;
    
    if (indexPath.row == 0) {
        movieURL = [NSURL URLWithString:@"http://stretchsite.appspot.com/arcVid1.mp4"];
    }else{
        movieURL = [NSURL URLWithString:@"http://stretchsite.appspot.com/arcVid1.mp4"];
    }
    
    moviePlayer = [[CustomMoviePlayerViewController alloc] initWithURL:movieURL];
    
    // Show the movie player as modal
    [self presentModalViewController:moviePlayer animated:YES];
    
    // Prep and play the movie
    [moviePlayer readyPlayer];
    
}

@end
