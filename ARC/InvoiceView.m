//
//  InvoiceView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "InvoiceView.h"
#import "DwollaPayment.h"
#import "CreditCardPayment.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "SplitCheckViewController.h"
#import "HomeNavigationController.h"
#import "RegisterDwollaView.h"
#import "ArcClient.h"
#import "ArcUtility.h"

@interface InvoiceView ()

@end

@implementation InvoiceView

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

    
   
-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceComplete:) name:@"invoiceNotification" object:nil];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
    // adjust if payments have already been made
    
    
    if (self.myInvoice.serviceCharge > 0.0) {
        
        BOOL showAlert = YES;
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"showedGratuityAlert"] length] > 0) {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"showedGratuityAlert"] isEqualToString:@"yes"]) {
                showAlert = NO;
            }
        }
        if (showAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added Service Charge" message:@"Please note that gratuity has already been added to your bill.  For this and all future purchases, you can see the added gratuity amount as 'Service Charge' on your receipt." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"showedGratuityAlert"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    [self willAppearSetup];
  
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if (self.fromDwolla) {
        
        self.fromDwolla = NO;
        if (self.dwollaSuccess) {
            
            [rSkybox addEventToSession:@"selectedDwollaForPayment"];

            [self performSegueWithIdentifier:@"goPayDwolla" sender:self];

            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" message:@"Dwolla could not authenticate your credentials, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)viewDidLoad
{
    @try {
        
    
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Invoice"];
        self.navigationItem.titleView = navLabel;
  
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Invoice"];
		self.navigationItem.backBarButtonItem = temp;
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
               
        [super viewDidLoad];
        
      
        [self setUpView];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        self.tipText.delegate = self;

        // numeric keyboard with a period
        self.tipText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
            self.tipText.keyboardType = UIKeyboardTypeDecimalPad;
        }
        
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
  
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)setUpView{
    
    self.subLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice subtotal]];
    self.taxLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.tax];
    self.gratLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.serviceCharge];
    self.discLabel.text = [NSString stringWithFormat:@"- $%.2f", self.myInvoice.discount];
    

    
    int tableCount = [self.myInvoice.items count];
    
    double amountPaid = [self.myInvoice calculateAmountPaid];
    if(amountPaid > 0.0) {
        tableCount++;
    }
    
    int tableHeight = tableCount * 24 + tableCount + 10;
    
    self.myTableView.frame = CGRectMake(0, 20, 300, tableHeight);
    
    self.dividerLabel.frame = CGRectMake(0, tableHeight + 10, 300, 21);
    int bottomViewY = tableHeight + 20;
    
    if (bottomViewY < 120) {
        bottomViewY = 120;
        int height = (120 - tableHeight)/2 + tableHeight;
        self.dividerLabel.frame = CGRectMake(0, height, 300, 21);
    }
    
    self.bottomHalfView.frame = CGRectMake(0, bottomViewY, 300, 134);
    
    
    
    //bottom view
    int yValue = 34;
    
    if (self.myInvoice.serviceCharge == 0.0) {
        self.gratLabel.hidden = YES;
        self.gratNameLabel.hidden = YES;
    }else{
        yValue += 20;
        
        CGRect frame = self.gratLabel.frame;
        frame.origin.y = yValue;
        self.gratLabel.frame = frame;
        
        CGRect frameName = self.gratNameLabel.frame;
        frameName.origin.y = yValue;
        self.gratNameLabel.frame = frameName;
        
    }
    
    if (self.myInvoice.discount == 0.0) {
        self.discLabel.hidden = YES;
        self.discNameLabel.hidden = YES;
    }else{
        
        yValue += 20;
        
        CGRect frame = self.discLabel.frame;
        frame.origin.y = yValue;
        self.discLabel.frame = frame;
        
        CGRect frameName = self.discNameLabel.frame;
        frameName.origin.y = yValue - 2;
        self.discNameLabel.frame = frameName;
        
        
        
    }
    
    
    if(amountPaid > 0.0) {
        
        self.payBillButton.title = @"Pay Remaining";
        self.isPartialPayment = YES;
        self.alreadyPaidLabel.hidden = NO;
        self.alreadyPaidNameLabel.hidden = NO;
        self.alreadyPaidLabel.text = [NSString stringWithFormat:@"-$%.2f", amountPaid];
        
        yValue += 20;
        
        CGRect frame = self.alreadyPaidLabel.frame;
        frame.origin.y = yValue;
        self.alreadyPaidLabel.frame = frame;
        
        CGRect frameName = self.alreadyPaidNameLabel.frame;
        frameName.origin.y = yValue;
        self.alreadyPaidNameLabel.frame = frameName;
        
        
    }else{
        
        self.alreadyPaidLabel.hidden = YES;
        self.alreadyPaidNameLabel.hidden = YES;
    }
    
    
    CGRect frame = self.bottomHalfView.frame;
    frame.size.height = yValue + 45;
    self.bottomHalfView.frame = frame;
    
    
    CGRect frameAmountName = self.amountNameLabel.frame;
    frameAmountName.origin.y = yValue + 27;
    self.amountNameLabel.frame = frameAmountName;
    
    CGRect frameAmount = self.amountLabel.frame;
    frameAmount.origin.y = yValue + 23;
    self.amountLabel.frame = frameAmount;
    double myDue = self.myInvoice.amountDue - amountPaid;
    self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", myDue];
    
    CGRect frameLine = self.dividerView.frame;
    frameLine.origin.y = yValue + 18;
    self.dividerView.frame = frameLine;
    
    
    [self.scrollView setContentSize:CGSizeMake(300, bottomViewY + yValue + 50)];
    
    // this method is called after refresh too, so tip may need to be recalculated
    [self segmentSelect];
    
}

-(void)willAppearSetup{
    double amountPaid = [self.myInvoice calculateAmountPaid];
    if(amountPaid > 0.0) {
        
        self.payBillButton.title = @"Pay Remaining";
        self.isPartialPayment = YES;
        
    }
    
    //To only show amount due at bottom, and already paid as a line item
    double amountDue = self.myInvoice.amountDue;
    
    double remaining = amountDue - amountPaid;
    if (remaining < 0.0001) {
        remaining = 0;
    }
    
    double totalPayment = remaining + [self.tipText.text doubleValue];
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", totalPayment];
    
    [self.myTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        return [self.myInvoice.items count];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        static NSString *FirstLevelCell=@"FirstLevelCell";
        
        static NSInteger itemTag = 1;
        static NSInteger numberTag = 2;
        static NSInteger priceTag = 3;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier: FirstLevelCell];
            
            
            
            UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 3, 188, 20)];
            itemLabel.tag = itemTag;
            [cell.contentView addSubview:itemLabel];
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 2, 75, 20)];
            priceLabel.tag = priceTag;
            [cell.contentView addSubview:priceLabel];
            
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 2, 32, 20)];
            numberLabel.tag = numberTag;
            [cell.contentView addSubview:numberLabel];
            
            
            
            
        }
        
        UILabel *itemLabel = (UILabel *)[cell.contentView viewWithTag:itemTag];
        UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
        UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:priceTag];
        
        NSUInteger row = [indexPath row];

        
     
        
        itemLabel.backgroundColor = [UIColor clearColor];
        numberLabel.backgroundColor = [UIColor clearColor];
        priceLabel.backgroundColor = [UIColor clearColor];
        
        itemLabel.font = [UIFont fontWithName:@"Corbel" size:14];
        numberLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
        priceLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
        
        priceLabel.textAlignment = UITextAlignmentRight;
        numberLabel.textAlignment = UITextAlignmentLeft;
        
        
        NSDictionary *itemDictionary = [self.myInvoice.items objectAtIndex:row];
        
        itemLabel.text = [itemDictionary valueForKey:@"Description"];
        
        int num = [[itemDictionary valueForKey:@"Amount"] intValue];
        double value = [[itemDictionary valueForKey:@"Value"] doubleValue] * num;

    
        priceLabel.text = [NSString stringWithFormat:@"$%.2f", value];
        
        numberLabel.text = [NSString stringWithFormat:@"%d", [[itemDictionary valueForKey:@"Amount"] intValue]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24;
}


- (IBAction)payNow:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"clickedPayButton"];
        
        BOOL haveCards;
        BOOL haveDwolla;
        BOOL showSheet = YES;
        
        if([self.myInvoice calculateAmountPaid] > 0) {
            [ArcClient trackEvent:@"PAY_REMAINING"];
        }

        
        [self.tipText resignFirstResponder];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
        
        if ([self.creditCards count] == 0) {
            haveCards = NO;
        }else{
            haveCards = YES;
        }
        
        NSString *token;
        
        @try {
            token = [DwollaAPI getAccessToken];
        }
        @catch (NSException *exception) {
            
        }
       
        if ([token length] > 0) {
            haveDwolla = YES;
        }else{
            haveDwolla = NO;
        }
        
        if (haveDwolla || haveCards) {
            
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
                
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                int x = 0;
                if (haveDwolla) {
                    x++;
                    [self.actionSheet addButtonWithTitle:@"Dwolla"];
                }
                
                for (int i = 0; i < [self.creditCards count]; i++) {
                    CreditCard *tmpCard = (CreditCard *)[self.creditCards objectAtIndex:i];
                    [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", tmpCard.sample]];
                    
                }
                [self.actionSheet addButtonWithTitle:@"Cancel"];
                self.actionSheet.cancelButtonIndex = [self.creditCards count] + x;
                
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not All Cards Accepted" message:@"One or more of your saved credit cards are not accepted by this merchant.  You will not see these cards in the list of payment choices" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }else{
                
                if (showSheet) {
                    [self.actionSheet showInView:self.view];

                }
                
            }
            
        }else{
            [self noPaymentSources];
        }
               
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.payNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.actionSheet showInView:self.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        
        BOOL haveDwolla = NO;
        NSString *token;
        
        @try {
            token = [DwollaAPI getAccessToken];
        }
        @catch (NSException *exception) {
            
        }
        
        int x = 0;
        if ([token length] > 0) {
            x++;
            haveDwolla = YES;
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
                
                [self performSegueWithIdentifier:@"goPayCreditCard" sender:self];
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
                    
                    [self performSegueWithIdentifier:@"goPayCreditCard" sender:self];
                    
                }
            }
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)editBegin:(id)sender {
    @try {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        self.view.frame = CGRectMake(0, -165, 320, self.view.frame.size.height);
        [self showDoneButton];
        
        [UIView commitAnimations];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.editBegin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)editEnd:(id)sender {
    @try {
        
        
        double tip = [self.tipText.text doubleValue];
        
        if (tip < 0.0) {
            tip = 0.0;
        }
        
        self.tipText.text = [NSString stringWithFormat:@"%.2f", tip];
        self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", ([self.myInvoice amountDue] - [self.myInvoice calculateAmountPaid] + tip)];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.editEnd" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        double tipAmount = 0.0f;
        if (self.tipText.text != nil) {
            tipAmount = [self.tipText.text doubleValue];
        }
        [self.myInvoice setGratuityByAmount:tipAmount];
        
        
        //For Metrics
        self.myInvoice.splitType = @"NONE";
        self.myInvoice.splitPercent = @"NONE";
        
        if (self.tipSegment.selectedSegmentIndex == 0) {
            self.myInvoice.tipEntry = @"SHORTCUT18";

        }else if (self.tipSegment.selectedSegmentIndex == 1){
            self.myInvoice.tipEntry = @"SHORTCUT20";

        }else if (self.tipSegment.selectedSegmentIndex == 2){
            self.myInvoice.tipEntry = @"SHORTCUT22";

        }else{
            
            if (tipAmount > 0) {
                self.myInvoice.tipEntry = @"MANUAL";

            }else{
                self.myInvoice.tipEntry = @"NONE";

            }

        }
        
        if ([[segue identifier] isEqualToString:@"goPayDwolla"]) {
            
            // on this screen, can only pay the full remaining amount due
            double basePayment = [self.myInvoice amountDue] - [self.myInvoice calculateAmountPaid];
            [self.myInvoice setBasePaymentAmount:basePayment];
            
            DwollaPayment *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;            
            
        }else if ([[segue identifier] isEqualToString:@"goPayCreditCard"]) {
            
            // on this screen, can only pay the full remaining amount due
            double basePayment = [self.myInvoice amountDue] - [self.myInvoice calculateAmountPaid];
            [self.myInvoice setBasePaymentAmount:basePayment];
            
            CreditCardPayment *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;
            
        }else if ([[segue identifier] isEqualToString:@"goSplitCheck"]) {
            
            
            SplitCheckViewController *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            controller.paymentsAccepted = self.paymentsAccepted;
            
        }else if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
            
            RegisterDwollaView *controller = [segue destinationViewController];
            controller.fromInvoice = YES;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)segmentSelect {
    @try {

        
        double tipPercent = 0.0;
        if (self.tipSegment.selectedSegmentIndex == 0) {
            tipPercent = .18;
        }else if (self.tipSegment.selectedSegmentIndex == 1){
            tipPercent = .20;
        }else if (self.tipSegment.selectedSegmentIndex == 2){
            tipPercent = .22;
        }
        
        double yourPayment = [self.myInvoice amountDueForSplit];
        [self.myInvoice setGratuityForSplit:yourPayment withTipPercent:tipPercent];
        double totalPayment = yourPayment + [self.myInvoice gratuity];
        
        self.tipText.text = [NSString stringWithFormat:@"%.2f", [self.myInvoice gratuity]];
        self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", totalPayment];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.tipText resignFirstResponder];
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.segmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (IBAction)splitCheckAction:(id)sender {
    @try {
        
        [self performSegueWithIdentifier:@"goSplitCheck" sender:self];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.splitCheckAction" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == self.tipText) {
        
        if ([self.tipText.text length] >= 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return FALSE;
        }
        
    }
    
    return TRUE;
}


-(void)hideKeyboard{
    self.tipSegment.selectedSegmentIndex = -1;
    
    [self.tipText resignFirstResponder];
    
}

-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyboardY = 320;
        if (self.isIphone5) {
            keyboardY = 408;
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
            [self willAppearSetup];
            
            
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
        [rSkybox sendClientLog:@"InvoiceView.invoiceComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}

@end
