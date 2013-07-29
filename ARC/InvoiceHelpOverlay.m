//
//  InvoiceHelpOverlay.m
//  ARC
//
//  Created by Nick Wroblewski on 7/3/13.
//
//

#import "InvoiceHelpOverlay.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"

@interface InvoiceHelpOverlay ()

@end

@implementation InvoiceHelpOverlay

-(void)viewDidLoad{
    
    self.topOpenView.layer.borderWidth = 2.0;
    self.topOpenView.layer.borderColor = [dutchDarkBlueColor CGColor];
    
    self.stepTwoView.hidden = YES;
    self.stepThreeView.hidden = YES;
    self.stepOneView.hidden = NO;
    self.currentStep = 1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self goNextStep];
}

-(void)startNow{
    
     self.myTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(goNextStep) userInfo:nil repeats:NO];
}

-(void)goNextStep{
    
    [self.myTimer invalidate];
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(goNextStep) userInfo:nil repeats:NO];

    if (self.currentStep == 1) {
        
        self.viewOne.hidden = YES;
        self.viewTwo.hidden = NO;
        
    }else{
        [self.myTimer invalidate];
        [UIView animateWithDuration:1.0 animations:^{
            self.view.alpha = 0.0;
        }];
    }
    
    self.currentStep++;

    
}
- (void)viewDidUnload {
    [self setViewOne:nil];
    [self setViewTwo:nil];
    [super viewDidUnload];
}
@end
