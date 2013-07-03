//
//  LiveDebugViewController.m
//  ARC
//
//  Created by Joseph Wroblewski on 4/14/13.
//
//

#import "LiveDebugViewController.h"
#import "rSkybox.h"

@interface LiveDebugViewController ()

@end

@implementation LiveDebugViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamCreateComplete:) name:@"createStreamNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamCloseComplete:) name:@"closeStreamNotification" object:nil];
    
    
    NSString *streamName = [rSkybox getActiveStream];
    if([streamName length] != 0) {
        NSString *activeMessage = [NSString stringWithFormat:@"Stream %@ still Active", streamName];
        self.streamStatusLabel.text = activeMessage;
        
        self.closeStreamButton.hidden = NO;
        self.createStreamButton.hidden = YES;
        self.streamNameText.hidden = YES;
    } else {
        self.closeStreamButton.hidden = YES;
    }
    
}

-(void)streamCreateComplete:(NSNotification *)notification{
    @try {
        [self.sendingActivity stopAnimating];
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *apiStatus = [responseInfo valueForKey:@"apiStatus"];
        if([apiStatus isEqualToString:SUCCESS]){
            NSString *activeMessage = [NSString stringWithFormat:@"Stream %@ Active", self.streamNameText.text];
            self.streamStatusLabel.text = activeMessage;
            
            self.closeStreamButton.hidden = NO;
            self.createStreamButton.hidden = YES;
            self.streamNameText.hidden = YES;
        }
        else {
            NSString *userMessage = @"";
            
            if([apiStatus isEqualToString:NAME_ALREADY_IN_USE]) {
                userMessage = @"Stream name already being used";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Stream Failed" message:userMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
    }
    @catch (NSException *e) {
        NSLog(@"LiveDebugViewController.steamCreateComplete Exception - %@ - %@", [e name], [e description]);
    }
}

-(void)streamCloseComplete:(NSNotification *)notification{
    @try {
        [self.sendingActivity stopAnimating];
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *apiStatus = [responseInfo valueForKey:@"apiStatus"];
        if([apiStatus isEqualToString:SUCCESS]){
            NSString *activeMessage = [NSString stringWithFormat:@"Stream %@ Closed", self.streamNameText.text];
            self.streamStatusLabel.text = activeMessage;
            
            self.closeStreamButton.hidden = YES;
            self.createStreamButton.hidden = NO;
            self.streamNameText.hidden = NO;
        }
        else {
            NSString *userMessage = [NSString stringWithFormat:@"Stream close failed with status %@", apiStatus];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Stream Failed" message:userMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
    }
    @catch (NSException *e) {
        NSLog(@"LiveDebugViewController.steamComplete Exception - %@ - %@", [e name], [e description]);
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setSendingActivity:nil];
    [self setStreamStatusLabel:nil];
    [self setStreamNameText:nil];
    [self setCreateStreamButton:nil];
    [self setCloseStreamButton:nil];
    [super viewDidUnload];
}

- (IBAction)createStreamAction:(id)sender {
    NSString *streamName = self.streamNameText.text;
    if([streamName length] > 0) {
        [self.sendingActivity startAnimating];
        [rSkybox createStream:streamName];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stream Name Missing" message:@"Please enter a unique stream name, then click Create Stream" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)closeStreamAction:(id)sender {
    NSString *streamName = [rSkybox getActiveStream];
    if([streamName length] != 0) {
        [self.sendingActivity startAnimating];
        [rSkybox closeStream:streamName];
    } else {
        NSString *activeMessage = [NSString stringWithFormat:@"Stream Was Already Closed"];
        self.streamStatusLabel.text = activeMessage;
        self.closeStreamButton.hidden = YES;
        self.createStreamButton.hidden = NO;
        self.streamNameText.hidden = NO;
    }
}

@end