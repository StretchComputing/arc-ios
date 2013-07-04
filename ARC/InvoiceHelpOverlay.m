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
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.view.hidden = YES;
}

@end
