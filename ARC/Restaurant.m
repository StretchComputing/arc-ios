//
//  Restaurant.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Restaurant.h"
#import "InvoiceView.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>

@interface Restaurant ()

@end

@implementation Restaurant


-(void)viewWillAppear:(BOOL)animated{
    
    if (self.wentInvoice) {
        self.wentInvoice = NO;
        [self.checkNumFour becomeFirstResponder];
    }else{
        [self.checkNumOne becomeFirstResponder];

    }
    
    self.serverData = [NSMutableData data];

}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
        
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
- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceComplete:) name:@"invoiceNotification" object:nil];
    
    self.checkHelpImageView.hidden = YES;
    
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

    
    self.nameDisplay.text = [NSString stringWithFormat:@"%@", self.name];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
}

- (IBAction)submit:(id)sender {
    
    self.errorLabel.text = @"";
    
    if ([self.checkNumOne.text isEqualToString:@" "] || [self.checkNumTwo.text isEqualToString:@" "] || [self.checkNumThree.text isEqualToString:@" "] || [self.checkNumFour.text isEqualToString:@" "]) {
        
        self.errorLabel.text = @"*Please enter the full check number";
    }else{
        
        @try{            
            [self.activity startAnimating];
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            
            
            NSString *invoiceNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
            
            
            [tempDictionary setValue:invoiceNumber forKey:@"invoiceNumber"];
            [tempDictionary setValue:self.merchantId forKey:@"merchantId"];
            
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            loginDict = tempDictionary;
            ArcClient *client = [[ArcClient alloc] init];
            [client getInvoice:loginDict];
        }
        @catch (NSException *e) {
            
            //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
            
        }

        
    }
       
}

-(void)invoiceComplete:(NSNotification *)notification{
    
    [self.activity stopAnimating];

    NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
    NSString *status = [responseInfo valueForKey:@"status"];
    
    if ([status isEqualToString:@"1"]) {
        //success
            
        NSDictionary *theInvoice = [[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Invoice"];
                
        self.myInvoice = [[Invoice alloc] init];
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
        
        self.wentInvoice = YES;
        [self performSegueWithIdentifier:@"goInvoice" sender:self];
        
    }else{
        
        self.errorLabel.text = @"*Internet connection error.";
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"goInvoice"]) {
        
        InvoiceView *nextView = [segue destinationViewController];
        nextView.myInvoice = self.myInvoice;
                
        
    } 
}

- (IBAction)checkNumberHelp {
    
    self.helpShowing = YES;
    
    self.checkHelpImageView.hidden = NO;
    [self.checkNumOne resignFirstResponder];
    [self.checkNumTwo resignFirstResponder];
    [self.checkNumThree resignFirstResponder];
    [self.checkNumFour resignFirstResponder];
    
    self.checkNumOne.enabled = NO;
    self.checkNumTwo.enabled = NO;
    self.checkNumThree.enabled = NO;
    self.checkNumFour.enabled = NO;
    
    self.submitButton.enabled = NO;
    self.nameDisplay.hidden = YES;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.helpShowing) {
        self.helpShowing = NO;
        self.checkHelpImageView.hidden = YES;
        
        self.checkNumOne.enabled = YES;
        self.checkNumTwo.enabled = YES;
        self.checkNumThree.enabled = YES;
        self.checkNumFour.enabled = YES;
        
        [self.checkNumOne becomeFirstResponder];
        
        self.nameDisplay.hidden = NO;
        self.submitButton.enabled = YES;


    }
   
    
}

- (void)viewDidUnload {
    [self setSubmitButton:nil];
    [super viewDidUnload];
}
@end
