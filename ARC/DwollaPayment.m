//
//  DwollaPayment.m
//  ARC
//
//  Created by Nick Wroblewski on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaPayment.h"
#import <QuartzCore/QuartzCore.h>
#import "NewJSON.h"
#import "ReviewTransaction.h"
#import "ArcAppDelegate.h"

@interface DwollaPayment ()

@end

@implementation DwollaPayment
@synthesize submitButton;
@synthesize notesText;
@synthesize checkNumFour;
@synthesize checkNumThree;
@synthesize checkNumTwo;
@synthesize checkNumOne, serverData, errorLabel, activity, fundingSources, fundingSourceStatus, selectedFundingSourceId, gratuity, totalAmount, invoiceId, fromDwolla, dwollaSuccess;


- (void)viewDidLoad
{

    
    self.fundingSourceStatus = @"";
    self.serverData = [NSMutableData data];
    
    self.notesText.delegate = self;
    self.checkNumOne.delegate = self;
    self.checkNumTwo.delegate = self;
    self.checkNumThree.delegate = self;
    self.checkNumFour.delegate = self;
    
    self.checkNumOne.text = @" ";
    self.checkNumTwo.text = @" ";
    self.checkNumThree.text = @" ";
    self.checkNumFour.text = @" ";
    
    self.checkNumOne.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumTwo.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumThree.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumFour.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.notesText.text = @"Transaction Notes (*optional):";
    
    self.notesText.layer.masksToBounds = YES;
    self.notesText.layer.cornerRadius = 5.0;
        
      
    dispatch_queue_t queue = dispatch_queue_create("dwolla.task", NULL);
    
    dispatch_async(queue,^{
        
        @try {
            DwollaFundingSources* sources = [DwollaAPI getFundingSources];
            
            //An array of DwollaFundingSource* objects
            self.fundingSources = [NSMutableArray arrayWithArray:[sources getAll]];
            self.fundingSourceStatus = @"success";
        }
        @catch (NSException *exception) {
            self.fundingSourceStatus = @"failed";
        }
        
        
    });
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [self.checkNumOne becomeFirstResponder];
    self.serverData = [NSMutableData data];
    
    if (self.fromDwolla) {
        self.fromDwolla = NO;
        
        if (self.dwollaSuccess) {
            
            //Get the Funding Sources
            
            dispatch_queue_t queue = dispatch_queue_create("dwolla.task", NULL);
            dispatch_queue_t main = dispatch_get_main_queue();
            
            dispatch_async(queue,^{
                
                @try {
                    DwollaFundingSources* sources = [DwollaAPI getFundingSources];
                    
                    //An array of DwollaFundingSource* objects
                    self.fundingSources = [NSMutableArray arrayWithArray:[sources getAll]];
                    self.fundingSourceStatus = @"success";
                }
                @catch (NSException *exception) {
                    self.fundingSourceStatus = @"failed";
                    
                }
                
                dispatch_async(main,^{
                    [self submit:nil];
                });

                
                
            });
    
            
        }else{
            
            [self.activity stopAnimating];
        }
    }
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([textField.text isEqualToString:@" "]) {
        
        if ([string isEqualToString:@""]) {
            
            [self performSelector:@selector(previousField) withObject:nil afterDelay:0.1];
            
        }else{
            textField.text = string;
            [self performSelector:@selector(nextField) withObject:nil afterDelay:0.1];
        }
    }else{
        
        if ([string isEqualToString:@""]) {
            textField.text = @" ";
        }
    }
    
    return FALSE;
}


-(void)previousField{
    
    if ([self.checkNumFour isFirstResponder]) {
        [self.checkNumThree becomeFirstResponder];
        self.checkNumThree.text = @" ";
    }else if ([self.checkNumThree isFirstResponder]){
        [self.checkNumTwo becomeFirstResponder];
        self.checkNumTwo.text = @" ";
        
    }else if ([self.checkNumTwo isFirstResponder]){
        [self.checkNumOne becomeFirstResponder];
        self.checkNumOne.text = @" ";
        
    }
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.notesText.text isEqualToString:@"Transaction Notes (*optional):"]){
		self.notesText.text = @"";
	}
}



- (IBAction)submit:(id)sender {
    
    self.errorLabel.text = @"";    
        
        if ([self.checkNumOne.text isEqualToString:@""] || [self.checkNumTwo.text isEqualToString:@""] || [self.checkNumThree.text isEqualToString:@""] || [self.checkNumFour.text isEqualToString:@""]) {
            
            self.errorLabel.text = @"*Please enter your full pin number.";
        }else{
            
            NSString *token = @"";
            @try {
                token = [DwollaAPI getAccessToken];
            }
            @catch (NSException *exception) {
                token = nil;
            }
          
            
            if ((token == nil) || [token isEqualToString:@""]) {
                //get the token
                [self.activity startAnimating];
                
  
                
                [self performSegueWithIdentifier:@"confirmDwolla" sender:self];

                
            }else{
                
                
                if ([self.fundingSourceStatus isEqualToString:@"success"]) {

                    if ([self.fundingSources count] == 0) {
                        
                    }else if ([self.fundingSources count] == 1){
                        
                        DwollaFundingSource *tmp = [self.fundingSources objectAtIndex:0];
                        self.selectedFundingSourceId = [tmp getSourceID];
                        [self performSelector:@selector(createPayment)];
                        
                    }else{
                        //display funding sources
                        
                        UIActionSheet *fundingAction = [[UIActionSheet alloc] initWithTitle:@"Select A Funding Source" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                        
                        for (int i = 0; i < [self.fundingSources count]; i++) {
                            DwollaFundingSource *tmp = [self.fundingSources objectAtIndex:i];
                            
                            [fundingAction addButtonWithTitle:[tmp getName]];
                        }
                        [fundingAction addButtonWithTitle:@"Cancel"];
                        
                        [fundingAction setCancelButtonIndex: [self.fundingSources count]];
                        
                        [fundingAction showInView:self.view];
                        
                        
                    }
                   
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dwolla Error" message:@"Unable to obtain Dwolla Funding Sources" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }


                
            }
                        
        }

}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [self.fundingSources count]) {
        //Cancel
    }else{
        
        DwollaFundingSource *tmp = [self.fundingSources objectAtIndex:buttonIndex];
        self.selectedFundingSourceId = [tmp getSourceID];
        [self performSelector:@selector(createPayment)];
    }
    
}
-(void)createPayment{
    
    @try{        
        [self.activity startAnimating];
        
         NSString *pinNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
        
        NSString *dwollaToken = [DwollaAPI getAccessToken];
        
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        //*Testing Only*
        NSNumber *amount = [NSNumber numberWithDouble:1.0];
        //NSNumber *amount = [NSNumber numberWithDouble:self.totalAmount];
        [ tempDictionary setObject:amount forKey:@"Amount"];
        
        [ tempDictionary setObject:dwollaToken forKey:@"AuthenticationToken"];
        [ tempDictionary setObject:self.selectedFundingSourceId forKey:@"FundSourceAccount"];

        double gratDouble = self.gratuity/self.totalAmount;
        
        //*Testing Only* -------- SEND EMPTY STRINGS for OPTIONAL PARAMETERS
        //NSNumber *grat = [NSNumber numberWithDouble:gratDouble];
        NSNumber *grat = [NSNumber numberWithDouble:0.0];
        [ tempDictionary setObject:grat forKey:@"Gratuity"];
        
        if (![self.notesText.text isEqualToString:@""] && ![self.notesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
            [ tempDictionary setObject:self.notesText.text forKey:@"Notes"];
        }else{
            [ tempDictionary setObject:@"" forKey:@"Notes"];
        }
        
                
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        NSNumber *tmpId = [NSNumber numberWithInt:[customerId intValue]];
        [ tempDictionary setObject:tmpId forKey:@"CustomerId"];
        
        [ tempDictionary setObject:@"" forKey:@"Tag"];
        [ tempDictionary setObject:@"" forKey:@"Expiration"];
		
        NSNumber *invoice = [NSNumber numberWithInt:self.invoiceId];
        [ tempDictionary setObject:invoice forKey:@"InvoiceId"];

        [ tempDictionary setObject:pinNumber forKey:@"Pin"];
        [ tempDictionary setObject:@"DWOLLA" forKey:@"Type"];

        
  
        
        
		loginDict = tempDictionary;

		NSString *requestString = [NSString stringWithFormat:@"%@", [loginDict JSONFragment], nil];
        
        NSLog(@"RequestString: %@", requestString);
        
		NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *tmpUrl = [NSString stringWithString:@"http://68.57.205.193:8700/rest/v1/payments"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setHTTPMethod: @"POST"];
		[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
        
        
        
    }
    @catch (NSException *e) {
        
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self.activity stopAnimating];
    
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"ReturnString: %@", returnString);
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success) {
        
        self.errorLabel.text = @"";

        [self performSegueWithIdentifier:@"reviewTransaction" sender:self];
        
        
    }else{
        self.errorLabel.text = @"*Error submitting payment.";
    }
    
    
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.errorLabel.text = @"*Internet connection error.";
    [self.activity stopAnimating];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"reviewTransaction"]) {
        
        ReviewTransaction *next = [segue destinationViewController];
        next.invoiceId = self.invoiceId;
    } 
}

@end
