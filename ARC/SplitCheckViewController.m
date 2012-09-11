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


@interface SplitCheckViewController ()

@end

@implementation SplitCheckViewController
@synthesize divisionTypeSegment;
@synthesize splitSaveButton;
@synthesize splitCancelButton;
@synthesize dollarAmountAlreadyPaidNameLabel;
@synthesize itemSplitItemSegControl;
@synthesize itemSplitItemItemTotal;
@synthesize itemSplitItemYourAmount;
@synthesize itemSplitItemView;
@synthesize itemTaxLabel;
@synthesize itemServiceChargeLabel;
@synthesize percentFoodBevLabel;
@synthesize percentServiceChargeLabel;
@synthesize percentTaxLabel;
@synthesize dollarFoodBevLabel;
@synthesize dollarServiceChargeLabel;
@synthesize dollarTaxLabel;
@synthesize percentYourPercentSegControl;
@synthesize itemYourTotalPaymentLabel;
@synthesize itemTableView;
@synthesize percentYourPaymentDollarAmount;
@synthesize percentTipSegment;


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
      
        

        
        
        /*
        self.dollarAmountAlreadyPaidNameLabel.font = [UIFont fontWithName:@"Corbel-Bold" size:21];
        self.dollarAmountDueLabel.font = [UIFont fontWithName:@"Corbel Bold" size:21];
        self.dollarAmountDueNameLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarAmountPaidLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarFoodBevLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarServiceChargeLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarTaxLabel.font = [UIFont fontWithName:@"Corbel Bold" size:21];
        self.dollarTotalBillLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarTotalBillNameLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarYourPaymentNameLabel.font = [UIFont fontWithName:@"Corbel" size:21];
        self.dollarYourTotalPaymentLabel.font = [UIFont fontWithName:@"Corbel Bold" size:21];
         */
        
        [rSkybox addEventToSession:@"signInComplete"];
        
        
        [[self.itemSplitItemView layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[self.itemSplitItemView layer] setBorderWidth:1.0];
        [[self.itemSplitItemView layer] setCornerRadius:5];
        [self.itemSplitItemView setClipsToBounds: YES];
        

        self.itemSplitItemView.hidden = YES;
        
        //self.myInvoice.tax = 0.11;
        //self.myInvoice.serviceCharge = 0.20;
        
        //Calculate tax and service charage for % and $$
        
        self.baseDollarValue = self.myInvoice.baseAmount;
        self.taxDollarValue = self.baseDollarValue * self.myInvoice.tax;
        self.serviceChargeDollarValue = self.baseDollarValue * self.myInvoice.serviceCharge;
        
        //set labels
        
        self.percentFoodBevLabel.text = [NSString stringWithFormat:@"$%.2f", self.baseDollarValue];
        self.percentTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.taxDollarValue];
        self.percentServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.serviceChargeDollarValue];
        
        self.dollarFoodBevLabel.text = [NSString stringWithFormat:@"$%.2f", self.baseDollarValue];
        self.dollarTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.taxDollarValue];
        self.dollarServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.serviceChargeDollarValue];
        
        
        self.dollarView.hidden = NO;
        self.percentView.hidden = YES;
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
        
        
        
     
        
        // *** TODO get Jim to change API and/or put this calculation inside of the Invoice class ****
        double serviceCharge = (self.myInvoice.baseAmount * self.myInvoice.serviceCharge);
        double tax = (self.myInvoice.baseAmount * self.myInvoice.tax);
        double discount = (self.myInvoice.baseAmount * self.myInvoice.discount);
        self.totalBill = self.myInvoice.baseAmount + serviceCharge + tax - discount;
        double amountPaid = [self calculateAmountPaid];
        self.amountDue = self.totalBill - amountPaid;
        
        
        self.dollarTotalBillLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalBill];
        self.dollarAmountPaidLabel.text = [NSString stringWithFormat:@"$%.2f", amountPaid];
        self.dollarAmountDueLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", 0.0];
        
        self.percentTotalBillLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalBill];
        self.percentAmountPaidLabel.text = [NSString stringWithFormat:@"$%.2f", amountPaid];
        self.percentAmountDueLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue];
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", 0.0];
        
        self.itemYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", 0.0];

        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        self.dollarView.backgroundColor = [UIColor clearColor];
        self.percentView.backgroundColor = [UIColor clearColor];
        self.itemView.backgroundColor = [UIColor clearColor];
        
        self.itemArray = [NSMutableArray array];
        

    
        NSMutableArray *invoiceItems= [[NSMutableArray alloc]initWithArray:self.myInvoice.items];

        
        for (int i = 0; i < [invoiceItems count]; i++) {
            
            NSDictionary *oldItem = [invoiceItems objectAtIndex:i];
            
            int number = [[oldItem valueForKey:@"Amount"] intValue];
            
            [oldItem setValue:@"no" forKey:@"selected"];
            [oldItem setValue:@"0" forKey:@"myAmount"];

            [oldItem setValue:@"1" forKey:@"splitAmount"];
            
            double price = [[oldItem valueForKey:@"Value"] doubleValue];
            
            price  = price / (double)number;
            
            [oldItem setValue:[NSString stringWithFormat:@"%f", price] forKey:@"splitValue"];
            
            
            for (int j = 0; j < number; j++) {
                
                NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:oldItem];
                [self.itemArray addObject:newItem];
            }
            
        }
        
        [self.itemTableView reloadData];
        
        
      

    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }

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
            
            if (![[NSUserDefaults standardUserDefaults] valueForKey:@"didShowItemBeta"]) {
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowItemBeta"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIAlertView *betaAlert = [[UIAlertView alloc] initWithTitle:@"Beta Version" message:@"Itemized check splitting is currently in beta.  Please be sure that multiple people do not select and pay for the same item!  ARC will verify for you that this does not happen in the next release.  Thank you!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
    [self.itemTipText resignFirstResponder];
    [self.percentTipText resignFirstResponder];

    [UIView animateWithDuration:0.3 animations:^{
        
        self.dollarView.frame = CGRectMake(0, 44, 320, 328);
        self.percentView.frame = CGRectMake(0, 44, 320, 328);
        self.itemView.frame = CGRectMake(0, 44, 320, 328);
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
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", self.yourTotalPayment];
        
        
        
        [self endText];
        
        
  
      
        
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
   // self.dollarTipSegment.selectedSegmentIndex = -1;
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
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", self.yourTotalPayment];
        
                
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
    self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", self.yourTotalPayment];
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
                [action addButtonWithTitle:[NSString stringWithFormat:@"%@", tmpCard.sample]];
                
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
    
    double gratuity = 0.0;
    
    if (self.itemView.hidden == NO) {
        gratuity = [self.itemTipText.text doubleValue];
    }else if (self.percentView.hidden == NO){
        gratuity = [self.percentTipText.text doubleValue];
    }else{
        gratuity = [self.dollarTipText.text doubleValue];
    }
    @try {
        
        if ([[segue identifier] isEqualToString:@"dollarGoPayDwolla"]) {
            
            DwollaPayment *controller = [segue destinationViewController];
            controller.totalAmount = [[NSString stringWithFormat:@"%f", self.yourPayment] doubleValue];
            controller.gratuity = gratuity;
            controller.invoiceId = self.myInvoice.invoiceId;
            
        }else if ([[segue identifier] isEqualToString:@"dollarGoPayCreditCard"]) {
            
            CreditCardPayment *controller = [segue destinationViewController];
            controller.totalAmount = [[NSString stringWithFormat:@"%f", self.yourPayment] doubleValue];
            controller.gratuity = gratuity;
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


-(void)percentYourPercentSegmentSelect{
    
    if (self.percentYourPercentSegControl.selectedSegmentIndex == 0) {
        self.percentYourPaymentText.text = @"25";
    }else if (self.percentYourPercentSegControl.selectedSegmentIndex == 1){
        self.percentYourPaymentText.text = @"33.333333";

    }else{
        self.percentYourPaymentText.text = @"50";

    }
    
    //[self percentYourPercentDidEnd];
   // [self.percentYourPaymentText resignFirstResponder];
    
    if ([self.percentYourPaymentText isFirstResponder]) {
        [self endText];

    }else{
        [self percentYourPercentDidEnd];
    }

}

- (IBAction)percentYourPercentDidEnd {
    
    double tip = [self.percentTipText.text doubleValue];
    
    double percentYourPayment = [self.percentYourPaymentText.text doubleValue]/100.0;
    self.yourPayment = percentYourPayment * self.totalBill;
    
    self.percentYourPaymentDollarAmount.text = [NSString stringWithFormat:@"($%.2f)", self.yourPayment];
    
    if (self.yourPayment < 0.0) {
        self.yourPayment = 0.0;
    }
    self.yourTotalPayment = self.yourPayment + tip;
    
    //self.percentYourPaymentText.text = [NSString stringWithFormat:@"%.2f", self.yourPayment];
    self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", self.yourTotalPayment];
    
    
}


- (IBAction)percentTipSegmentSelect{
    
    @try {
        [self performSelector:@selector(resetSegment) withObject:nil afterDelay:0.2];
        
        double tipPercent = 0.0;
        if (self.percentTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .10;
        }else if (self.percentTipSegment.selectedSegmentIndex == 1){
            tipPercent = .15;
        }else{
            tipPercent = .20;
        }
        
        double percentYourPayment = [self.percentYourPaymentText.text doubleValue]/100.0;
        self.yourPayment = percentYourPayment * self.totalBill;
        
        double tipAmount = tipPercent * self.yourPayment;
        self.yourTotalPayment = self.yourPayment + tipAmount;
        self.percentTipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", self.yourTotalPayment];
        
        
        
        [self endText];

        
        
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.percentTipSegmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

    
    
}

- (IBAction)percentTipEditEnd{
    
    @try {
        
    
        double tip = [self.percentTipText.text doubleValue];
        if (tip < 0.0) {
            tip = 0.0;
        }
        self.yourPayment = [self.percentYourPaymentText.text doubleValue];
        self.yourTotalPayment = self.yourPayment + tip;
        
        self.percentTipText.text = [NSString stringWithFormat:@"%.2f", tip];
        self.percentYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", self.yourTotalPayment];
        
        
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
        self.itemTotal -= value;
    }else if ([[tmp valueForKey:@"selected"] isEqualToString:@"maybe"]){
        [tmp setValue:@"no" forKey:@"selected"];
        
        double myValue = [[tmp valueForKey:@"myAmount"] doubleValue];
        self.itemTotal -= myValue;

    }else{
        [tmp setValue:@"yes" forKey:@"selected"];
        self.itemTotal += value;
    }
    
    
    self.itemTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.itemTotal * self.myInvoice.tax];
    self.itemServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.itemTotal * self.myInvoice.serviceCharge];

    [self showItemTotal];
    [self.itemTableView reloadData];
}

-(void)showItemTotal{
    
    double taxTotal = self.itemTotal * self.myInvoice.tax;
    double serviceTotal = self.itemTotal * self.myInvoice.serviceCharge;
    
    double tipTotal = [self.itemTipText.text doubleValue];
    
    double total = tipTotal + self.itemTotal + taxTotal + serviceTotal;
    
    self.yourPayment = total;
    
    self.itemYourTotalPaymentLabel.text = [NSString stringWithFormat:@"$%.2f", total];
}

- (IBAction)itemTipDidBegin{
    [rSkybox addEventToSession:@"itemTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.itemView.frame = CGRectMake(0, -120, 320, 328);
    }];
}

- (IBAction)itemTipEditEnd{
    
    [self showItemTotal];
}
- (IBAction)itemTipSegmentSelect{
    
    @try {
        [self performSelector:@selector(resetSegment) withObject:nil afterDelay:0.2];
        
        double tipPercent = 0.0;
        if (self.itemTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .10;
        }else if (self.itemTipSegment.selectedSegmentIndex == 1){
            tipPercent = .15;
        }else{
            tipPercent = .20;
        }
        
        double tipAmount = tipPercent * self.itemTotal;
        
        self.itemTipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];

        [self showItemTotal];
        
        
        [self endText];

        
        
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.itemTipSegmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

    
}
- (void)viewDidUnload {
    [self setItemTaxLabel:nil];
    [self setItemServiceChargeLabel:nil];
    [self setItemSplitItemView:nil];
    [self setItemSplitItemItemTotal:nil];
    [self setItemSplitItemYourAmount:nil];
    [self setItemSplitItemSegControl:nil];
    [self setDollarAmountAlreadyPaidNameLabel:nil];
    [self setDivisionTypeSegment:nil];
    [self setSplitSaveButton:nil];
    [self setSplitCancelButton:nil];
    [super viewDidUnload];
}
- (IBAction)itemSplitItemCancel {
    
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
    
    
    self.itemTaxLabel.text = [NSString stringWithFormat:@"$%.2f", self.itemTotal * self.myInvoice.tax];
    self.itemServiceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", self.itemTotal * self.myInvoice.serviceCharge];
    
    [self showItemTotal];
    [self.itemTableView reloadData];
    

}
- (IBAction)itemSplitItemYourAmountTextEnd {
    
    double yourPay = [self.itemSplitItemYourAmount.text doubleValue];
    
    if (self.yourPayment < 0.0) {
        self.yourPayment = 0.0;
    }
    
    self.itemSplitItemYourAmount.text = [NSString stringWithFormat:@"%.2f", yourPay];
    
    
}
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
@end
