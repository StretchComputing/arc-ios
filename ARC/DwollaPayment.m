//
//  DwollaPayment.m
//  ARC
//
//  Created by Nick Wroblewski on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaPayment.h"
#import <QuartzCore/QuartzCore.h>

@interface DwollaPayment ()

@end

@implementation DwollaPayment
@synthesize notesText;
@synthesize checkNumFour;
@synthesize checkNumThree;
@synthesize checkNumTwo;
@synthesize checkNumOne, serverData, errorLabel, activity;

- (void)viewDidLoad
{
    self.serverData = [NSMutableData data];
    
    self.notesText.delegate = self;
    self.checkNumOne.delegate = self;
    self.checkNumTwo.delegate = self;
    self.checkNumThree.delegate = self;
    self.checkNumFour.delegate = self;
    
    self.checkNumOne.text = @"";
    self.checkNumTwo.text = @"";
    self.checkNumThree.text = @"";
    self.checkNumFour.text = @"";
    
    self.notesText.text = @"Transaction Notes (*optional):";
    
    self.notesText.layer.masksToBounds = YES;
    self.notesText.layer.cornerRadius = 5.0;
    
        
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


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
        
        @try{
            
            NSString *pinNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
            
            /*
            NSString *tmpUrl = [NSString stringWithFormat:@"http://68.57.205.193:8700/rest/v1/Invoices/%@", invoiceNumber];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
            [request setHTTPMethod: @"GET"];
            
            [self.activity startAnimating];
             self.serverData = [NSMutableData data];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
             */
            
        }
        @catch (NSException *e) {
            
            //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
            
        }
        
        
    }
    

    
}



- (void)viewDidUnload {
    [self setNotesText:nil];
    [super viewDidUnload];
}
@end
