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

@interface InvoiceView ()

@end

@implementation InvoiceView


-(void)viewWillAppear:(BOOL)animated{

    
    // adjust if payments have already been made
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
        
        self.subLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice baseAmount]];
        self.taxLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.tax];
        self.gratLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.serviceCharge];
        self.discLabel.text = [NSString stringWithFormat:@"- $%.2f", self.myInvoice.discount];
        
        
        [super viewDidLoad];
        
        // Do any additional setup after loading the view.
        
        //Set up scroll view sizes
        
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
        
        if([self.myInvoice calculateAmountPaid] > 0) {
            [ArcClient trackEvent:@"PAY_REMAINING"];
        }

        
        [self.tipText resignFirstResponder];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not All Cards Accepted" message:@"One or more of your saved credit cards are not accepted by this merchant.  You will not see these cards in the list of payment choices" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }else{

        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.payNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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

                [self performSegueWithIdentifier:@"goPayDwolla" sender:self];

            }
        }else {
            [rSkybox addEventToSession:@"selectedCreditCardForPayment"];
            
            if ([self.creditCards count] > 0) {
                if (buttonIndex == [self.creditCards count] + 1) {
                    //Cancel
                }else{
                    //1 is paypal, 2 is first credit card
                    CreditCard *selectedCard = [self.creditCards objectAtIndex:buttonIndex - 1];
                    
                    self.creditCardNumber = selectedCard.number;
                    self.creditCardSecurityCode = selectedCard.securityCode;
                    self.creditCardExpiration = selectedCard.expiration;
                    self.creditCardSample = selectedCard.sample;
                    
                    [self performSegueWithIdentifier:@"goPayCreditCard" sender:self];
                    
                }
            }else{
                
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
            self.myInvoice.tipEntry = @"SHORTCUT10";

        }else if (self.tipSegment.selectedSegmentIndex == 1){
            self.myInvoice.tipEntry = @"SHORTCUT15";

        }else if (self.tipSegment.selectedSegmentIndex == 2){
            self.myInvoice.tipEntry = @"SHORTCUT20";

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
        }else{
            tipPercent = .22;
        }
        
        [self.myInvoice setGratuityByPercentage:tipPercent];
        self.tipText.text = [NSString stringWithFormat:@"%.2f", [self.myInvoice gratuity]];
        
        double totalPayment = [self.myInvoice amountDue] - [self.myInvoice calculateAmountPaid] + [self.myInvoice gratuity];
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


- (void)viewDidUnload {
    [self setSplitCheckButton:nil];
    [self setPayBillButton:nil];
    [self setAlreadyPaidNameLabel:nil];
    [self setAlreadyPaidLabel:nil];
    [super viewDidUnload];
}
@end
