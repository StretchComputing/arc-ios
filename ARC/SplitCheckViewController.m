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
#import "MyGestureRecognizer.h"
#import "ArcUtility.h"
#import "Invoice.h"
#import "RegisterDwollaView.h"
#import "ArcClient.h"
#import "InvoiceView.h"

@interface SplitCheckViewController ()

@end

@implementation SplitCheckViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceComplete:) name:@"invoiceNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];

}

-(void)keyboardWillShow:(id)sender{
    [self showDoneButton];
}
-(void)keyboardWillHide:(id)sender{
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    
    if (self.fromDwolla) {
        
        self.fromDwolla = NO;
        if (self.dwollaSuccess) {
            
            [rSkybox addEventToSession:@"selectedDwollaForPayment"];
            
            [self performSegueWithIdentifier:@"dollarGoPayDwolla" sender:self];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"Dwolla could not authenticate your credentials, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }

    
    
}

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
      
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }

        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Split Check"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Split"];
		self.navigationItem.backBarButtonItem = temp;
   
        
        [rSkybox addEventToSession:@"signInComplete"];
        
        
        [[self.itemSplitItemView layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[self.itemSplitItemView layer] setBorderWidth:1.0];
        [[self.itemSplitItemView layer] setCornerRadius:5];
        [self.itemSplitItemView setClipsToBounds: YES];
        

        self.itemSplitItemView.hidden = YES;
        
        
        self.dollarView.hidden = YES;
        self.percentView.hidden = NO;
        self.itemView.hidden = YES;
        
        self.itemTableView.delegate = self;
        self.itemTableView.dataSource = self;
        self.itemTableView.backgroundColor = [UIColor clearColor];
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        tmpView.backgroundColor = [UIColor clearColor];
        self.itemTableView.tableFooterView = tmpView;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        
        
        [self setUpView];
        
        [super viewDidLoad];

        
        self.dollarView.backgroundColor = [UIColor clearColor];
        self.percentView.backgroundColor = [UIColor clearColor];
        self.itemView.backgroundColor = [UIColor clearColor];
        
        
        self.itemTipText.delegate = self;
        self.itemSplitItemYourAmount.delegate = self;
        self.dollarTipText.delegate = self;
        self.dollarYourPaymentText.delegate = self;
        self.percentTipText.delegate = self;
        self.percentYourPaymentText.delegate = self;
        
        
        // numeric keyboard with a period
        self.percentYourPaymentText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
            self.percentYourPaymentText.keyboardType = UIKeyboardTypeDecimalPad;
        }

        // numeric keyboard with a period
        self.dollarTipText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
            self.dollarTipText.keyboardType = UIKeyboardTypeDecimalPad;
        }
        
        // numeric keyboard with a period
        self.dollarYourPaymentText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
            self.dollarYourPaymentText.keyboardType = UIKeyboardTypeDecimalPad;
        }
        
        // numeric keyboard with a period
        self.itemTipText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
            self.itemTipText.keyboardType = UIKeyboardTypeDecimalPad;
        }
        
        // numeric keyboard with a period
        self.percentTipText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
            self.percentTipText.keyboardType = UIKeyboardTypeDecimalPad;
        }

    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }

}

-(void)setUpView{
    self.serviceChargePercentage = self.myInvoice.serviceCharge / self.myInvoice.taxableAmount;
    self.taxPercentage = self.myInvoice.tax / self.myInvoice.taxableAmount;
    self.discountPercentage = self.myInvoice.discount / self.myInvoice.subtotal;
    
    
    self.percentFoodBevLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.subtotal];
    self.percentTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.tax];
    self.percentServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.serviceCharge];
    
    self.dollarFoodBevLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.subtotal];
    self.dollarTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.tax];
    self.dollarServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.serviceCharge];
    
    
    self.dollarTotalBillLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice amountDue]];
    self.dollarAmountPaidLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice calculateAmountPaid]];
    self.dollarAmountDueLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice amountDueForSplit]];
    self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", 0.0];
    
    self.percentTotalBillLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice amountDue]];
    self.percentAmountPaidLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice calculateAmountPaid]];
    self.percentAmountDueLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice amountDueForSplit]];
    self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", 0.0];
    
    self.itemYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", 0.0];
    
    // Do any additional setup after loading the view.
    
    
    
    self.itemArray = [NSMutableArray array];
    NSMutableArray *invoiceItems= [[NSMutableArray alloc]initWithArray:self.myInvoice.items];
    
    for (int i = 0; i < [invoiceItems count]; i++) {
        
        NSDictionary *oldItem = [invoiceItems objectAtIndex:i];
        
        int number = [[oldItem valueForKey:@"Amount"] intValue];
        
        [oldItem setValue:@"no" forKey:@"selected"];
        [oldItem setValue:@"0" forKey:@"myAmount"];
        
        [oldItem setValue:@"1" forKey:@"splitAmount"];
        
        double price = [[oldItem valueForKey:@"Value"] doubleValue];
        
        //price  = price / (double)number;
        
        [oldItem setValue:[NSString stringWithFormat:@"%f", price] forKey:@"splitValue"];
        
        
        for (int j = 0; j < number; j++) {
            
            NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:oldItem];
            [self.itemArray addObject:newItem];
        }
        
    }
    
    [self.itemTableView reloadData];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)typeSegmentChanged {
    [self endText];
    @try {
        if (self.typeSegment.selectedSegmentIndex == 0) {
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = NO;
            self.itemView.hidden = YES;
            
        }else if (self.typeSegment.selectedSegmentIndex == 1){
            
            self.dollarView.hidden = NO;
            self.percentView.hidden = YES;
            self.itemView.hidden = YES;
            
            
        }else{
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = YES;
            self.itemView.hidden = NO;
            
            if (![[NSUserDefaults standardUserDefaults] valueForKey:@"didShowItemAlert"]) {
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowItemAlert"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIAlertView *betaAlert = [[UIAlertView alloc] initWithTitle:@"Choose Your Items:" message:@"Itemized check splitting currently does not check which members of your party paid for each item .  Please be sure that multiple people do not select and pay for the same item!  ARC will verify for you that this does not happen in the next release.  Thank you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [betaAlert show];
            }
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(void)endText{
    
    [self.percentYourPaymentText resignFirstResponder];
    [self.dollarTipText resignFirstResponder];
    [self.dollarYourPaymentText resignFirstResponder];
    [self.itemTipText resignFirstResponder];
    [self.percentTipText resignFirstResponder];

    [UIView animateWithDuration:0.3 animations:^{
        
        self.dollarView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 88);
        self.percentView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 88);
        self.itemView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 88);
    }];
    
}

- (IBAction)dollarTipDidBegin {
    [rSkybox addEventToSession:@"dollarTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.dollarView.frame = CGRectMake(0, -120, 320, self.view.frame.size.height - 88);
    }];
}

- (IBAction)percentTipDidBegin {
    [rSkybox addEventToSession:@"percentTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.percentView.frame = CGRectMake(0, -120, 320, self.view.frame.size.height - 88);
    }];
}

- (IBAction)dollarTipSegmentSelect:(id)sender {
    
    @try {
        
        if ([self.dollarTipText isFirstResponder]) {
            self.isSegmentDollar = YES;
        }
        
        double tipPercent = 0.0;
        if (self.dollarTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .18;
        }else if (self.dollarTipSegment.selectedSegmentIndex == 1){
            tipPercent = .20;
        }else if (self.dollarTipSegment.selectedSegmentIndex == 2){
            tipPercent = .22;
        }
        
        double yourPayment = [self.dollarYourPaymentText.text doubleValue];
        [self.myInvoice setGratuityForSplit:yourPayment withTipPercent:tipPercent];
        double payment = yourPayment + [self.myInvoice gratuity];
        
        self.dollarTipText.text = [NSString stringWithFormat:@"%.2f", [self.myInvoice gratuity]];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", payment];
        
        [self endText];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarTipSegmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

- (IBAction)dollarTipSegmentSelect {
    
       
}


// For tip on the dollar screen
- (IBAction)dollarEditEnd:(id)sender {
    @try {
        
        if (self.isSegmentDollar) {
            self.isSegmentDollar = NO;
        }else{
            self.dollarTipSegment.selectedSegmentIndex = -1;
        }
        
        double yourPayment = [self.dollarTipText.text doubleValue] + [self.dollarYourPaymentText.text doubleValue];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", yourPayment];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarEditEnd" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (IBAction)dollarYourPaymentEditEnd:(id)sender {
    double basePayment = [self.dollarYourPaymentText.text doubleValue];
    if (basePayment < 0.0) {
        basePayment = 0.0;
    }
    
    if (basePayment > [self.myInvoice amountDueForSplit] && basePayment != 0.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Over Payment" message:@"Payment cannot exceed 'Amount Remaining'." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:@"Pay Remaining", nil];
        
        [alert show];
    } else  {
        self.dollarYourPaymentText.text = [NSString stringWithFormat:@"%.2f", basePayment];
        double yourPayment = [self.dollarTipText.text doubleValue] + [self.dollarYourPaymentText.text doubleValue];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", yourPayment];
    }
    
    [self dollarTipSegmentSelect:nil];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    double basePayment = 0.0;
    
    if (buttonIndex == 1) {
        basePayment = [self.myInvoice amountDueForSplit];
    }
    
    NSString *yourBaseAmount = @"";
    if(basePayment > 0.0) {
        yourBaseAmount = [NSString stringWithFormat:@"%.2f", basePayment];
    }
    
    if(self.dollarView.hidden == NO) {
        self.dollarYourPaymentText.text = yourBaseAmount;
        double yourPayment = [self.dollarTipText.text doubleValue] + [self.dollarYourPaymentText.text doubleValue];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", yourPayment];
    } else if(self.percentView.hidden == NO) {
        self.percentYourPaymentDollarAmount.text = [NSString stringWithFormat:@"($%.2f)", basePayment];
        self.percentYourPayment = basePayment;
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", (basePayment + [self.percentTipText.text doubleValue])];
        double percentRemaining = ([self.myInvoice amountDueForSplit]/[self.myInvoice amountDue]) * 100;
        self.percentYourPaymentText.text = [NSString stringWithFormat:@"%.2f", percentRemaining];
        if(basePayment == 0.0) {
            self.percentYourPaymentText.text = @"";
        }
    }
}

- (IBAction)dollarPayNow:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"clickedDollarPayButton"];
        
        [self readyInvoiceForPayment];
        double totalPay = self.myInvoice.basePaymentAmount + self.myInvoice.gratuity;
        
        if (totalPay <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"You must pay more than $0.00 to continue" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }

        [self.dollarTipText resignFirstResponder];
        UIActionSheet *action;
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
        
        
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
            
            action = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [action addButtonWithTitle:@"Dwolla"];
            
            for (int i = 0; i < [self.creditCards count]; i++) {
                CreditCard *tmpCard = (CreditCard *)[self.creditCards objectAtIndex:i];
                [action addButtonWithTitle:[NSString stringWithFormat:@"%@", tmpCard.sample]];
                
            }
            [action addButtonWithTitle:@"Cancel"];
            action.cancelButtonIndex = [self.creditCards count] + 1;
            
        }else {
            action = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Dwolla", nil];
        }        
        
        action.actionSheetStyle = UIActionSheetStyleDefault;
        [action showInView:self.view];
        
        
        if (didRemove) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not All Cards Accepted" message:@"One or more of your saved credit cards are not accepted by this merchant.  You will not see these cards in the list of payment choices" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.dollarPayNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        
        if (buttonIndex == 0) {
            //Dwolla
            
            NSString *token = @"";
            @try {
                token = [DwollaAPI getAccessToken];
            }
            @catch (NSException *exception) {
                token = nil;
            }
            
            
            if ((token == nil) || [token isEqualToString:@""]) {
                
                [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
                
                
            }else{
                [rSkybox addEventToSession:@"selectedDwollaForPayment"];
                
                [self performSegueWithIdentifier:@"dollarGoPayDwolla" sender:self];
                
            }
            
        }else {
            [rSkybox addEventToSession:@"selectedCreditCardForPayment"];
            
            if ([self.creditCards count] > 0) {
            
                if (buttonIndex == [self.creditCards count] + 1) {
                   
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

- (void)readyInvoiceForPayment {
    @try {

        // since the user can be switching back-and-forth between dollar/percent/item views, myInvoice values can't be relied upon, so
        // we must get the payment and gratuity fields from the text fields again
        if (self.itemView.hidden == NO) {
            
            if (self.itemTipText.text == nil) {
                self.itemTipText.text = @"0.0";
            }
            
            [self.myInvoice setGratuity:[self.itemTipText.text doubleValue]];
            double payment = [[self.itemYourTotalPaymentLabel.text substringFromIndex:1] doubleValue] - [self.myInvoice gratuity];
            payment = [ArcUtility roundUpToNearestPenny:payment];
            [self.myInvoice setBasePaymentAmount:payment];
            
            self.myInvoice.splitType = @"ITEMIZED";
            self.myInvoice.splitPercent = @"NONE";
            
            if (self.itemSplitItemSegControl.selectedSegmentIndex == 0) {
                self.myInvoice.tipEntry = @"SHORTCUT18";
                
            }else if (self.itemSplitItemSegControl.selectedSegmentIndex == 1){
                self.myInvoice.tipEntry = @"SHORTCUT20";
                
            }else if (self.itemSplitItemSegControl.selectedSegmentIndex == 2){
                self.myInvoice.tipEntry = @"SHORTCUT22";
                
            }else{
                
                if ([self.itemTipText.text doubleValue] > 0) {
                    self.myInvoice.tipEntry = @"MANUAL";
                    
                }else{
                    self.myInvoice.tipEntry = @"NONE";
                    
                }
                
            }
            
        }else if (self.percentView.hidden == NO){
            
            if (self.percentTipText.text == nil) {
                self.percentTipText.text = @"0.0";
            }
            
            
            [self.myInvoice setGratuity:[ArcUtility roundUpToNearestPenny:[self.percentTipText.text doubleValue]]];
            [self.myInvoice setBasePaymentAmount:[ArcUtility roundUpToNearestPenny:self.percentYourPayment]];
            //NSLog(@"%f", self.percentYourPayment);
            
            self.myInvoice.splitType = @"PERCENT";
            
            if (self.percentYourPercentSegControl.selectedSegmentIndex == 0) {
                self.myInvoice.splitPercent = @"SHORTCUT25";
                
            }else if (self.percentYourPercentSegControl.selectedSegmentIndex == 1){
                self.myInvoice.splitPercent = @"SHORTCUT33";
                
            }else if (self.percentYourPercentSegControl.selectedSegmentIndex == 2){
                self.myInvoice.splitPercent = @"SHORTCUT50";
                
            }else{
                self.myInvoice.splitPercent = @"MANUAL";
                
            }
            
            
            if (self.percentTipSegment.selectedSegmentIndex == 0) {
                self.myInvoice.tipEntry = @"SHORTCUT18";
                
            }else if (self.percentTipSegment.selectedSegmentIndex == 1){
                self.myInvoice.tipEntry = @"SHORTCUT20";
                
            }else if (self.percentTipSegment.selectedSegmentIndex == 2){
                self.myInvoice.tipEntry = @"SHORTCUT22";
                
            }else{
                
                if ([self.percentTipText.text doubleValue] > 0) {
                    self.myInvoice.tipEntry = @"MANUAL";
                    
                }else{
                    self.myInvoice.tipEntry = @"NONE";
                    
                }
                
            }
            
        } else{
            
            if (self.dollarTipText.text == nil) {
                self.dollarTipText.text = @"0.0";
            }
            
            [self.myInvoice setGratuity:[self.dollarTipText.text doubleValue]];
            [self.myInvoice setBasePaymentAmount:[self.dollarYourPaymentText.text doubleValue]];
            
            self.myInvoice.splitType = @"DOLLAR";
            self.myInvoice.splitPercent = @"NONE";
            
            if (self.dollarTipSegment.selectedSegmentIndex == 0) {
                self.myInvoice.tipEntry = @"SHORTCUT18";
                
            }else if (self.dollarTipSegment.selectedSegmentIndex == 1){
                self.myInvoice.tipEntry = @"SHORTCUT20";
                
            }else if (self.dollarTipSegment.selectedSegmentIndex == 2){
                self.myInvoice.tipEntry = @"SHORTCUT22";
                
            }else{
                
                if ([self.dollarTipText.text doubleValue] > 0) {
                    self.myInvoice.tipEntry = @"MANUAL";
                    
                }else{
                    self.myInvoice.tipEntry = @"NONE";
                    
                }
                
            }
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.readyInvoiceForPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    @try {
        
        if ([[segue identifier] isEqualToString:@"dollarGoPayDwolla"]) {
            
            DwollaPayment *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
        }else if ([[segue identifier] isEqualToString:@"dollarGoPayCreditCard"]) {
            
            CreditCardPayment *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;
            
        }else if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
            
            RegisterDwollaView *controller = [segue destinationViewController];
            controller.fromSplitCheck = YES;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)percentYourPercentSegmentSelect{
    
    if ([self.percentYourPaymentText isFirstResponder]) {
        self.isSegmentPercentYour = YES;
    }
    
  
    if (self.percentYourPercentSegControl.selectedSegmentIndex == 0) {
        self.percentYourPaymentText.text = @"25";
    }else if (self.percentYourPercentSegControl.selectedSegmentIndex == 1){
        self.percentYourPaymentText.text = @"33.333333";

    }else if (self.percentYourPercentSegControl.selectedSegmentIndex == 2){
        self.percentYourPaymentText.text = @"50";

    }
    
    if ([self.percentYourPaymentText isFirstResponder]) {
        [self endText];

    }else{
        self.isSegmentPercentYour = YES;
        [self percentYourPercentDidEnd];
    }
    
    [self percentTipSegmentSelect];


}

- (IBAction)percentYourPercentDidEnd {
    
    if (self.isSegmentPercentYour) {
        self.isSegmentPercentYour = NO;
    }else{
      
        self.percentYourPercentSegControl.selectedSegmentIndex = -1;
    }
    
    double tip = [self.percentTipText.text doubleValue];
    
    double percentYourPayment = [self.percentYourPaymentText.text doubleValue]/100.0;
    double basePayment = [ArcUtility roundUpToNearestPenny:(percentYourPayment * [self.myInvoice amountDue])];
    if (basePayment < 0.0) {
        basePayment = 0.0;
    }
    
    
    if (basePayment > [self.myInvoice amountDueForSplit] && basePayment != 0.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Over Payment" message:@"Payment cannot exceed 'Amount Remaining'." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:@"Pay Remaining", nil];
        
        [alert show];
    } else {
        self.percentYourPaymentDollarAmount.text = [NSString stringWithFormat:@"($%.2f)", basePayment];
        self.percentYourPayment = basePayment;
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", (basePayment + tip)];

    }
    
    [self percentTipSegmentSelect];
    
}


- (IBAction)percentTipSegmentSelect{
    
    @try {
        
        if ([self.percentTipText isFirstResponder]) {
            self.isSegmentPercentTip = YES;
        }
        
        if ([self.percentYourPaymentText isFirstResponder]) {
            self.isSegmentPercentYour = YES;
        }
        
        double tipPercent = 0.0;
        if (self.percentTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .18;
        }else if (self.percentTipSegment.selectedSegmentIndex == 1){
            tipPercent = .20;
        }else if (self.percentTipSegment.selectedSegmentIndex == 2){
            tipPercent = .22;
        }
        
        double percentYourPayment = [self.percentYourPaymentText.text doubleValue]/100.0;
        double payment = [ArcUtility roundUpToNearestPenny:(percentYourPayment * [self.myInvoice amountDue])];
        double baseTipPayment = percentYourPayment * [self.myInvoice subtotal];

        double tipAmount = [ArcUtility roundUpToNearestPenny:(tipPercent * baseTipPayment)];
        self.percentTipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", (payment + tipAmount)];
        
        [self endText];

        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.percentTipSegmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

    
    
}

- (IBAction)percentTipEditEnd{
    
    @try {
        
        if (self.isSegmentPercentTip) {
            self.isSegmentPercentTip = NO;
        }else{
            self.percentTipSegment.selectedSegmentIndex = -1;
        }
        
        double tip = [self.percentTipText.text doubleValue];
        if (tip < 0.0) {
            tip = 0.0;
        }
        
        double percentYourPayment = [self.percentYourPaymentText.text doubleValue]/100.0;
        double payment = [ArcUtility roundUpToNearestPenny:(percentYourPayment * [self.myInvoice amountDue])];
        
        self.percentTipText.text = [NSString stringWithFormat:@"%.2f", tip];
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", (payment + tip)];
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.percentTipEditEnd" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        return [self.itemArray count];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        NSUInteger row = [indexPath row];
        static NSString *itemCell=@"itemCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCell];
    
        
        NSDictionary *tmpItem = [self.itemArray objectAtIndex:row];
        
        UILabel *itemlabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:2];
        
        itemlabel.text = [tmpItem valueForKey:@"Description"];
        
        double price = [[tmpItem valueForKey:@"splitValue"] doubleValue];
        
        priceLabel.text = [NSString stringWithFormat:@"$%.2f", price];
        
        if ([[tmpItem valueForKey:@"selected"] isEqualToString:@"yes"]) {
            cell.contentView.backgroundColor = [UIColor greenColor];
        }else if ([[tmpItem valueForKey:@"selected"] isEqualToString:@"maybe"]){
            cell.contentView.backgroundColor = [UIColor yellowColor];
        }else{
            cell.contentView.backgroundColor = [UIColor whiteColor];

        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        MyGestureRecognizer *lpgr = [[MyGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		lpgr.minimumPressDuration = 0.5f; //seconds
		lpgr.delegate = self;
        lpgr.selectedCell = row;
		[cell addGestureRecognizer:lpgr];
        
        
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)longPress:(id)sender{
    
    [self endText];
    MyGestureRecognizer *myPress = (MyGestureRecognizer *)sender;
    
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.frame = self.itemSplitItemView.bounds;
    self.itemSplitItemView.backgroundColor = [UIColor clearColor];
    UIColor *myColor1 = [UIColor colorWithRed:114.0*1.1/255.0 green:168.0*1.1/255.0 blue:192.0*1.1/255.0 alpha:1.0];
    gradient1.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor1 CGColor], nil];
    [self.itemSplitItemView.layer insertSublayer:gradient1 atIndex:0];
    
    double theTotal = [[[self.itemArray objectAtIndex:myPress.selectedCell] valueForKey:@"splitValue"] doubleValue];
    
    self.itemSplitItemIndex = myPress.selectedCell;
    
    self.itemSplitItemItemTotal.text = [NSString stringWithFormat:@"$%.2f", theTotal];
    self.itemSplitItemView.hidden = NO;
    
    double myAmount = [[[self.itemArray objectAtIndex:myPress.selectedCell] valueForKey:@"myAmount"] doubleValue];
    
    if (myAmount > 0) {
        
        self.itemSplitItemYourAmount.text = [NSString stringWithFormat:@"%.2f", myAmount];
    }else{
        self.itemSplitItemYourAmount.text = @"";
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *tmp = [self.itemArray objectAtIndex:indexPath.row];
    
    double value = [[tmp valueForKey:@"splitValue"] doubleValue];
    
    if ([[tmp valueForKey:@"selected"] isEqualToString:@"yes"]) {
        [tmp setValue:@"no" forKey:@"selected"];
        self.itemTotal -= (value * (1 - self.discountPercentage));
    }else if ([[tmp valueForKey:@"selected"] isEqualToString:@"maybe"]){
        [tmp setValue:@"no" forKey:@"selected"];
        
        double myValue = [[tmp valueForKey:@"myAmount"] doubleValue];
        self.itemTotal -= (myValue * (1 - self.discountPercentage));

    }else{
        [tmp setValue:@"yes" forKey:@"selected"];
        self.itemTotal += (value * (1 - self.discountPercentage));
    }
    
    
    self.itemTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.taxPercentage * self.itemTotal];
    self.itemServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.serviceChargePercentage * self.itemTotal];

    [self showItemTotal];
    [self.itemTableView reloadData];
    
    [self itemTipSegmentSelect];

}

-(void)showItemTotal{
    double taxTotal = [ArcUtility roundUpToNearestPenny:(self.taxPercentage * self.itemTotal)];
    
    double serviceTotal = [ArcUtility roundUpToNearestPenny:(self.serviceChargePercentage * self.itemTotal)];
    
    double tipTotal = [self.itemTipText.text doubleValue];
    
    double total = tipTotal + self.itemTotal + taxTotal + serviceTotal;
    
    self.itemYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", total];
}

- (IBAction)itemTipDidBegin{
    [rSkybox addEventToSession:@"itemTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.itemView.frame = CGRectMake(0, -120, 320, self.view.frame.size.height - 88);
    }];
}

- (IBAction)itemTipEditEnd{
    
    if (self.isSegmentItemized) {
        self.isSegmentItemized = NO;
    }else{
        self.itemTipSegment.selectedSegmentIndex = -1;
    }
    
    [self showItemTotal];
}

- (IBAction)itemTipSegmentSelect{
    
    @try {
        
        if ([self.itemTipText isFirstResponder]) {
            self.isSegmentItemized = YES;
        }
        
        double tipPercent = 0.0;
        if (self.itemTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .18;
        }else if (self.itemTipSegment.selectedSegmentIndex == 1){
            tipPercent = .20;
        }else if (self.itemTipSegment.selectedSegmentIndex == 2){
            tipPercent = .22;
        }
        
        double tipAmount = [ArcUtility roundUpToNearestPenny:(tipPercent * self.itemTotal)];
        
        self.itemTipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];

        [self showItemTotal];
        
        
        [self endText];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.itemTipSegmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

- (IBAction)itemSplitItemCancel {
    
    self.itemSplitItemSegControl.selectedSegmentIndex = -1;
    self.itemSplitItemView.hidden = YES;
}

- (IBAction)itemSplitItemSave {
    
    self.itemSplitItemView.hidden = YES;
    NSDictionary *tmp = [self.itemArray objectAtIndex:self.itemSplitItemIndex];

    
    double initValue = [[tmp valueForKey:@"splitValue"] doubleValue];
    double value = [self.itemSplitItemYourAmount.text doubleValue];
    
    [tmp setValue:[NSString stringWithFormat:@"%f", value] forKey:@"myAmount"];
    
    if ([[tmp valueForKey:@"selected"] isEqualToString:@"yes"]) {
        [tmp setValue:@"maybe" forKey:@"selected"];
        self.itemTotal -= initValue;
        self.itemTotal += value;
        
    }else{
        [tmp setValue:@"maybe" forKey:@"selected"];
        self.itemTotal += value;
    }
    
    
    self.itemTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.taxPercentage * self.itemTotal];
    self.itemServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.serviceChargePercentage * self.itemTotal];
    
    [self showItemTotal];
    [self.itemTableView reloadData];
    self.itemSplitItemSegControl.selectedSegmentIndex = -1;


    [self itemTipSegmentSelect];

}

// TODO don't think this method is still used
- (IBAction)itemSplitItemYourAmountTextEnd {
    
    double yourPay = [self.itemSplitItemYourAmount.text doubleValue];    
    self.itemSplitItemYourAmount.text = [NSString stringWithFormat:@"%.2f", yourPay];
    
}

// TODO don't think this method is still used
- (IBAction)itemSplitItemSegmentSelect {
    
    double amount = [[[self.itemArray objectAtIndex:self.itemSplitItemIndex] valueForKey:@"splitValue"] doubleValue];
    double percent = 0.0;
    
    if (self.itemSplitItemSegControl.selectedSegmentIndex == 0) {
        percent = 0.20;
    }else if (self.itemSplitItemSegControl.selectedSegmentIndex == 1){
        percent = 0.25;

    }else if (self.itemSplitItemSegControl.selectedSegmentIndex == 2){
        percent = 0.33333333;

    }else{
        percent = 0.5;

    }
    
    self.itemSplitItemYourAmount.text = [NSString stringWithFormat:@"%.2f", amount * percent];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == self.percentYourPaymentText) {
        
        if ([self.percentYourPaymentText.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
        
    }else if (textField == self.percentTipText){
        
        if ([self.percentTipText.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
    }else if (textField == self.dollarTipText){
        
        if ([self.dollarTipText.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
    }else if (textField == self.dollarYourPaymentText){
        
        if ([self.dollarYourPaymentText.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
    }else if (textField == self.itemSplitItemYourAmount){
        
        if ([self.itemSplitItemYourAmount.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
    }else if (textField == self.itemTipText){
        
        if ([self.itemTipText.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
    }


    return TRUE;
}


-(void)hideKeyboard{
    [self endText];

}

-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyboardY = 156;
        if (self.isIphone5) {
            keyboardY = 244;
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
        [rSkybox sendClientLog:@"RegisterView.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)refreshInvoice{
    
    [self.activity startAnimating];
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    
    NSString *merchantId = [NSString stringWithFormat:@"%d", self.myInvoice.merchantId];
    [tempDictionary setValue:self.myInvoice.number forKey:@"invoiceNumber"];
    [tempDictionary setValue:merchantId forKey:@"merchantId"];
    
    NSDictionary *loginDict = [[NSDictionary alloc] init];
    loginDict = tempDictionary;
    
    ArcClient *client = [[ArcClient alloc] init];
    [client getInvoice:loginDict];
}


-(void)invoiceComplete:(NSNotification *)notification{
    @try {
        
        [self.activity stopAnimating];
                
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
            
            self.myInvoice.subtotal = [[theInvoice valueForKey:@"BaseAmount"] doubleValue];
            self.myInvoice.serviceCharge = [[theInvoice valueForKey:@"ServiceCharge"] doubleValue];
            self.myInvoice.tax = [[theInvoice valueForKey:@"Tax"] doubleValue];
            self.myInvoice.discount = [[theInvoice valueForKey:@"Discount"] doubleValue];
            self.myInvoice.additionalCharge = [[theInvoice valueForKey:@"AdditionalCharge"] doubleValue];
            
            self.myInvoice.dateCreated = [theInvoice valueForKey:@"DateCreated"];
            
            self.myInvoice.tags = [NSArray arrayWithArray:[theInvoice valueForKey:@"Tags"]];
            self.myInvoice.items = [NSArray arrayWithArray:[theInvoice valueForKey:@"Items"]];
            self.myInvoice.payments = [NSArray arrayWithArray:[theInvoice valueForKey:@"Payments"]];
            self.myInvoice.paymentsAccepted = self.paymentsAccepted;
            
            [self setUpView];
            [self changePreviousView];
            
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INVOICE_NOT_FOUND) {
                errorMsg = @"Can not find invoice.";
            } else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            // self.errorLabel.text = errorMsg;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.invoiceComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)changePreviousView{
    
    NSArray *views = [self.navigationController viewControllers];
    int count = [views count];
    
    InvoiceView *tmp = [views objectAtIndex:count - 2];
    tmp.myInvoice = self.myInvoice;
    [tmp setUpView];
}

-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}


@end
