//
//  InvoiceDetail.m
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvoiceDetail.h"

@interface InvoiceDetail ()

@end

@implementation InvoiceDetail
@synthesize invoiceId, merchantId, totalCost, displayCost;



- (void)viewDidLoad
{
    self.displayCost.text = self.totalCost;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)submitPayment{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
