//
//  SplitCheckViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 8/15/12.
//
//

#import "SplitCheckViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "DwollaPayment.h"
#import "CreditCardPayment.h"



@interface SplitCheckViewController ()

@end

@implementation SplitCheckViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    @try {
        [rSkybox addEventToSession:@"signInComplete"];
        
        self.dollarView.hidden = NO;
        self.percentView.hidden = YES;
        self.itemView.hidden = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        // *** TODO get Jim to change API and/or put this calculation inside of the Invoice class ****
        double serviceCharge = (self.myInvoice.baseAmount * self.myInvoice.serviceCharge);
        double tax = (self.myInvoice.baseAmount * self.myInvoice.tax);
        double discount = (self.myInvoice.baseAmount * self.myInvoice.discount);
        self.amountDue = self.myInvoice.baseAmount + serviceCharge + tax - discount;
        double amountPaid = [self calculateAmountPaid];
        self.amountDue -= amountPaid;
        
        self.dollarTotalBillLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.baseAmount];
        self.dollarAmountPaidLabel.text = [NSString stringWithFormat:@"$%.2f", amountPaid];
        self.dollarAmountDueLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"Your Total Payment: $%.2f", 0.0];
        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        self.dollarView.backgroundColor = [UIColor clearColor];
        self.percentView.backgroundColor = [UIColor clearColor];
        self.itemView.backgroundColor = [UIColor clearColor];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }

}

- (void)viewDidUnload
{
    [self setPercentView:nil];
    [self setDollarView:nil];
    [self setItemView:nil];
    [self setTypeSegment:nil];
    [self setTypeSegment:nil];
    [self setDollarTotalBillNameLabel:nil];
    [self setDollarTotalBillLabel:nil];
    [self setDollarAmountPaidNameLabel:nil];
    [self setDollarAmountPaidLabel:nil];
    [self setDollarAmountDueNameLabel:nil];
    [self setDollarAmountDueLabel:nil];
    [self setDollarYourPaymentNameLabel:nil];
    [self setDollarYourPaymentText:nil];
    [self setDollarTipText:nil];
    [self setDollarTipSegment:nil];
    [self setDollarYourTotalPaymentLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)typeSegmentChanged {
    @try {
        if (self.typeSegment.selectedSegmentIndex == 0) {
            
            self.dollarView.hidden = NO;
            self.percentView.hidden = YES;
            self.itemView.hidden = YES;
            
        }else if (self.typeSegment.selectedSegmentIndex == 1){
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = NO;
            self.itemView.hidden = YES;
            
        }else{
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = YES;
            self.itemView.hidden = NO;
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(void)endText{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.dollarView.frame = CGRectMake(0, 44, 320, 328);
        self.percentView.frame = CGRectMake(0, 44, 320, 328);
    }];
    
}

- (IBAction)dollarTipDidBegin {
    [rSkybox addEventToSession:@"dollarTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.dollarView.frame = CGRectMake(0, -120, 320, 328);
    }];
}

- (IBAction)percentTipDidBegin {
    [rSkybox addEventToSession:@"percentTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.percentView.frame = CGRectMake(0, -120, 320, 328);
    }];
}

- (IBAction)dollarTipSegmentSelect:(id)sender {
    @try {
        //::nick -- what does this do?
        [self performSelector:@selector(resetSegment) withObject:nil afterDelay:0.2];
        
        double tipPercent = 0.0;
        if (self.dollarTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .10;
        }else if (self.dollarTipSegment.selectedSegmentIndex == 1){
            tipPercent = .15;
        }else{
            tipPercent = .20;
        }
        
        self.yourPayment = [self.dollarYourPaymentText.text doubleValue];
        double tipAmount = tipPercent * self.yourPayment;
        self.yourTotalPayment = self.yourPayment + tipAmount;
        self.dollarTipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"Your Total Payment: $%.2f", self.yourTotalPayment];
        
        //::nick?
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        //::nick?
        self.view.frame = CGRectMake(0, 0, 320, 416);
        [self.dollarTipText resignFirstResponder];
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarTipSegmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

//::nick::todo what happens if Amount cannot be converted to a float?
- (double)calculateAmountPaid {
    double amountPaid = 0.0;
    double paymentAmount = 0.0;
    for (int i = 0; i < [self.myInvoice.payments count]; i++) {
        NSDictionary *paymentDictionary = [self.myInvoice.payments objectAtIndex:i];
        paymentAmount = [[paymentDictionary valueForKey:@"Amount"] doubleValue];
        amountPaid += paymentAmount;
    }
    return amountPaid;
}

- (IBAction)dollarTipSegmentSelect {
    
       
}

-(void)resetSegment{
    self.dollarTipSegment.selectedSegmentIndex = -1;
}


- (IBAction)dollarEditBegin:(id)sender {
    @try {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        self.view.frame = CGRectMake(0, 0, 320, 416);
        
        [UIView commitAnimations];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarEditBegin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)dollarEditEnd:(id)sender {
    @try {
        
        double tip = [self.dollarTipText.text doubleValue];
        if (tip < 0.0) {
            tip = 0.0;
        }
        self.yourPayment = [self.dollarYourPaymentText.text doubleValue];
        self.yourTotalPayment = self.yourPayment + tip;
        
        self.dollarTipText.text = [NSString stringWithFormat:@"%.2f", tip];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"Your Total Payment: $%.2f", self.yourTotalPayment];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        self.view.frame = CGRectMake(0, 0, 320, 416);
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarEditEnd" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (IBAction)dollarYourPaymentEditEnd:(id)sender {
    double tip = [self.dollarTipText.text doubleValue];
    self.yourPayment = [self.dollarYourPaymentText.text doubleValue];
    
    if (self.yourPayment < 0.0) {
        self.yourPayment = 0.0;
    }
    self.yourTotalPayment = self.yourPayment + tip;
    
    self.dollarYourPaymentText.text = [NSString stringWithFormat:@"%.2f", self.yourPayment];
    self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"Your Total Payment: $%.2f", self.yourTotalPayment];
}

- (IBAction)dollarPayNow:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"clickedDollarPayButton"];
        
        [self.dollarTipText resignFirstResponder];
        UIActionSheet *action;
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
        
        if ([self.creditCards count] > 0) {
            
            action = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [action addButtonWithTitle:@"Dwolla"];
            
            for (int i = 0; i < [self.creditCards count]; i++) {
                CreditCard *tmpCard = (CreditCard *)[self.creditCards objectAtIndex:i];
                [action addButtonWithTitle:[NSString stringWithFormat:@"Credit Card  %@", tmpCard.sample]];
                
            }
            [action addButtonWithTitle:@"Cancel"];
            action.cancelButtonIndex = [self.creditCards count] + 1;
            
        }else {
            action = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Dwolla", nil];
        }
        
        
        action.actionSheetStyle = UIActionSheetStyleDefault;
        [action showInView:self.view];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarPayNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        
        if (buttonIndex == 0) {
            //Dwolla
            [rSkybox addEventToSession:@"selectedDwollaForPayment"];
            
            [self performSegueWithIdentifier:@"dollarGoPayDwolla" sender:self];
        }else {
            [rSkybox addEventToSession:@"selectedCreditCardForPayment"];
            
            if ([self.creditCards count] > 0) {
                if (buttonIndex == [self.creditCards count] + 1) {
                    //Cancel
                    //::todo::nick
                }else{
                    //1 is paypal, 2 is first credit card
                    CreditCard *selectedCard = [self.creditCards objectAtIndex:buttonIndex - 1];
                    
                    self.creditCardNumber = selectedCard.number;
                    self.creditCardSecurityCode = selectedCard.securityCode;
                    self.creditCardExpiration = selectedCard.expiration;
                    self.creditCardSample = selectedCard.sample;
                    
                    [self performSegueWithIdentifier:@"dollarGoPayCreditCard" sender:self];
                    
                }
            }else{
                
            }
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"dollarGoPayDwolla"]) {
            
            DwollaPayment *controller = [segue destinationViewController];
            controller.totalAmount = [[NSString stringWithFormat:@"%f", self.yourPayment] doubleValue];
            controller.gratuity = [self.dollarTipText.text doubleValue];
            controller.invoiceId = self.myInvoice.invoiceId;
            
        }else if ([[segue identifier] isEqualToString:@"dollarGoPayCreditCard"]) {
            
            CreditCardPayment *controller = [segue destinationViewController];
            controller.totalAmount = [[NSString stringWithFormat:@"%f", self.yourPayment] doubleValue];
            controller.gratuity = [self.dollarTipText.text doubleValue];
            controller.invoiceId = self.myInvoice.invoiceId;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end
