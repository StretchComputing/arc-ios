//
//  LeftTestViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 9/12/13.
//
//

#import "LeftTestViewController.h"

@interface LeftTestViewController ()

@end

@implementation LeftTestViewController

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
    
    CGRect frame = self.view.frame;
    frame.origin.y -= 200;
    frame.size.height +=40;
    self.view.frame = frame;
    
    self.view.backgroundColor = [UIColor greenColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
