//
//  Restaurant.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "Restaurant.h"
#import "InvoiceView.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"

#import "HomeNavigationController.h"

@interface Restaurant ()

@end

@implementation Restaurant
@synthesize checkNumFive;
@synthesize checkNumSix;


-(void)viewWillAppear:(BOOL)animated{
    
   
    
    @try {
        
        /*
        if (self.wentInvoice) {
            self.wentInvoice = NO;
            [self.checkNumFour becomeFirstResponder];
        }else{
            [self.checkNumOne becomeFirstResponder];
            
        }
         */
        [self.hiddenText becomeFirstResponder];
        
        self.serverData = [NSMutableData data];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)setValues:(NSString *)newString{

    
    if ([newString length] < 7) {
        
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
        
        @try {
            self.checkNumFive.text = [newString substringWithRange:NSMakeRange(4, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumFive.text = @"";
        }
        
        @try {
            self.checkNumSix.text = [newString substringWithRange:NSMakeRange(5, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumSix.text = @"";
        }
       
        
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
        
   // NSLog(@"NewString: %@", string);
    //NSLog(@"RangeLength: %d", range.length);
    //NSLog(@"RangeLoc: %d", range.location);
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        
   
        if (newLength > 6) {
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
        [rSkybox sendClientLog:@"Restaurant.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)previousField{

    @try {
        
        if ([self.checkNumSix isFirstResponder]) {
            [self.checkNumFive becomeFirstResponder];
            self.checkNumFive.text = @" ";
        }else if ([self.checkNumFive isFirstResponder]) {
            [self.checkNumFour becomeFirstResponder];
            self.checkNumFour.text = @" ";
        }if ([self.checkNumFour isFirstResponder]) {
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
        [rSkybox sendClientLog:@"Restaurant.previousField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
        }else if ([self.checkNumFour isFirstResponder]){
            [self.checkNumFive becomeFirstResponder];
        }else if ([self.checkNumFive isFirstResponder]){
            [self.checkNumSix becomeFirstResponder];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.nextField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)viewDidLoad
{
    @try {
        
       
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Invoice #"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Invoice #"];
		self.navigationItem.backBarButtonItem = temp;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceComplete:) name:@"invoiceNotification" object:nil];
        
        self.checkHelpImageView.hidden = YES;
        
        self.checkNumOne.delegate = self;
        self.checkNumTwo.delegate = self;
        self.checkNumThree.delegate = self;
        self.checkNumFour.delegate = self;
        self.checkNumFive.delegate = self;
        self.checkNumSix.delegate = self;
        
        self.hiddenText = [[UITextField alloc] init];
        self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
        self.hiddenText.delegate = self;
        self.hiddenText.text = @"";
        [self.view addSubview:self.hiddenText];
        

        
        self.checkNumOne.text = @"";
        self.checkNumTwo.text = @"";
        self.checkNumThree.text = @"";
        self.checkNumFour.text = @"";
        self.checkNumFive.text = @"";
        self.checkNumSix.text = @"";

        
        self.checkNumOne.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:23];
        self.checkNumTwo.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:23];
        self.checkNumThree.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:23];
        self.checkNumFour.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:23];
        self.checkNumFive.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:23];
        self.checkNumSix.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:23];

        
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
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}





- (IBAction)submit:(id)sender {
    @try {
        
        self.errorLabel.text = @"";
        
        if ([self.checkNumOne.text isEqualToString:@" "] || [self.checkNumTwo.text isEqualToString:@" "] || [self.checkNumThree.text isEqualToString:@" "] || [self.checkNumFour.text isEqualToString:@" "]) {
            
            self.errorLabel.text = @"*Please enter the full check number";
        }else{
            
            @try{
                [self.activity startAnimating];
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                
                NSString *invoiceNumber = @"";
                
                if ([self.checkNumFive.text isEqualToString:@" "]) {
                       invoiceNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
                }else if ([self.checkNumSix.text isEqualToString:@" "]){
                    invoiceNumber = [NSString stringWithFormat:@"%@%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text, self.checkNumFive.text];
                }else{
                    invoiceNumber = [NSString stringWithFormat:@"%@%@%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text, self.checkNumFive.text, self.checkNumSix.text];
                }
                
             
                
                
                [tempDictionary setValue:invoiceNumber forKey:@"invoiceNumber"];
                [tempDictionary setValue:self.merchantId forKey:@"merchantId"];
                
                NSDictionary *loginDict = [[NSDictionary alloc] init];
                loginDict = tempDictionary;
                
                self.submitButton.enabled = NO;
            
                ArcClient *client = [[ArcClient alloc] init];
                [client getInvoice:loginDict];
            }
            @catch (NSException *e) {
                //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];                
            }
            
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.submit" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)invoiceComplete:(NSNotification *)notification{
    @try {
        
        [self.activity stopAnimating];
        self.submitButton.enabled = YES;

        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            NSDictionary *theInvoice = [[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] objectAtIndex:0];
            
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
            self.myInvoice.payments = [NSArray arrayWithArray:[theInvoice valueForKey:@"Payments"]];
            
            self.wentInvoice = YES;
            [self performSegueWithIdentifier:@"goInvoice" sender:self];
            
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            // TODO create static values maybe in ArcClient
            if(errorCode == CANNOT_GET_INVOICE) {
                errorMsg = @"Can not find invoice.";
            } else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            self.errorLabel.text = errorMsg;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.invoiceComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"goInvoice"]) {
            
            InvoiceView *nextView = [segue destinationViewController];
            nextView.myInvoice = self.myInvoice;
            
            
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}

- (IBAction)checkNumberHelp {
    @try {
        
        self.helpShowing = YES;
        
        self.checkHelpImageView.hidden = NO;
        [self.checkNumOne resignFirstResponder];
        [self.checkNumTwo resignFirstResponder];
        [self.checkNumThree resignFirstResponder];
        [self.checkNumFour resignFirstResponder];
        [self.hiddenText resignFirstResponder];
        
        self.checkNumOne.enabled = NO;
        self.checkNumTwo.enabled = NO;
        self.checkNumThree.enabled = NO;
        self.checkNumFour.enabled = NO;
        
        self.submitButton.enabled = NO;
        self.nameDisplay.hidden = YES;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.checkNumberHelp" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    @try {
        
        if (self.helpShowing) {
            self.helpShowing = NO;
            self.checkHelpImageView.hidden = YES;
            
            self.checkNumOne.enabled = YES;
            self.checkNumTwo.enabled = YES;
            self.checkNumThree.enabled = YES;
            self.checkNumFour.enabled = YES;
            
            [self.checkNumOne becomeFirstResponder];
            [self.hiddenText becomeFirstResponder];
            
            self.nameDisplay.hidden = NO;
            self.submitButton.enabled = YES;
            
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.touchesBegan" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}


- (void)viewDidUnload {
    [self setSubmitButton:nil];
    [super viewDidUnload];
}
@end
