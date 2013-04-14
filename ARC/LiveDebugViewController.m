//
//  LiveDebugViewController.m
//  ARC
//
//  Created by Joseph Wroblewski on 4/14/13.
//
//

#import "LiveDebugViewController.h"

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
}
- (IBAction)closeStreamAction:(id)sender {
}
@end
