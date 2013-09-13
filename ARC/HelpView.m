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

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    //self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
  // self.navigationController.navigationBarHidden = NO;
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
        

        
        
        UIImageView *imageBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 560)];
        imageBackView.image = [UIImage imageNamed:@"newBackground.png"];
        
        self.myTableView.backgroundView = imageBackView;
        
        [self.myTableView reloadData];
       
        
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        
        UITableViewCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"helpCell"];
            

        SteelfishBoldLabel *myLabel = [[SteelfishBoldLabel alloc] initWithFrame:CGRectMake(20,9,267,26) andSize:20];
        myLabel.textAlignment = UITextAlignmentLeft;
        if (indexPath.row == 0) {
            myLabel.text = @"How It Works";
        }else{
            myLabel.text = @"Splitting The Bill";
        }
        
        [cell.contentView addSubview:myLabel];
        
        
        
        
        
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Select A Help Video To Watch";
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
