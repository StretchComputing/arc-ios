//
//  DwollaPayment.m
//  ARC
//
//  Created by Nick Wroblewski on 6/27/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "DwollaPayment.h"
#import <QuartzCore/QuartzCore.h>
#import "ReviewTransaction.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import "Invoice.h"


@interface DwollaPayment ()

@end

@implementation DwollaPayment




- (void)viewDidLoad
{
    

    @try {
        
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
        [self showDoneButton];

        [rSkybox addEventToSession:@"viewDwollaPaymentScreen"];
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Dwolla"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Dwolla"];
		self.navigationItem.backBarButtonItem = temp;
        
        
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
        
        // bypass retrieval of funding sources for now
        //self.fundingSourceStatus = @"";
        self.fundingSourceStatus = @"success";
        
        dispatch_queue_t queue = dispatch_queue_create("dwolla.task", NULL);
        dispatch_queue_t main = dispatch_get_main_queue();
        
        /*
        dispatch_async(queue,^{
            
            @try {
                DwollaFundingSources* sources = [DwollaAPI getFundingSources];
                
                //An array of DwollaFundingSource* objects
                self.fundingSources = [NSMutableArray arrayWithArray:[sources getAll]];
                self.fundingSourceStatus = @"success";
                
                if (self.waitingSources) {
                    self.waitingSources = NO;
                    
                    dispatch_async(main,^{
                        [self submit:nil];
                    });
                }
            }
            @catch (NSException *exception) {
                self.fundingSourceStatus = @"failed";
            }
            
            
        });
         */
        
        [self.dwollaBalanceActivity startAnimating];
        self.totalPaymentText.text = [NSString stringWithFormat:@"$%.2f", (self.myInvoice.basePaymentAmount + self.myInvoice.gratuity)];
        dispatch_async(queue,^{
            
            NSString *balance = @"";
            @try {
                
                balance = [DwollaAPI getBalance];
                
                dispatch_async(main,^{
                    [self.dwollaBalanceActivity stopAnimating];
                    self.dwollaBalance = [balance doubleValue];
                    self.dwollaBalanceText.text = [NSString stringWithFormat:@"$%.2f", self.dwollaBalance];
                    [self.dwollaBalanceActivity stopAnimating];
                    
                    if (self.dwollaBalance < self.myInvoice.basePaymentAmount) {
                        self.dwollaBalanceText.textColor = [UIColor redColor];
                    }else{
                        self.dwollaBalanceText.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
                    }
                });
            }
            @catch (NSException *exception) {
                //NSLog(@"Exception getting balance");
            }           
        });
        
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
        [rSkybox sendClientLog:@"DwollaPayment.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:@"createPaymentNotification" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
    @try {
        
        [self.hiddenText becomeFirstResponder];
        self.serverData = [NSMutableData data];
        
        // bypass retrieval of Dwolla funding sources for now
        /*
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
                
                dispatch_queue_t queueTwo = dispatch_queue_create("dwolla.taskTwo", NULL);
                
                dispatch_async(queue,^{
                    
                    NSString *balance = @"";
                    @try {
                        balance = [DwollaAPI getBalance];
                        
                        
                    }
                    @catch (NSException *exception) {
                        balance = @"Could Not Find";
                        
                    }
                    
                    dispatch_async(main,^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Balance: %@" message:balance delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                    });
                    
                    
                    
                });
                
                
                
                
            }else{
                
                [self.activity stopAnimating];
            }
        }
        */
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DwollaPayment.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // NSLog(@"NewString: %@", string);
    //NSLog(@"RangeLength: %d", range.length);
    //NSLog(@"RangeLoc: %d", range.location);
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        
        self.errorLabel.text = @"";
        
        if (newLength == 0) {
            //[self.hideKeyboardView removeFromSuperview];
           // self.hideKeyboardView = nil;
        }else{
            //[self showDoneButton];
        }
        
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
        [rSkybox sendClientLog:@"DwollaPayment.textField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
        [rSkybox sendClientLog:@"DwollaPayment.previousField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
        [rSkybox sendClientLog:@"DwollaPayment.nextField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
        [rSkybox sendClientLog:@"DwollaPayment.textViewDidBeginEditing" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (IBAction)submit:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"submitForDwollaPayment"];
        
        self.errorLabel.text = @"";
        
        if ([self.checkNumOne.text isEqualToString:@""] || [self.checkNumTwo.text isEqualToString:@""] || [self.checkNumThree.text isEqualToString:@""] || [self.checkNumFour.text isEqualToString:@""]) {
            
            self.errorLabel.text = @"*Please enter your full pin.";
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
                // bypass Dwolla Funding Source logic
                
                if (self.dwollaBalance < self.myInvoice.basePaymentAmount) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insufficient Funds" message:@"You do not have enough funds in your Dwolla account to cover this transaction." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    
                }else{
                    [self performSelector:@selector(createPayment)];

                }
                
                /*
                if ([self.fundingSourceStatus isEqualToString:@"success"]) {
                    
                    if ([self.fundingSources count] == 0) {
                        // TODO what should the code do here?????
                        
                    }else if ([self.fundingSources count] == 1){
                        
                        DwollaFundingSource *tmp = [self.fundingSources objectAtIndex:0];
                        
                        NSLog(@"Name: %@", [tmp getName]);
                        NSLog(@"Id: %@", [tmp getSourceID]);
                        NSLog(@"Type: %@", [tmp getType]);
                        
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
                    
                    
                }else if ([self.fundingSourceStatus isEqualToString:@"failure"]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dwolla Error" message:@"Unable to obtain Dwolla Funding Sources" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    self.waitingSources = YES;
                    
                    [self.activity startAnimating];
                    
                }
                */
                
                
                
            }
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DwollaPayment.submit" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        
        if (buttonIndex == [self.fundingSources count]) {
            //Cancel
        }else{
            
            DwollaFundingSource *tmp = [self.fundingSources objectAtIndex:buttonIndex];
            self.selectedFundingSourceId = [tmp getSourceID];
            [self performSelector:@selector(createPayment)];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DwollaPayment.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}
-(void)createPayment{
    
    @try{        
        [self.activity startAnimating];
        
         NSString *pinNumber = [NSString stringWithFormat:@"%@%@%@%@", self.checkNumOne.text, self.checkNumTwo.text, self.checkNumThree.text, self.checkNumFour.text];
        
        NSString *dwollaToken = [DwollaAPI getAccessToken];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        NSNumber *invoiceAmount = [NSNumber numberWithDouble:[self.myInvoice amountDue]];
        [ tempDictionary setObject:invoiceAmount forKey:@"InvoiceAmount"];
        
        NSNumber *amount = [NSNumber numberWithDouble:[self.myInvoice basePaymentAmount]];
        [ tempDictionary setObject:amount forKey:@"Amount"];
        
        [ tempDictionary setObject:dwollaToken forKey:@"AuthenticationToken"];
        // bypass funding source - force server to use default which means the money comes from the user's Dwolla account
        //[ tempDictionary setObject:self.selectedFundingSourceId forKey:@"FundSourceAccount"];
        [ tempDictionary setObject:@"" forKey:@"FundSourceAccount"];
        
        NSNumber *grat = [NSNumber numberWithDouble:[self.myInvoice gratuity]];
        [ tempDictionary setObject:grat forKey:@"Gratuity"];
        
        if (![self.notesText.text isEqualToString:@""] && ![self.notesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
            [ tempDictionary setObject:self.notesText.text forKey:@"Notes"];
        }else{
            [ tempDictionary setObject:@"" forKey:@"Notes"];
        }
                
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        [ tempDictionary setObject:customerId forKey:@"CustomerId"];
        
        [ tempDictionary setObject:@"" forKey:@"Tag"];
        [ tempDictionary setObject:@"" forKey:@"Expiration"];
		
        NSString *invoiceIdString = [NSString stringWithFormat:@"%d", self.myInvoice.invoiceId];
        [ tempDictionary setObject:invoiceIdString forKey:@"InvoiceId"];
        NSString *merchantIdString = [NSString stringWithFormat:@"%d", self.myInvoice.merchantId];
        [ tempDictionary setObject:merchantIdString forKey:@"MerchantId"];


        [ tempDictionary setObject:pinNumber forKey:@"Pin"];
        [ tempDictionary setObject:@"DWOLLA" forKey:@"Type"];
        
        // TODO hardcoded for now
        [ tempDictionary setObject:@"Z" forKey:@"CardType"];

        //For Metrics
        [tempDictionary setObject:self.myInvoice.splitType forKey:@"SplitType"];
        [tempDictionary setObject:self.myInvoice.splitPercent forKey:@"PercentEntry"];
        [tempDictionary setObject:self.myInvoice.tipEntry forKey:@"TipEntry"];
        
		loginDict = tempDictionary;
        self.payButton.enabled = NO;
        self.navigationItem.hidesBackButton = YES;
        ArcClient *client = [[ArcClient alloc] init];
        [client createPayment:loginDict];
    }
    @catch (NSException *e) {
        
        [rSkybox sendClientLog:@"DwollaPayment.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)paymentComplete:(NSNotification *)notification{
    @try {
        
        bool displayAlert = NO;
        self.payButton.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
        [rSkybox addEventToSession:@"DwollaPaymentComplete"];
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            BOOL paidInFull = [[[responseInfo valueForKey:@"Results"] valueForKey:@"InvoicePaid"] boolValue];
            if(paidInFull) [self.myInvoice setPaidInFull:paidInFull];
            int paymentId = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"PaymentId"] intValue];
            
             self.paymentPointsReceived =  [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"Points"] intValue];
            
            [self.myInvoice setPaymentId:paymentId];
            
            [self performSegueWithIdentifier:@"reviewTransaction" sender:self];
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == CANNOT_PROCESS_PAYMENT) {
                errorMsg = @"Can not process payment.";
            } else if(errorCode == CANNOT_TRANSFER_TO_SAME_ACCOUNT) {
                errorMsg = @"Can not transfer to your own account.";
            } else if(errorCode == MERCHANT_CANNOT_ACCEPT_PAYMENT_TYPE) {
                errorMsg = @"Merchant does not accept Dwolla payment.";
            } else if(errorCode == INVALID_ACCOUNT_PIN) {
                errorMsg = @"Invalid PIN";
                
                self.checkNumOne.text = @"";
                self.checkNumTwo.text = @"";
                self.checkNumThree.text = @"";
                self.checkNumFour.text = @"";
                
                self.hiddenText.text = @"";
                
            } else if(errorCode == INSUFFICIENT_FUNDS) {
                errorMsg = @"Insufficient funds.";
            } else if(errorCode == OVER_PAID) {
                    errorMsg = @"Over payment. Please check invoice and try again.";
            } else if(errorCode == INVALID_AMOUNT) {
                errorMsg = @"Invalid amount. Please re-enter payment and try again.";
            }else if (errorCode == PAYMENT_MAYBE_PROCESSED){
                errorMsg = @"This payment may have already processed.  To be sure, please wait 30 seconds and then try again.";
                displayAlert = YES;
            }
            else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            if (displayAlert) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Warning" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }else{
                self.errorLabel.text = errorMsg;

            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DwollaPayment.paymentComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"reviewTransaction"]) {
            
            ReviewTransaction *next = [segue destinationViewController];
            next.myInvoice = self.myInvoice;
            next.paymentPointsReceived = self.paymentPointsReceived;
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DwollaPayment.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
        [rSkybox sendClientLog:@"DwollaPayment.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
- (IBAction)touchBoxesAction {
    [self.hiddenText becomeFirstResponder];

}
@end
