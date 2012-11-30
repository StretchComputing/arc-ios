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
#import "Invoice.h"
#import "ArcUtility.h"
#import "EditCreditCard.h"

@interface CreditCardPayment ()

@end

@implementation CreditCardPayment


-(void)viewDidAppear:(BOOL)animated{
    
    if (self.didEditCard) {
        self.didEditCard = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your card was successfully edited, please try your payment again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)viewDidLoad
{
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Credit Card"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Credit Card"];
		self.navigationItem.backBarButtonItem = temp;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:@"createPaymentNotification" object:nil];
        
        self.fundingSourceStatus = @"";
        self.serverData = [NSMutableData data];
        
        self.notesText.delegate = self;
        self.checkNumOne.delegate = self;
        self.checkNumTwo.delegate = self;
        self.checkNumThree.delegate = self;
        self.checkNumFour.delegate = self;
        
        self.hiddenText = [[UITextField alloc] init];
        self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
        self.hiddenText.delegate = self;
        self.hiddenText.text = @"";
        [self.view addSubview:self.hiddenText];
        
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
        

        self.totalPaymentText.text = [NSString stringWithFormat:@"$%.2f", (self.myInvoice.basePaymentAmount + self.myInvoice.gratuity)];
        
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
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        
        
        if (newLength > 4) {
            return FALSE;
        }else{
            
            [self setValues:[self.hiddenText.text stringByReplacingCharactersInRange:range withString:string]];
            return TRUE;
            
        }
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
            
            self.errorLabel.text = @"*Please enter your full pin.";
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
                 
            NSNumber *invoiceAmount = [NSNumber numberWithDouble:[self.myInvoice amountDue]];
            [ tempDictionary setObject:invoiceAmount forKey:@"InvoiceAmount"];
            
            NSNumber *amount = [NSNumber numberWithDouble:[self.myInvoice basePaymentAmount]];
            [ tempDictionary setObject:amount forKey:@"Amount"];
            
            [ tempDictionary setObject:@"" forKey:@"AuthenticationToken"];
            [ tempDictionary setObject:ccNumber forKey:@"FundSourceAccount"];
            
            NSNumber *grat = [NSNumber numberWithDouble:[self.myInvoice gratuity]];
            [tempDictionary setObject:grat forKey:@"Gratuity"];
            
            if (![self.notesText.text isEqualToString:@""] && ![self.notesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
                [ tempDictionary setObject:self.notesText.text forKey:@"Notes"];
            }else{
                [ tempDictionary setObject:@"" forKey:@"Notes"];
            }
            
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *customerId = [mainDelegate getCustomerId];
            [ tempDictionary setObject:customerId forKey:@"CustomerId"];
            
            [ tempDictionary setObject:@"" forKey:@"Tag"];
            
            [ tempDictionary setObject:self.creditCardExpiration forKey:@"Expiration"];
            
            NSString *invoiceIdString = [NSString stringWithFormat:@"%d", self.myInvoice.invoiceId];
            [ tempDictionary setObject:invoiceIdString forKey:@"InvoiceId"];
            NSString *merchantIdString = [NSString stringWithFormat:@"%d", self.myInvoice.merchantId];
            [ tempDictionary setObject:merchantIdString forKey:@"MerchantId"];
            
            [ tempDictionary setObject:ccSecurityCode forKey:@"Pin"];
            
            if ([[self.creditCardSample substringToIndex:1] isEqualToString:@"C"]) {
                [ tempDictionary setObject:@"CREDIT" forKey:@"Type"];
            }else{
                [ tempDictionary setObject:@"DEBIT" forKey:@"Type"];
            }
            
            NSString *cardType = [ArcUtility getCardTypeForNumber:ccNumber];
            
            [ tempDictionary setObject:cardType forKey:@"CardType"];
            
            //For Metrics
            [tempDictionary setObject:self.myInvoice.splitType forKey:@"SplitType"];
            [tempDictionary setObject:self.myInvoice.splitPercent forKey:@"PercentEntry"];
            [tempDictionary setObject:self.myInvoice.tipEntry forKey:@"TipEntry"];

            
            loginDict = tempDictionary;
            self.payButton.enabled = NO;
            self.navigationItem.hidesBackButton = YES;
            ArcClient *client = [[ArcClient alloc] init];
            [client createPayment:loginDict];

        }else{
            self.errorLabel.text = @"*Invalid PIN.";
            
            self.checkNumOne.text = @"";
            self.checkNumTwo.text = @"";
            self.checkNumThree.text = @"";
            self.checkNumFour.text = @"";
            
            self.hiddenText.text = @"";
        }
        
    }
    @catch (NSException *e) {
        self.errorLabel.text = @"*Error retreiving credit card.";

        [rSkybox sendClientLog:@"CreditCardPayment.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)paymentComplete:(NSNotification *)notification{
    @try {
        BOOL editCardOption = NO;

        self.payButton.enabled = YES;
        self.navigationItem.hidesBackButton = NO;

        [rSkybox addEventToSession:@"creditCardPaymentComplete"];
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        NSString *errorMsg= @"";
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            BOOL paidInFull = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"InvoicePaid"] boolValue];
            if(paidInFull) [self.myInvoice setPaidInFull:paidInFull];
            int paymentId = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"PaymentId"] intValue];
            [self.myInvoice setPaymentId:paymentId];
            
            [self performSegueWithIdentifier:@"reviewCreditCardTransaction" sender:self];
        } else if([status isEqualToString:@"error"]){
            
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == CANNOT_GET_PAYMENT_AUTHORIZATION) {
                errorMsg = @"Credit card not approved.";
                editCardOption = YES;
            } else if(errorCode == FAILED_TO_VALIDATE_CARD) {
                // TODO need explanation from Jim to put proper error msg
                errorMsg = @"Failed to validate credit card";
                editCardOption = YES;
            } else if (errorCode == FIELD_FORMAT_ERROR){
                errorMsg = @"Invalid Credit Card Field Format";
                editCardOption = YES;
            }else if(errorCode == INVALID_ACCOUNT_NUMBER) {
                // TODO need explanation from Jim to put proper error msg
                errorMsg = @"Invalid credit/debit card number";
                editCardOption = YES;
            } else if(errorCode == MERCHANT_CANNOT_ACCEPT_PAYMENT_TYPE) {
                // TODO put exact type of credit card not accepted in msg -- Visa, MasterCard, etc.
                errorMsg = @"Merchant does not accept credit/debit card";
            } else if(errorCode == OVER_PAID) {
                errorMsg = @"Over payment. Please check invoice and try again.";
            } else if(errorCode == INVALID_AMOUNT) {
                errorMsg = @"Invalid amount. Please re-enter payment and try again.";
            } else if(errorCode == INVALID_EXPIRATION_DATE) {
                errorMsg = @"Invalid expiration date.";
                editCardOption = YES;
            }  else if (errorCode == UNKOWN_ISIS_ERROR){
                editCardOption = YES;
                errorMsg = @"Arc Error, Try Again.";
            }
            else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            self.errorLabel.text = errorMsg;
        }
        
        if (editCardOption) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your payment may have failed due to invalid credit card information.  Would you like to view/edit the card you tried to make this payment with?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"View/Edit", nil];
            [alert show];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.paymentComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"editCard" sender:self];
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    @try {
        
        // Any new character added is passed in as the "text" parameter
        if ([text isEqualToString:@"\n"]) {
            // Be sure to test for equality using the "isEqualToString" message
            [textView resignFirstResponder];
            
            if ([self.notesText.text isEqualToString:@""]){
                self.notesText.text = @"Transaction Notes (*optional):";
            }
            
            [self.hiddenText becomeFirstResponder];

            
            
            // Return FALSE so that the final '\n' character doesn't get added
            return FALSE;
        }else{
            if ([self.notesText.text length] >= 500) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
        }
        // For any other character return TRUE so that the text gets added to the view
        return TRUE;
    }
    @catch (NSException *e) {
        
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"reviewCreditCardTransaction"]) {
            
            ReviewTransaction *next = [segue destinationViewController];
            next.myInvoice = self.myInvoice;
        }
        
        if ([[segue identifier] isEqualToString:@"editCard"]) {
            
            EditCreditCard *controller = [segue destinationViewController];
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;
            controller.isFromPayment = YES;
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end