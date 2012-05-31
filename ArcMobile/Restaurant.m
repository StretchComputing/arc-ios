//
//  Restaurant.m
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Restaurant.h"
#import "ServerAPI.h"
#import "InvoiceDetail.h"

@interface Restaurant ()

@end

@implementation Restaurant
@synthesize name, invoiceNumber;

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
    self.title = self.name;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void)submitAction{
    
        [self performSelectorInBackground:@selector(runRequest) withObject:nil];
    
}


-(void)runRequest{
    @autoreleasepool {
        
        NSDictionary *response = [ServerAPI getInvoiceFromNumber:self.invoiceNumber.text andRestaurantId:@""];
        
        [self performSelectorOnMainThread:@selector(doneRequest:) withObject:[response valueForKey:@"values"] waitUntilDone:NO];

    }
    
}

-(void)doneRequest:(NSDictionary *)response{
    
    InvoiceDetail *invoice = [[InvoiceDetail alloc] init];
    
    invoice.merchantId = [response valueForKey:@"MerchantId"];
    invoice.invoiceId = [response valueForKey:@"InvoiceId"];
    invoice.totalCost = [[response valueForKey:@"Total"] stringValue];
    
    NSLog(@"Cost: %@", invoice.totalCost);
    
    [self.navigationController pushViewController:invoice animated:YES];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
