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
#import "SteelfishBoldLabel.h"

@interface HelpView ()

@end

@implementation HelpView

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationItem setHidesBackButton:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
}

-(void)contactUs{
    
}
- (void)viewDidLoad
{
        
    @try {
        [rSkybox addEventToSession:@"viewHelpPage"];
        
        //SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Help"];
       // self.navigationItem.titleView = navLabel;
        
        //SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Help"];
		//self.navigationItem.backBarButtonItem = temp;
        
        
        self.title = @"";
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        [ArcClient trackEvent:@"MAIN_HELP_VIEW"];
        
        UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        backView1.backgroundColor = [UIColor blackColor];
        [self.navigationController.navigationBar addSubview:backView1];
        
        
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        backView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        backView.layer.cornerRadius = 7.0;
        
        [self.navigationController.navigationBar addSubview:backView];
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        lineView.backgroundColor = [UIColor blackColor];
        [self.navigationController.navigationBar addSubview:lineView];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setImage:[UIImage imageNamed:@"backarrow.png"] forState:UIControlStateNormal];
        tmpButton.frame = CGRectMake(7, 7, 30, 30);
        [tmpButton addTarget:self action:@selector(goBackOne) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:tmpButton];
        
        SteelfishBoldLabel *tmpLabel = [[SteelfishBoldLabel alloc] initWithFrame:CGRectMake(0, 6, 320, 32) andSize:23];
        tmpLabel.text = @"Help";
        tmpLabel.textAlignment = UITextAlignmentCenter;
        [self.navigationController.navigationBar addSubview:tmpLabel];
        
        
        UIImageView *imageBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 560)];
        imageBackView.image = [UIImage imageNamed:@"newBackground.png"];
        
        self.tableView.backgroundView = imageBackView;
        
        
       
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"HelpView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

-(void)goBackOne{
    [self.navigationController popViewControllerAnimated:YES];
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
        movieURL = [NSURL URLWithString:@"http://dagher.net.co/videos/arcVidMain.mp4"];
    }else{
        movieURL = [NSURL URLWithString:@"http://dagher.net.co/videos/arcVidSplit.mp4"];
    }
    
    moviePlayer = [[CustomMoviePlayerViewController alloc] initWithURL:movieURL];
    
    // Show the movie player as modal
    [self presentModalViewController:moviePlayer animated:YES];
    
    // Prep and play the movie
    [moviePlayer readyPlayer];
    
}


-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}
@end
