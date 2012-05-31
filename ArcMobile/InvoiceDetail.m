//
//  InvoiceDetail.m
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvoiceDetail.h"
#import "ServerAPI.h"
#import "AppDelegate.h"

@interface InvoiceDetail ()

@end

@implementation InvoiceDetail
@synthesize invoiceId, merchantId, totalCost, displayCost, tipField, totalPlusTip;



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
 
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [ServerAPI updateInvoiceWithId:self.invoiceId andRestaurantId:merchantId gratuity:self.tipField.text paymentMethod:@"Dwolla" percentage:@"100" invoiceStatus:@"paid" userToken:mainDelegate.token];
}

-(void)endText{
    
    @try {
        [self.tipField resignFirstResponder];
        
        float cost = [self.totalCost floatValue];
        float tip = [self.tipField.text floatValue];
        
        int total = tip + cost;
        
        self.totalPlusTip.text = [NSString stringWithFormat:@"%f", total];
        
    }
    @catch (NSException *exception) {
        
    }
 

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
