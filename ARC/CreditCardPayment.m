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

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        self.loadingViewController.view.hidden = YES;
        [self.view addSubview:self.loadingViewController.view];
        
        self.overlayTextView.layer.masksToBounds = YES;
        self.overlayTextView.layer.cornerRadius = 10.0;
        self.overlayTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.overlayTextView.layer.borderWidth = 3.0;
        
        self.overlayTextView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);

        CAGradientLayer *gradient1 = [CAGradientLayer layer];
        gradient1.frame = self.overlayTextView.bounds;
        self.overlayTextView.backgroundColor = [UIColor clearColor];
        double x = 1.4;
        UIColor *myColor1 = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
        gradient1.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor1 CGColor], nil];
        [self.overlayTextView.layer insertSublayer:gradient1 atIndex:0];
        
        UIActivityIndicatorView *highVolumeActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        highVolumeActivity.frame = CGRectMake(165, 70, 20, 20);
        [highVolumeActivity startAnimating];
        [self.overlayTextView addSubview:highVolumeActivity];
        self.overlayTextView.alpha = 0.0;
        
        
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
        [self showDoneButton];

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

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
  
    [self.view bringSubviewToFront:self.touchBoxesButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
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
        
        self.errorLabel.text = @"";
        
        if (newLength == 0) {
            //[self.hideKeyboardView removeFromSuperview];
            //self.hideKeyboardView = nil;
        }else{
            //[self showDoneButton];
        }
        
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
            
            
            //[self.activity startAnimating];
            self.loadingViewController.displayText.text = @"Sending Payment...";
            self.loadingViewController.view.hidden = NO;


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
            
            if (self.mySplitPercent > 0.0) {
                self.mySplitPercent = self.mySplitPercent / 100.0;
                [tempDictionary setValue:[NSNumber numberWithDouble:self.mySplitPercent] forKey:@"PercentPaid"];
            }
            
            if ([self.myItemsArray count] > 0) {
                [tempDictionary setValue:self.myItemsArray forKey:@"Items"];
            }

            
            loginDict = tempDictionary;
            self.keyboardSubmitButton.enabled = NO;
            self.navigationItem.hidesBackButton = YES;
            ArcClient *client = [[ArcClient alloc] init];
            
            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(createPaymentTimer) userInfo:nil repeats:NO];
            
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


-(void)createPaymentTimer{
    
    /*
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Volume" message:@"Arc is experiencing high volume, or a weak internet connecition, please be patient..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
     [alert show];
     
     */
    
    [self showHighVolumeOverlay];
}

- (IBAction)touchBoxesAction {
    [self.hiddenText becomeFirstResponder];
}

-(void)showHighVolumeOverlay{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingViewController.displayText.text = @"Arc is experiencing high volume, or a weak internet connection, please be patient...";
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
        
        [self.myTimer invalidate];
        
        //[self hideHighVolumeOverlay];
        
        BOOL editCardOption = NO;
        BOOL duplicateTransaction = NO;
        BOOL displayAlert = NO;
        self.keyboardSubmitButton.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        //[self.activity stopAnimating];
        self.loadingViewController.view.hidden = YES;

        NSString *errorMsg= @"";
        if ([status isEqualToString:@"success"]) {
            [rSkybox addEventToSession:@"creditCardPaymentCompleteSuccess"];

            //success
            self.errorLabel.text = @"";
            BOOL paidInFull = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"InvoicePaid"] boolValue];
            self.paymentPointsReceived =  [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"Points"] intValue];
            
            if(paidInFull) [self.myInvoice setPaidInFull:paidInFull];
            int paymentId = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"PaymentId"] intValue];
            [self.myInvoice setPaymentId:paymentId];
            
            [self performSegueWithIdentifier:@"reviewCreditCardTransaction" sender:self];
        } else if([status isEqualToString:@"error"]){
            [rSkybox addEventToSession:@"creditCardPaymentCompleteFail"];

            
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
            }else if (errorCode == PAYMENT_MAYBE_PROCESSED){
                errorMsg = @"This payment may have already processed.  To be sure, please wait 30 seconds and then try again.";
                displayAlert = YES;
            }else if(errorCode == DUPLICATE_TRANSACTION){
                duplicateTransaction = YES;
            }else if (errorCode == CHECK_IS_LOCKED){
                errorMsg = @"This check is currently locked.  Please try again in a few minutes.";
                displayAlert = YES;
            }else if (errorCode == CARD_ALREADY_PROCESSED){
                errorMsg = @"This card has already been used for payment on this invoice.  A card may only be used once per invoice.  Please try again with a different card.";
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Transaction" message:@"Arc has recorded a similar transaction that happened recently.  To avoid a duplicate transaction, please wait 30 seconds and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    @try {
        
        if ([text isEqualToString:@""]) {
            return YES;
        }
        
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
            if ([self.notesText.text length] >= 300) {
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
            next.paymentPointsReceived = self.paymentPointsReceived;
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



-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyboardY = 158;
        if (self.isIphone5) {
            keyboardY = 245;
        }
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyboardY, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor clearColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.cornerRadius = 3.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        [self.hideKeyboardView addSubview:tmpView];
        
        self.keyboardSubmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.keyboardSubmitButton.frame = CGRectMake(8, 5, 69, 35);
        [self.keyboardSubmitButton setTitle:@"Pay" forState:UIControlStateNormal];
        [self.keyboardSubmitButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [self.keyboardSubmitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.keyboardSubmitButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [self.keyboardSubmitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:self.keyboardSubmitButton];
        [self.view addSubview:self.hideKeyboardView];
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)hideHighVolumeOverlay{
    
    [UIView animateWithDuration:1.0 animations:^{
        self.overlayTextView.alpha = 0.0;
    }];
}
@end