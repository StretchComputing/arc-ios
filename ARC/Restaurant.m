//
//  Restaurant.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Restaurant.h"
#import "NewJSON.h"
#import "InvoiceView.h"

@interface Restaurant ()

@end

@implementation Restaurant
@synthesize nameDisplay, name, myInvoice;
@synthesize checkNumFour;
@synthesize checkNumThree;
@synthesize checkNumTwo;
@synthesize checkNumOne;
@synthesize activity;
@synthesize errorLabel;
@synthesize serverData;

-(void)viewWillAppear:(BOOL)animated{
    [self.checkNumOne becomeFirstResponder];
    self.serverData = [NSMutableData data];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([textField.text length] == 1) {
        if ([string isEqualToString:@""]) {
            return TRUE;
        }
        return FALSE;
    }else{
        [self performSelector:@selector(nextField) withObject:nil afterDelay:0.1];
        return TRUE;
    }
    
    return TRUE;
}

-(void)nextField{
    
    if ([self.checkNumOne isFirstResponder]) {
        [self.checkNumTwo becomeFirstResponder];
    }else if ([self.checkNumTwo isFirstResponder]){
        [self.checkNumThree becomeFirstResponder];
    }else if ([self.checkNumThree isFirstResponder]){
        [self.checkNumFour becomeFirstResponder];
    }
}
- (void)viewDidLoad
{
    self.checkNumOne.delegate = self;
    self.checkNumTwo.delegate = self;
    self.checkNumThree.delegate = self;
    self.checkNumFour.delegate = self;
    
    self.checkNumOne.text = @"";
    self.checkNumTwo.text = @"";
    self.checkNumThree.text = @"";
    self.checkNumFour.text = @"";
    
    
    self.nameDisplay.text = [NSString stringWithFormat:@"%@, Chicago", self.name];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)submit:(id)sender {
    
    self.errorLabel.text = @"";
    
    if ([self.checkNumOne.text isEqualToString:@""] || [self.checkNumTwo.text isEqualToString:@""] || [self.checkNumThree.text isEqualToString:@""] || [self.checkNumFour.text isEqualToString:@""]) {
        
        self.errorLabel.text = @"*Please enter the full check number";
    }else{
        
        @try{
            
            NSString *invoiceNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
            NSString *tmpUrl = [NSString stringWithFormat:@"http://68.57.205.193:8700/rest/v1/Invoices/%@", invoiceNumber];
                        
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
            [request setHTTPMethod: @"GET"];
            
            [self.activity startAnimating];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
            
        }
        @catch (NSException *e) {
            
            //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
            
        }

        
    }
       
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self.activity stopAnimating];
    
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success) {
       
        self.myInvoice = [[Invoice alloc] init];
        
        NSDictionary *theInvoice = [response valueForKey:@"Invoice"];
        
        self.myInvoice.invoiceId = [[theInvoice valueForKey:@"Id"] intValue];
        self.myInvoice.status = [theInvoice valueForKey:@"Status"];
        self.myInvoice.number = [theInvoice valueForKey:@"Number"];
        self.myInvoice.merchantId = [[theInvoice valueForKey:@"MerchantId"] intValue];
        self.myInvoice.customerId = [[theInvoice valueForKey:@"CustomerId"] intValue];
        self.myInvoice.posi = [theInvoice valueForKey:@"POSI"];
        
        self.myInvoice.baseAmount = [[theInvoice valueForKey:@"BaseAmount"] doubleValue];
        self.myInvoice.serviceCharge = [[theInvoice valueForKey:@"ServiceCharge"] doubleValue];
        self.myInvoice.tax = [[theInvoice valueForKey:@"Tax"] doubleValue];
        self.myInvoice.discount = [[theInvoice valueForKey:@"Discount"] doubleValue];
        self.myInvoice.additionalCharge = [[theInvoice valueForKey:@"AdditionalCharge"] doubleValue];
        
        self.myInvoice.dateCreated = [theInvoice valueForKey:@"DateCreated"];
        
        self.myInvoice.tags = [NSArray arrayWithArray:[theInvoice valueForKey:@"Tags"]];
        self.myInvoice.items = [NSArray arrayWithArray:[theInvoice valueForKey:@"Items"]];


        
        [self performSegueWithIdentifier:@"goInvoice" sender:self];
        
    }else{
        self.errorLabel.text = @"*Error finding invoice.";
    }
    
   
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.errorLabel.text = @"*Internet connection error.";
    [self.activity stopAnimating];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"goInvoice"]) {
        
        InvoiceView *nextView = [segue destinationViewController];
        nextView.myInvoice = self.myInvoice;
        
        
    } 
}


@end
