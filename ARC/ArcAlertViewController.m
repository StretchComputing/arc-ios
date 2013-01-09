//
//  ArcAlertViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 1/8/13.
//
//

#import "ArcAlertViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ArcAlertViewController ()

@end

@implementation ArcAlertViewController

-(void)viewDidLoad{
    
    self.alertViewTextView.userInteractionEnabled = NO;
    
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 2.0;
    self.alertView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.alertView.layer.borderWidth = 2.0;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.alertView.bounds;
    self.alertView.backgroundColor = [UIColor clearColor];
    double x = 1.2;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.alertView.layer insertSublayer:gradient atIndex:0];

}

-(void)doInitSetup{
    self.alertViewTextView.text = self.alertText;
    
    CGRect frame = self.alertViewTextView.frame;
    frame.size.height = self.alertViewHeight;
    self.alertViewTextView.frame = frame;
    
    CGRect frame1 = self.alertView.frame;
    frame1.size.height = self.alertViewHeight + 50;
    self.alertView.frame = frame1;
}

-(void)okAlertAction{
    
    id mainViewController = (UIViewController *)[self.view.superview nextResponder];
    
    if ([mainViewController respondsToSelector:@selector(hideAlert)]) {
        [mainViewController hideAlert];
    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self okAlertAction];
}
@end
