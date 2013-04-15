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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamComplete:) name:@"createStreamNotification" object:nil];
}

-(void)streamComplete:(NSNotification *)notification{
    @try {
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *apiStatus = [responseInfo valueForKey:@"apiStatus"];
        if([apiStatus isEqualToString:SUCCESS]){
            NSString *activeMessage = [NSString stringWithFormat:@"Stream %@ Active", self.streamNameText.text];
            self.streamStatusLabel.text = activeMessage;
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
        NSLog(@"LiveDebugViewController.steamComplete Exception - %@ - %@", [e name], [e description]);
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
        [rSkybox createStream:streamName];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stream Name Missing" message:@"Please enter a unique stream name, then click Create Stream" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }

}

- (IBAction)closeStreamAction:(id)sender {
}
@end
