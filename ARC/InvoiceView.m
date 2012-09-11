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
#import "SplitCheckViewController.h":

@interface InvoiceView ()

@end

@implementation InvoiceView



- (void)viewDidLoad
{
    @try {
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        double serviceCharge = (self.myInvoice.baseAmount * self.myInvoice.serviceCharge);
        double tax = (self.myInvoice.baseAmount * self.myInvoice.tax);
        double discount = (self.myInvoice.baseAmount * self.myInvoice.discount);
        
        
        self.subLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.baseAmount];
        self.taxLabel.text = [NSString stringWithFormat:@"$%.2f", tax];
        self.gratLabel.text = [NSString stringWithFormat:@"$%.2f", serviceCharge];
        self.discLabel.text = [NSString stringWithFormat:@"- $%.2f", discount];
        
        self.amountDue = self.myInvoice.baseAmount + serviceCharge + tax - discount;
        
        self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue];
        
        self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue];
        
        [super viewDidLoad];
        
        [self.myTableView reloadData];
        // Do any additional setup after loading the view.
        
        //Set up scroll view sizes
        
        int tableCount = [self.myInvoice.items count];
        
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
        
        [self.scrollView setContentSize:CGSizeMake(300, bottomViewY + 140)];
        
        
        //bottom view
        int movedown = 0;
        if (self.myInvoice.serviceCharge == 0.0) {
            self.gratLabel.hidden = YES;
            self.gratNameLabel.hidden = YES;
            movedown += 15;
        }
        
        if (self.myInvoice.discount == 0.0) {
            self.discLabel.hidden = YES;
            self.discNameLabel.hidden = YES;
            movedown +=15;
        }else{
            
            if (self.myInvoice.serviceCharge == 0.0) {
                self.discNameLabel.frame = CGRectMake(10, 52, 95, 21);
                self.discLabel.frame = CGRectMake(219, 52, 71, 21);
            }
        }
        
        CGRect frame = self.bottomHalfView.frame;
        frame.origin.y += movedown;
        frame.size.height -= movedown;
        self.bottomHalfView.frame = frame;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
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
            
            
            
            UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 2, 207, 20)];
            itemLabel.tag = itemTag;
            [cell.contentView addSubview:itemLabel];
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(234, 2, 60, 20)];
            priceLabel.tag = priceTag;
            [cell.contentView addSubview:priceLabel];
            
            UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 2, 20, 20)];
            numberLabel.tag = numberTag;
            [cell.contentView addSubview:numberLabel];
            
            
            
            
        }
        
        UILabel *itemLabel = (UILabel *)[cell.contentView viewWithTag:itemTag];
        UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
        UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:priceTag];
        
        
        itemLabel.backgroundColor = [UIColor clearColor];
        numberLabel.backgroundColor = [UIColor clearColor];
        priceLabel.backgroundColor = [UIColor clearColor];
        
        itemLabel.font = [UIFont fontWithName:@"Corbel" size:14];
        numberLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
        priceLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
        
        priceLabel.textAlignment = UITextAlignmentRight;
        numberLabel.textAlignment = UITextAlignmentLeft;
        
        NSUInteger row = [indexPath row];
        
        NSDictionary *itemDictionary = [self.myInvoice.items objectAtIndex:row];
        
        itemLabel.text = [itemDictionary valueForKey:@"Description"];
        
        double value = [[itemDictionary valueForKey:@"Value"] doubleValue];
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
        
        [self.tipText resignFirstResponder];
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
        [rSkybox sendClientLog:@"InvoiceView.payNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        
        if (buttonIndex == 0) {
            //Dwolla
            [rSkybox addEventToSession:@"selectedDwollaForPayment"];
            
            [self performSegueWithIdentifier:@"goPayDwolla" sender:self];
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
        
        self.view.frame = CGRectMake(0, -165, 320, 416);
        
        
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
        
        self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue + tip];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        self.view.frame = CGRectMake(0, 0, 320, 416);
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.editEnd" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"goPayDwolla"]) {
            
            DwollaPayment *controller = [segue destinationViewController];
            controller.totalAmount = [[NSString stringWithFormat:@"%f", self.amountDue] doubleValue];
            controller.gratuity = [self.tipText.text doubleValue];
            controller.invoiceId = self.myInvoice.invoiceId;
            
            
        }else if ([[segue identifier] isEqualToString:@"goPayCreditCard"]) {
            
            CreditCardPayment *controller = [segue destinationViewController];
            controller.totalAmount = [[NSString stringWithFormat:@"%f", self.amountDue] doubleValue];
            controller.gratuity = [self.tipText.text doubleValue];
            controller.invoiceId = self.myInvoice.invoiceId;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;
            
        }else if ([[segue identifier] isEqualToString:@"goSplitCheck"]) {
            SplitCheckViewController *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
        }
            
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)segmentSelect {
    @try {
        
        [self performSelector:@selector(resetSegment) withObject:nil afterDelay:0.2];
        
        double tipPercent = 0.0;
        if (self.tipSegment.selectedSegmentIndex == 0) {
            tipPercent = .10;
        }else if (self.tipSegment.selectedSegmentIndex == 1){
            tipPercent = .15;
        }else{
            tipPercent = .20;
        }
        
        double tipAmount = tipPercent * self.amountDue;
        
        self.tipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];
        
        self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue + tipAmount];
        
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        self.view.frame = CGRectMake(0, 0, 320, 416);
        [self.tipText resignFirstResponder];
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.segmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)resetSegment{
    self.tipSegment.selectedSegmentIndex = -1;
}

- (IBAction)splitCheckAction:(id)sender {
    @try {
        
        [self performSegueWithIdentifier:@"goSplitCheck" sender:self];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.splitCheckAction" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
@end
