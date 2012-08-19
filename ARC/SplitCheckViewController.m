//
//  SplitCheckViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 8/15/12.
//
//

#import "SplitCheckViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"

@interface SplitCheckViewController ()

@end

@implementation SplitCheckViewController


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
    @try {
        [rSkybox addEventToSession:@"signInComplete"];
        
        self.dollarView.hidden = NO;
        self.percentView.hidden = YES;
        self.itemView.hidden = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        self.dollarView.backgroundColor = [UIColor clearColor];
        self.percentView.backgroundColor = [UIColor clearColor];
        self.itemView.backgroundColor = [UIColor clearColor];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }

}

- (void)viewDidUnload
{
    [self setPercentView:nil];
    [self setDollarView:nil];
    [self setItemView:nil];
    [self setTypeSegment:nil];
    [self setTypeSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)typeSegmentChanged {
    @try {
        if (self.typeSegment.selectedSegmentIndex == 0) {
            
            self.dollarView.hidden = NO;
            self.percentView.hidden = YES;
            self.itemView.hidden = YES;
            
        }else if (self.typeSegment.selectedSegmentIndex == 1){
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = NO;
            self.itemView.hidden = YES;
            
        }else{
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = YES;
            self.itemView.hidden = NO;
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(void)endText{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.dollarView.frame = CGRectMake(0, 44, 320, 328);
        self.percentView.frame = CGRectMake(0, 44, 320, 328);
    }];
    
}

- (IBAction)dollarTipDidBegin {
    [rSkybox addEventToSession:@"dollarTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.dollarView.frame = CGRectMake(0, -120, 320, 328);
    }];
}

- (IBAction)percentTipDidBegin {
    [rSkybox addEventToSession:@"percentTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.percentView.frame = CGRectMake(0, -120, 320, 328);
    }];
}
@end
