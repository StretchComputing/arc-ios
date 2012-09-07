//
//  CreditCardPayment.m
//  ARC
//
//  Created by Nick Wroblewski on 7/4/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "CreditCardPayment.h"
#import <QuartzCore/QuartzCore.h>
#import "ReviewTransaction.h"
#import "ArcAppDelegate.h"
#import "FBEncryptorAES.h"
#import "ArcClient.h"
#import "rSkybox.h"

@interface CreditCardPayment ()

@end

@implementation CreditCardPayment



- (void)viewDidLoad
{
    @try {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:@"createPaymentNotification" object:nil];
        
        self.fundingSourceStatus = @"";
        self.serverData = [NSMutableData data];
        
        self.notesText.delegate = self;
        self.checkNumOne.delegate = self;
        self.checkNumTwo.delegate = self;
        self.checkNumThree.delegate = self;
        self.checkNumFour.delegate = self;
        
        self.hiddenText.delegate = self;
        self.hiddenText.text = @"";
        
        self.checkNumOne.text = @"";
        self.checkNumTwo.text = @"";
        self.checkNumThree.text = @"";
        self.checkNumFour.text = @"";
        
        self.checkNumOne.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
        self.checkNumTwo.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
        self.checkNumThree.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
        self.checkNumFour.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
        self.notesText.text = @"Transaction Notes (*optional):";
        
        self.notesText.layer.masksToBounds = YES;
        self.notesText.layer.cornerRadius = 5.0;
        
        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    @try {
        
        [self.hiddenText becomeFirstResponder];
        self.serverData = [NSMutableData data];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)setValues:(NSString *)newString{
    
    
    if ([newString length] < 5) {
        
        @try {
            self.checkNumOne.text = [newString substringWithRange:NSMakeRange(0, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumOne.text = @"";
        }
        
        @try {
            self.checkNumTwo.text = [newString substringWithRange:NSMakeRange(1, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumTwo.text = @"";
        }
        
        @try {
            self.checkNumThree.text = [newString substringWithRange:NSMakeRange(2, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumThree.text = @"";
        }
        
        @try {
            self.checkNumFour.text = [newString substringWithRange:NSMakeRange(3, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumFour.text = @"";
        }
   
        
        
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // NSLog(@"NewString: %@", string);
    //NSLog(@"RangeLength: %d", range.length);
    //NSLog(@"RangeLoc: %d", range.location);
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        
        
        if (newLength > 4) {
            return FALSE;
        }else{
            
            [self setValues:[self.hiddenText.text stringByReplacingCharactersInRange:range withString:string]];
            return TRUE;
            
        }
        /*
         if ([textField.text isEqualToString:@" "]) {
         
         if ([string isEqualToString:@""]) {
         
         [self performSelector:@selector(previousField) withObject:nil afterDelay:0.0];
         
         }else{
         textField.text = string;
         [self performSelector:@selector(nextField) withObject:nil afterDelay:0.0];
         }
         }else{
         
         if ([string isEqualToString:@""]) {
         textField.text = @" ";
         }
         }
         
         return FALSE;
         */
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardpayment.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}




-(void)previousField{
    @try {
        
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
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.previousField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)nextField{
    @try {
        
        if ([self.checkNumOne isFirstResponder]) {
            [self.checkNumTwo becomeFirstResponder];
        }else if ([self.checkNumTwo isFirstResponder]){
            [self.checkNumThree becomeFirstResponder];
        }else if ([self.checkNumThree isFirstResponder]){
            [self.checkNumFour becomeFirstResponder];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.nextField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    @try {
        
        if ([self.notesText.text isEqualToString:@"Transaction Notes (*optional):"]){
            self.notesText.text = @"";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.textViewDidBeginEditing" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (IBAction)submit:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"submitForCreditCardPayment"];
        
        self.errorLabel.text = @"";
        
        if ([self.checkNumOne.text isEqualToString:@""] || [self.checkNumTwo.text isEqualToString:@""] || [self.checkNumThree.text isEqualToString:@""] || [self.checkNumFour.text isEqualToString:@""]) {
            
            self.errorLabel.text = @"*Please enter your full pin number.";
        }else{
            
            [self performSelector:@selector(createPayment)];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.submit" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



-(void)createPayment{
    @try{        
        
        NSString *pinNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
        
        NSString *ccNumber = [FBEncryptorAES decryptBase64String:self.creditCardNumber keyString:pinNumber];
        
        NSString *ccSecurityCode = [FBEncryptorAES decryptBase64String:self.creditCardSecurityCode keyString:pinNumber];
        
      
        if (ccNumber && ([ccNumber length] > 0)) {
            
            [self.activity startAnimating];

            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            
            
            //*Testing Only*
            NSNumber *amount = @1.0;
            //NSNumber *amount = [NSNumber numberWithDouble:self.totalAmount];
            [ tempDictionary setObject:amount forKey:@"Amount"];
            
            [ tempDictionary setObject:@"" forKey:@"AuthenticationToken"];
            [ tempDictionary setObject:ccNumber forKey:@"FundSourceAccount"];
            
            double gratDouble = self.gratuity/self.totalAmount;
            
            //*Testing Only* -------- SEND EMPTY STRINGS for OPTIONAL PARAMETERS
            //NSNumber *grat = [NSNumber numberWithDouble:gratDouble];
            NSNumber *grat = @0.0;
            [ tempDictionary setObject:grat forKey:@"Gratuity"];
            
            if (![self.notesText.text isEqualToString:@""] && ![self.notesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
                [ tempDictionary setObject:self.notesText.text forKey:@"Notes"];
            }else{
                [ tempDictionary setObject:@"" forKey:@"Notes"];
            }
            
            
            
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *customerId = [mainDelegate getCustomerId];
            NSNumber *tmpId = @([customerId intValue]);
            [ tempDictionary setObject:tmpId forKey:@"CustomerId"];
            
            [ tempDictionary setObject:@"" forKey:@"Tag"];
            
            [ tempDictionary setObject:self.creditCardExpiration forKey:@"Expiration"];
            
            NSNumber *invoice = @(self.invoiceId);
            [ tempDictionary setObject:invoice forKey:@"InvoiceId"];
            
            [ tempDictionary setObject:ccSecurityCode forKey:@"Pin"];
            
            if ([[self.creditCardSample substringToIndex:1] isEqualToString:@"C"]) {
                [ tempDictionary setObject:@"CREDIT" forKey:@"Type"];
            }else{
                [ tempDictionary setObject:@"DEBIT" forKey:@"Type"];
            }
            
            
            loginDict = tempDictionary;
            ArcClient *client = [[ArcClient alloc] init];
            [client createPayment:loginDict];

        }else{
            self.errorLabel.text = @"*Invalid PIN.";
        }
        
    }
    @catch (NSException *e) {
        self.errorLabel.text = @"*Error retreiving credit card.";

        [rSkybox sendClientLog:@"CreditCardPayment.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)paymentComplete:(NSNotification *)notification{
    @try {
        
        [rSkybox addEventToSession:@"creditCardPaymentComplete"];
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        if ([status isEqualToString:@"1"]) {
            //success
            self.errorLabel.text = @"";
            
            [self performSegueWithIdentifier:@"reviewTransaction" sender:self];
        }else{
            self.errorLabel.text = @"*Error submitting payment.";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.paymentComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"reviewTransaction"]) {
            
            ReviewTransaction *next = [segue destinationViewController];
            next.invoiceId = self.invoiceId;
            next.totalAmount = self.totalAmount;
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end