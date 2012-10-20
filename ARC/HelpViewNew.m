//
//  HelpViewNew.m
//  ARC
//
//  Created by Nick Wroblewski on 9/19/12.
//
//

#import "HelpViewNew.h"
#import "CorbelTitleLabel.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HelpViewNew ()

@end

@implementation HelpViewNew

-(void)viewDidLoad{
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Help"];
    self.navigationItem.titleView = navLabel;
    
         self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    double x = 1.8;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    
    //myColor = [UIColor colorWithRed:64.0*y/255.0 green:74.0*y/255.0 blue:81.0*y/255.0 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    
}

- (IBAction)cancel:(id)sender {
    
    
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"arcVid1" ofType:@"mp4"]];
        MPMoviePlayerController *moviePlayer =  [[MPMoviePlayerController alloc]
                        initWithContentURL:url];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self
          //                                       selector:@selector(moviePlayBackDidFinish:)
            //                                         name:MPMoviePlayerPlaybackDidFinishNotification
              //                                     object:moviePlayer];
        
        moviePlayer.controlStyle = MPMovieControlStyleDefault;
        moviePlayer.shouldAutoplay = YES;
        [self.view addSubview:moviePlayer.view];
        [moviePlayer setFullscreen:YES animated:YES];
    
    
    //[self.navigationController dismissModalViewControllerAnimated:YES];
    
    
}

/*
-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
	MPMoviePlayerController* theMovie=[aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [[UIApplication sharedApplication]
     setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
}

*/





@end
