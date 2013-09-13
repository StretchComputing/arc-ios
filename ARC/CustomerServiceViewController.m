//
//  CustomerServiceViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 2/21/13.
//
//

#import "CustomerServiceViewController.h"
#import "SteelfishTitleLabel.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "rSkybox.h"
#import "ArcClient.h"

@interface CustomerServiceViewController ()

@end

@implementation CustomerServiceViewController

-(void)viewDidLoad{
    
    self.recordButton.text = @"Record";
    self.sendButton.text = @"Send Feedback";
    
   // self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
   // self.topLineView.layer.shadowRadius = 1;
  //  self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    
    [ArcClient trackEvent:@"CUSTOMER_SERVICE_VIEW"];

    
    //SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Feedback"];
    //self.navigationItem.titleView = navLabel;
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.sendButton.hidden = YES;
    self.sendLabel.hidden = YES;
    self.recordingActivity.hidden = YES;
    self.recordingLabel.hidden = YES;
    self.displayLabel.hidden = YES;
}




- (IBAction)recordAction {
    
    @try {
        self.displayLabel.text = @"";
        if (self.isRecording) {
            self.isRecording = false;
            
            [self.navigationItem setHidesBackButton:NO];
            
            self.recordingActivity.hidden = YES;
            self.recordingLabel.hidden = YES;
            self.recordButton.text = @"Record";
            [self.recorder stop];
            
            self.recordedData = [[NSData alloc] initWithContentsOfURL:self.temporaryRecFile];
            
            self.displayLabel.hidden = NO;
            if ([self.recordedData length] > 0) {
                self.sendLabel.hidden = NO;
                self.sendButton.hidden = NO;
                //self.previewButton.hidden = NO;
                self.displayLabel.text = @"*Recording Successful!";
                self.displayLabel.textColor = [UIColor colorWithRed:0.0 green:100.0/255.0 blue:0.0 alpha:1.0];
            }else{
                self.displayLabel.textColor = [UIColor redColor];
                self.displayLabel.text = @"*Recording failed...";
            }
            
        }else{
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryRecord error:nil];
            [session setActive:YES error:nil];
            
            self.isRecording = true;
            [self.navigationItem setHidesBackButton:YES];
            self.recordingLabel.hidden = NO;
            self.recordingActivity.hidden = NO;
            self.sendLabel.hidden = YES;
            self.sendButton.hidden = YES;
            //self.previewButton.hidden = YES;
            self.displayLabel.hidden = YES;
            
            self.recordButton.text = @"Stop";
            self.temporaryRecFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"VoiceFile1.mp4"]];
            
            NSDictionary *recordSettings = @{AVSampleRateKey: @44100.0f,
                                             AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                             AVNumberOfChannelsKey: @1,
                                             AVEncoderAudioQualityKey: @(AVAudioQualityMedium)};
            
            
            
            
            self.recorder = [[AVAudioRecorder alloc] initWithURL:self.temporaryRecFile settings:recordSettings error:nil];
            [self.recorder setDelegate:self];
            [self.recorder prepareToRecord];
            [self.recorder record];
            
            
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"CustomerServiceViewController.recordAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
    
    
}








- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
}


- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    
}

- (IBAction)sendAction {
    
  
    
    // send recorded feedback to GAE
    self.sendButton.hidden = YES;
    [self.sendingActivity startAnimating];
    self.recordButton.enabled = NO;
    [self performSelectorInBackground:@selector(sendResults) withObject:nil];
    
}

-(void)sendResults{
    
    @autoreleasepool {
        
        [rSkybox sendFeedback:self.recordedData];
        
        [self performSelectorOnMainThread:@selector(doneResults) withObject:nil waitUntilDone:NO];
    }
    
    
}

-(void)doneResults{
    
    self.recordButton.enabled = YES;
   // self.previewButton.hidden = YES;
    [self.sendingActivity stopAnimating];
    self.sendLabel.hidden = YES;
    self.displayLabel.text = @"Feedback Sent!";
    self.displayLabel.textColor = [UIColor colorWithRed:0.0 green:100.0/255.0 blue:0.0 alpha:1.0];
    
}

-(void)preview{
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    
    
    NSError* error = nil;
    AVAudioPlayer *newAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:self.temporaryRecFile error:&error];
    newAudio.delegate = self;
    //self.myPlayer = [[AVAudioPlayer alloc] initWithData:self.recordedData error:&error];
    
    
    
    [newAudio prepareToPlay];
    
    // set it up and play
    [newAudio setNumberOfLoops:0];
    [newAudio setVolume: 1.0];
    [newAudio play];
    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
    
}




- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)liveDebug {
    //Customer Service
    UIViewController *liveDebug = [self.storyboard instantiateViewControllerWithIdentifier:@"liveDebug"];
    [self.navigationController pushViewController:liveDebug animated:YES];

}
@end
