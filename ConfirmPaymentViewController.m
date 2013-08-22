//
//  ConfirmPaymentViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import "ConfirmPaymentViewController.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "FBEncryptorAES.h"
#import "ArcUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "ReviewTransaction.h"
#import "InvoiceView.h"
#import "MFSideMenu.h"

@interface ConfirmPaymentViewController ()

@end

@implementation ConfirmPaymentViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:@"createPaymentNotification" object:nil];

    [self.hiddenText becomeFirstResponder];

}
- (void)viewDidLoad
{
    
    [rSkybox addEventToSession:@"viewConfirmPaymentViewController"];

    self.incorrectPinCount = 0;
   
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    
    
    
    NSString *ccSample = [self.creditCardSample stringByReplacingOccurrencesOfString:@"Credit Card" withString:@""];
    self.paymentLabel.text = [NSString stringWithFormat:@"Payment:  %@", ccSample];
    
    self.confirmButton.text = @"Confirm Payment";
    self.confirmButton.textColor = [UIColor whiteColor];
    self.confirmButton.textShadowColor = [UIColor darkGrayColor];
    self.confirmButton.tintColor = dutchGreenColor;
    
    self.myTotalLabel.text = [NSString stringWithFormat:@"My Total: $%.2f", self.myInvoice.basePaymentAmount + self.myInvoice.gratuity];
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.hiddenText = [[UITextField alloc] init];
    self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
    self.hiddenText.delegate = self;
    self.hiddenText.text = @"";
    [self.view addSubview:self.hiddenText];

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
        
        
        if (newLength == 0) {
            //[self.hideKeyboardView removeFromSuperview];
            //self.hideKeyboardView = nil;
        }else{
            //[self showDoneButton];
        }
        
        if (newLength > 4) {
            return FALSE;
        }else{
            self.errorLabel.text = @"";
            [self setValues:[self.hiddenText.text stringByReplacingCharactersInRange:range withString:string]];
            return TRUE;
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ConfirmPayment.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (IBAction)confirmAction {
    
    [self submit:nil];
}

- (IBAction)submit:(id)sender {
    @try {
        
        
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
            
            
            //[self.activity startAnimating];
            self.loadingViewController.displayText.text = @"Sending Payment...";
            [self.loadingViewController startSpin];
            
            
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            
            NSNumber *invoiceAmount = [NSNumber numberWithDouble:[self.myInvoice amountDue]];
            [ tempDictionary setObject:invoiceAmount forKey:@"InvoiceAmount"];
            
            //NSNumber *amount = [NSNumber numberWithDouble:[self.myInvoice basePaymentAmount]];
            NSString *amountString = [NSString stringWithFormat:@"%.2f", [self.myInvoice basePaymentAmount]];

            [ tempDictionary setObject:amountString forKey:@"Amount"];
            
            [ tempDictionary setObject:@"" forKey:@"AuthenticationToken"];
            [ tempDictionary setObject:ccNumber forKey:@"FundSourceAccount"];
            
            NSString *gratuityString = [NSString stringWithFormat:@"%.2f", [self.myInvoice gratuity]];
            [tempDictionary setObject:gratuityString forKey:@"Gratuity"];
            
          
            [ tempDictionary setObject:self.transactionNotes forKey:@"Notes"];
            
            
            
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
            
            if (self.mySplitPercent > 0.0) {
                self.mySplitPercent = self.mySplitPercent / 100.0;
                [tempDictionary setValue:[NSNumber numberWithDouble:self.mySplitPercent] forKey:@"PercentPaid"];
            }
            
            if ([self.myItemsArray count] > 0) {
                [tempDictionary setValue:self.myItemsArray forKey:@"Items"];
            }
            
            
            loginDict = tempDictionary;
            self.confirmButton.enabled = NO;
            self.navigationItem.hidesBackButton = YES;
            ArcClient *client = [[ArcClient alloc] init];
            
            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(createPaymentTimer) userInfo:nil repeats:NO];
            
            self.navigationController.sideMenu.allowSwipeOpenLeft = NO;

            [client createPayment:loginDict];
            
        }else{
            
            if (self.incorrectPinCount < 3) {
                self.incorrectPinCount ++;
                
                self.errorLabel.text = @"*Invalid PIN.";
                
                self.checkNumOne.text = @"";
                self.checkNumTwo.text = @"";
                self.checkNumThree.text = @"";
                self.checkNumFour.text = @"";
                
                self.hiddenText.text = @"";
            }else{
                
                
                ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Deleted" message:@"You have entered your PIN wrong too many times.  For security reasons, this card has been deleted.  Please re-add the card with a new PIN, and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                
                for (int i = 0; i < [[self.navigationController viewControllers] count]; i++) {
                    
                    UIViewController *tmp = [[self.navigationController viewControllers] objectAtIndex:i];
                    
                    if ([tmp class] == [InvoiceView class]) {
                        [self.navigationController popToViewController:tmp animated:YES];
                        break;
                    }
                }
                
            }
            
          
        }
        
    }
    @catch (NSException *e) {
        self.errorLabel.text = @"*Error retreiving credit card.";
        
        [rSkybox sendClientLog:@"CreditCardPayment.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)createPaymentTimer{
 
    
    [self showHighVolumeOverlay];
}


-(void)showHighVolumeOverlay{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingViewController.displayText.text = @"dutch is experiencing high volume, or a weak internet connection, please be patient...";
        self.loadingViewController.displayText.font = [UIFont fontWithName:[self.loadingViewController.displayText.font fontName] size:16];
        
        self.loadingViewController.displayText.numberOfLines = 3;
        CGRect frame = self.loadingViewController.mainBackView.frame;
        frame.origin.y -= 20;
        frame.size.height += 20;
        frame.origin.x = 10;
        frame.size.width = 300;
        self.loadingViewController.mainBackView.frame = frame;
        
        CGRect frame2 = self.loadingViewController.displayText.frame;
        frame2.origin.y -= 20;
        frame2.size.height += 20;
        frame2.origin.x = 10;
        frame2.size.width = 300;
        self.loadingViewController.displayText.frame = frame2;
        
    }];
}




-(void)paymentComplete:(NSNotification *)notification{
    
    @try {
        self.navigationController.sideMenu.allowSwipeOpenLeft = YES;

        [self.myTimer invalidate];
        
        //[self hideHighVolumeOverlay];
        
        BOOL editCardOption = NO;
        BOOL duplicateTransaction = NO;
        BOOL displayAlert = NO;
        self.confirmButton.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        //[self.activity stopAnimating];
        [self.loadingViewController stopSpin];
        
        NSString *errorMsg= @"";
        if ([status isEqualToString:@"success"]) {
            
            //success
            self.errorLabel.text = @"";
            BOOL paidInFull = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"InvoicePaid"] boolValue];
            self.paymentPointsReceived =  [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"Points"] intValue];
            
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
                errorMsg = @"dutch is unable to complete your request, please try again.";
            }else if (errorCode == PAYMENT_MAYBE_PROCESSED){
                errorMsg = @"This payment may have already processed.  To be sure, please wait 30 seconds and then try again.";
                displayAlert = YES;
            }else if(errorCode == DUPLICATE_TRANSACTION){
                duplicateTransaction = YES;
            }else if (errorCode == CHECK_IS_LOCKED){
                errorMsg = @"Invoice being access by your server.  Please try again in a few minutes.";
                displayAlert = YES;
            }else if (errorCode == CARD_ALREADY_PROCESSED){
                errorMsg = @"this credit card has already been used to make a payment on this invoice. To make an additional payment, either use a different credit card or have your server void your initial payment.";
                displayAlert = YES;
            }else if (errorCode == NO_AUTHORIZATION_PROVIDED){
                errorMsg = @"Invalid Authorization, please try again.";
                displayAlert = YES;
            }
            else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if (displayAlert) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Warning" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else{
            self.errorLabel.text = errorMsg;
            
        }
        
        if (editCardOption) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your payment may have failed due to invalid credit card information.  Would you like to view/edit the card you tried to make this payment with?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"View/Edit", nil];
            [alert show];
        }else if (duplicateTransaction){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Transaction" message:@"dutch has recorded a similar transaction that happened recently.  To avoid a duplicate transaction, please wait 30 seconds and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *e) {
        
        [self.loadingViewController stopSpin];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:@"We encountered an error processing your request, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [rSkybox sendClientLog:@"CreditCardPayment.paymentComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}




- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    @try {
        
        if ([[segue identifier] isEqualToString:@"reviewCreditCardTransaction"]) {
            
            ReviewTransaction *next = [segue destinationViewController];
            next.myInvoice = self.myInvoice;
            next.paymentPointsReceived = self.paymentPointsReceived;
        }
        
     
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ConfirmPayment.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


@end
