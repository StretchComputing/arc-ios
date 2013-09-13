//
//  AdditionalTipViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/29/13.
//
//

#import "ArcAppDelegate.h"
#import "AdditionalTipViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "ConfirmPaymentViewController.h"
#import "AddCreditCardGuest.h"
#import "ArcUtility.h"

@interface AdditionalTipViewController ()

@end

@implementation AdditionalTipViewController


-(void)viewDidAppear:(BOOL)animated{
    if ([self.transactionNotesText.text length] == 0) {
        self.transactionNotesText.text = @"Transaction Notes (*optional):";
    }
}


-(void)viewDidLoad{
    
    @try {
        
        self.tipTextField.delegate = self;
        self.transactionNotesText.delegate = self;
        
        self.tipTextField.keyboardType = UIKeyboardTypeDecimalPad;
        
        
        self.continueButton.text = @"Continue";
        self.continueButton.textColor = [UIColor whiteColor];
        self.continueButton.textShadowColor = [UIColor darkGrayColor];
        self.continueButton.tintColor = dutchDarkBlueColor;
        
        self.tipSelectSegment.tintColor = dutchDarkBlueColor;
        
        
       // self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
       // self.topLineView.layer.shadowRadius = 1;
       // self.topLineView.layer.shadowOpacity = 0.2;
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;
        
        
        
        self.myTotalLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.basePaymentAmount];
        
        
        if (self.myInvoice.serviceCharge == 0.0) {
            
            NSString *customerId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
            NSString *defaultTipName = [NSString stringWithFormat:@"%@%@", customerId, @"defaultTip"];
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:defaultTipName] length] > 0 ) {
                //There is a default tip
                
                NSString *tipValueString = [[NSUserDefaults standardUserDefaults] valueForKey:defaultTipName];
                double tipValueDouble = [tipValueString doubleValue];
                
                BOOL didFind = NO;
                for (int i = 0; i < 3; i++) {
                    
                    if ([[[self.tipSelectSegment titleForSegmentAtIndex:i] stringByReplacingOccurrencesOfString:@"%" withString:@""] isEqualToString:tipValueString]) {
                        self.tipSelectSegment.selectedSegmentIndex = i;
                        didFind = YES;
                        break;
                    }
                    
                }
                
                
                if (!didFind) {
                    
                    [self.tipSelectSegment insertSegmentWithTitle:[NSString stringWithFormat:@"%@%%", tipValueString] atIndex:3 animated:NO];
                    self.tipSelectSegment.selectedSegmentIndex = 3;
                    
                }
                
                tipValueDouble = tipValueDouble/100.0;
                double tipTotalValue = self.myInvoice.basePaymentAmount * tipValueDouble;
                self.tipTextField.text = [NSString stringWithFormat:@"%.2f", tipTotalValue];
                
            }else{
                self.tipSelectSegment.selectedSegmentIndex = 1;
                double doubleValue = self.myInvoice.basePaymentAmount * 0.20;
                
                self.tipTextField.text = [NSString stringWithFormat:@"%.2f", doubleValue];
            }
            
            
            
        }else{
            
            
            self.tipSelectSegment.selectedSegmentIndex = -1;
            
        }
        
        self.transactionNotesText.layer.borderWidth = 1;
        self.transactionNotesText.layer.borderColor = [dutchTopLineColor CGColor];
    }
    @catch (NSException *exception) {
        NSLog(@"E: %@", exception);
    }
   
}



- (IBAction)continueAction:(id)sender {
    
    self.myInvoice.gratuity = [self.tipTextField.text doubleValue];

    if (self.tipTextField.text == nil) {
        self.tipTextField.text = @"";
    }
    
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"] length] > 0) {
        
        BOOL haveCards;
        BOOL haveDwolla;
        BOOL showSheet = YES;
        
        if([self.myInvoice calculateAmountPaid] > 0) {
            //[ArcClient trackEvent:@"PAY_REMAINING"];
        }
        
        
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
        
        if ([self.creditCards count] == 0) {
            haveCards = NO;
        }else{
            haveCards = YES;
        }
        
        NSString *token;
        
        @try {
           // token = [DwollaAPI getAccessToken];
        }
        @catch (NSException *exception) {
            
        }
        
        if ([token length] > 0) {
            haveDwolla = YES;
        }else{
            haveDwolla = NO;
        }
        
        if (haveCards) {
            
            NSMutableArray *tmpCards = [NSMutableArray arrayWithArray:self.creditCards];
            BOOL didRemove = NO;
            for (int i = 0; i < [tmpCards count]; i++) {
                
                CreditCard *tmp = [tmpCards objectAtIndex:i];
                
                if ([self.myInvoice.paymentsAccepted rangeOfString:tmp.cardType].location == NSNotFound) {
                    [tmpCards removeObjectAtIndex:i];
                    i--;
                    didRemove = YES;
                }
                
            }
            self.creditCards = [NSArray arrayWithArray:tmpCards];
            
            
            
            if ([self.creditCards count] > 0) {
                
                
                if ([self.creditCards count] == 1) {
                    CreditCard *selectedCard = [self.creditCards objectAtIndex:0];
                    
                    self.creditCardNumber = selectedCard.number;
                    self.creditCardSecurityCode = selectedCard.securityCode;
                    self.creditCardExpiration = selectedCard.expiration;
                    self.creditCardSample = selectedCard.sample;
                    
                    [self performSegueWithIdentifier:@"goConfirm" sender:self];
                    return;
                }else{
                    
                    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                    
                    int x = 0;
                    if (haveDwolla) {
                        x++;
                        [self.actionSheet addButtonWithTitle:@"Dwolla"];
                    }
                    
                    for (int i = 0; i < [self.creditCards count]; i++) {
                        CreditCard *tmpCard = (CreditCard *)[self.creditCards objectAtIndex:i];
                        
                        if ([tmpCard.sample rangeOfString:@"Credit Card"].location == NSNotFound && [tmpCard.sample rangeOfString:@"Debit Card"].location == NSNotFound) {
                            
                            [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", tmpCard.sample]];
                            
                        }else{
                            [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@  %@", [ArcUtility getCardNameForType:tmpCard.cardType], [tmpCard.sample substringFromIndex:[tmpCard.sample length] - 8] ]];
                            
                        }
                        
                        
                        
                        
                    }
                    [self.actionSheet addButtonWithTitle:@"Cancel"];
                    self.actionSheet.cancelButtonIndex = [self.creditCards count] + x;
                }
                
                
            }else {
                
                if (haveDwolla) {
                    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Dwolla", nil];
                }else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Cards Accepted" message:@"None of your credit cards on file are accepted by this merchant, to continue please add a new form of payment." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    
                    didRemove = NO;
                    showSheet = NO;
                    [self noPaymentSources];
                    
                    
                }
                
            }
            
            
            self.actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            
            if (didRemove) {
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not All Cards Accepted" message:@"One or more of your saved credit cards are not accepted by this merchant.  You will not see these cards in the list of payment choices" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                //[alert show];
                
                //[self showTextOverlay];
                [self.actionSheet showInView:self.view];
                
            }else{
                
                if (showSheet) {
                    [self.actionSheet showInView:self.view];
                    
                }
                
            }
            
        }else{
            [self noPaymentSources];
        }
        
        
    }else{
        
        //Guest
        
        
        self.creditCardNumber = @"";
        self.creditCardSecurityCode = @"";
        self.creditCardExpiration = @"";
        self.creditCardSample = @"";
        
        [self performSegueWithIdentifier:@"goEnterCard" sender:self];
       
    }

    
    
    
    /*
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"] > 0) {
        
        if ([self.creditCardSample length] > 0) {
            [self performSegueWithIdentifier:@"goConfirm" sender:self];
        }else{
            //logged in, but need to enter card
            [self performSegueWithIdentifier:@"goEnterCard" sender:self];

        }
        
    }else{
        //Guest
        
        [self performSegueWithIdentifier:@"goEnterCard" sender:self];

    }
  
     */
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    @try {
        
        BOOL haveDwolla = NO;
        NSString *token;
        
        @try {
            //token = [DwollaAPI getAccessToken];
        }
        @catch (NSException *exception) {
            
        }
        
        int x = 0;
        if ([token length] > 0) {
            x++;
            //haveDwolla = YES;
        }
        
        
        if (buttonIndex == 0) {
            //Dwolla
            
            if (haveDwolla) {
                if ((token == nil) || [token isEqualToString:@""]) {
                    
                    [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
                    
                    
                }else{
                    [rSkybox addEventToSession:@"selectedDwollaForPayment"];
                    
                    [self performSegueWithIdentifier:@"goPayDwolla" sender:self];
                    
                }
            }else{
                //Grab top CC
                
                CreditCard *selectedCard = [self.creditCards objectAtIndex:0];
                
                self.creditCardNumber = selectedCard.number;
                self.creditCardSecurityCode = selectedCard.securityCode;
                self.creditCardExpiration = selectedCard.expiration;
                self.creditCardSample = selectedCard.sample;
                
                [self performSegueWithIdentifier:@"goConfirm" sender:self];
            }
            
            
            
            
        }else {
            [rSkybox addEventToSession:@"selectedCreditCardForPayment"];
            
            
            if ([self.creditCards count] > 0) {
                if (buttonIndex == [self.creditCards count] + x) {
                    //Cancel
                }else{
                    CreditCard *selectedCard = [self.creditCards objectAtIndex:buttonIndex - x];
                    
                    self.creditCardNumber = selectedCard.number;
                    self.creditCardSecurityCode = selectedCard.securityCode;
                    self.creditCardExpiration = selectedCard.expiration;
                    self.creditCardSample = selectedCard.sample;
                    
                    [self performSegueWithIdentifier:@"goConfirm" sender:self];
                    
                }
            }
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionalTip.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}




-(void)noPaymentSources{
    [self performSegueWithIdentifier:@"goEnterCard" sender:self];

}

- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)endText {
}

- (IBAction)segmentValueChanged:(id)sender {
    
    double tipDouble = 0.0;
    if (self.tipSelectSegment.selectedSegmentIndex == 0) {
        tipDouble = 0.18;
    }else if (self.tipSelectSegment.selectedSegmentIndex == 1){
        tipDouble = 0.20;
    }else{
        tipDouble = 0.22;
    }
    
    double doubleValue = self.myInvoice.basePaymentAmount * tipDouble;
    
    self.tipTextField.text = [NSString stringWithFormat:@"%.2f", doubleValue];
}

- (IBAction)tipTextEditChanged {
    
    self.tipSelectSegment.selectedSegmentIndex = -1;
}

-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyboardY = 200;
        if (self.view.frame.size.height > 500) {
            keyboardY = 288;
        }
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyboardY, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor clearColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.cornerRadius = 3.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        [self.hideKeyboardView addSubview:tmpView];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpButton.frame = CGRectMake(8, 5, 69, 35);
        [tmpButton setTitle:@"Done" forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tmpButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [tmpButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:tmpButton];
        [self.view addSubview:self.hideKeyboardView];
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionalTipView.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)hideKeyboard{
    
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;

    [self.transactionNotesText resignFirstResponder];
    [self.tipTextField resignFirstResponder];
    
    
    double value = [self.tipTextField.text doubleValue];
    
    self.tipTextField.text = [NSString stringWithFormat:@"%.2f", value];
}


- (IBAction)tipTextEditBegin {
    
    [self showDoneButton];
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    @try {
        
        if ([self.transactionNotesText.text isEqualToString:@"Transaction Notes (*optional):"]){
            self.transactionNotesText.text = @"";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionaTipVC.textViewDidBeginEditing" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            
            if ([self.transactionNotesText.text isEqualToString:@""]){
                self.transactionNotesText.text = @"Transaction Notes (*optional):";
            }
            
            
            
            // Return FALSE so that the final '\n' character doesn't get added
            return FALSE;
        }else{
            
            if ([self.transactionNotesText.text length] + [text length] >= 300) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
            if ([self.transactionNotesText.text length] >= 300) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
        }
        // For any other character return TRUE so that the text gets added to the view
        return TRUE;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionaTipVC.shouldChangeCharacters" logMessage:@"Exception Caught" logLevel:@"error" exception:e];

    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
      
        
       if ([[segue identifier] isEqualToString:@"goConfirm"]) {
           
           
          
 
            
            ConfirmPaymentViewController *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
           controller.creditCardSecurityCode = self.creditCardSecurityCode;
           controller.myItemsArray = [NSArray arrayWithArray:self.myItemsArray];
           
           if (self.transactionNotesText.text == nil || [self.transactionNotesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
               self.transactionNotesText.text = @"";
           }
           controller.transactionNotes = self.transactionNotesText.text;
           
            
       }else if ([[segue identifier] isEqualToString:@"goEnterCard"]){
           
           AddCreditCardGuest *controller = [segue destinationViewController];

           controller.myInvoice = self.myInvoice;
           if (self.transactionNotesText.text == nil || [self.transactionNotesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
               self.transactionNotesText.text = @"";
           }
           
           controller.myItemsArray = [NSArray arrayWithArray:self.myItemsArray];
        
           controller.transactionNotes = self.transactionNotesText.text;
           
           if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"]length] > 0) {
               controller.isGuest = NO;
           }else{
               controller.isGuest = YES;
           }

      
       }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



@end
