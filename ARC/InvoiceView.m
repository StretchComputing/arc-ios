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
#import "MFSideMenu.h"
#import "AddTipViewController.h"
#import "NumberLineButton.h"
#import "RightViewController.h"


@interface InvoiceView ()

@end

@implementation InvoiceView

-(void)viewWillDisappear:(BOOL)animated{
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

    
   
-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    
    @try {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceComplete:) name:@"invoiceNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
        
        // adjust if payments have already been made
        
        
        if (self.myInvoice.serviceCharge > 0.0) {
            
            double serviceChargePercent = self.myInvoice.serviceCharge/self.myInvoice.subtotal * 100;
            
            //self.gratNameLabel.text = [NSString stringWithFormat:@"Tip Included - %.0f%%", serviceChargePercent];
            
            self.gratNameLabel.text = [NSString stringWithFormat:@"%.0f%% Tip Included", serviceChargePercent];
            
            BOOL showAlert = YES;
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"showedGratuityAlert"] length] > 0) {
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"showedGratuityAlert"] isEqualToString:@"yes"]) {
                    showAlert = NO;
                }
            }
            if (showAlert) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added Service Charge" message:@"Please note that gratuity has already been added to your bill.  For this and all future purchases, you can see the added gratuity amount as 'Tip Included' on your receipt." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"showedGratuityAlert"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }
        
        if (self.shouldRun) {
            self.shouldRun = NO;
            [self willAppearSetup];

        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
   
  
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self becomeFirstResponder];
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
        
        self.shouldRun = YES;
        
        [self setUpScrollView];
        
        self.splitMyPaymentTextField.keyboardAppearance = UIKeyboardTypeDecimalPad;
        
        self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
        self.topLineView.layer.shadowRadius = 1;
        self.topLineView.layer.shadowOpacity = 0.5;
        
        self.splitTopLineView.layer.shadowOffset = CGSizeMake(0, 1);
        self.splitTopLineView.layer.shadowRadius = 1;
        self.splitTopLineView.layer.shadowOpacity = 0.5;
        
        self.backView.layer.cornerRadius = 7.0;
        
        self.splitCancelButton.text = @"Cancel";
        
        self.splitFullButton.textColor = [UIColor whiteColor];
        self.splitFullButton.text = @"Pay Full";
        self.splitFullButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
        
        self.splitSaveButton.textColor = [UIColor whiteColor];
        self.splitSaveButton.text = @"Save";
        self.splitSaveButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
    
        
        self.payBillButton.textColor = [UIColor whiteColor];
        self.payBillButton.text = @"Pay Bill!";
        self.payBillButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
        
        
        self.alreadyPaidButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.alreadyPaidButton setTitle:@"See Who Paid!" forState:UIControlStateNormal];
        [self.alreadyPaidButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
        [self.alreadyPaidButton setTitleColor:[UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0] forState:UIControlStateNormal];
       // [self.bottomHalfView addSubview:self.alreadyPaidButton];
        self.alreadyPaidButton.hidden = YES;
        [self.alreadyPaidButton addTarget:self action:@selector(showAlreadyPaid) forControlEvents:UIControlEventTouchUpInside];
        [self.alreadyPaidButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        
        self.overlayTextView.layer.masksToBounds = YES;
        self.overlayTextView.layer.cornerRadius = 10.0;
        self.overlayTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.overlayTextView.layer.borderWidth = 3.0;
        
        //self.overlayTextView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        CAGradientLayer *gradient1 = [CAGradientLayer layer];
        gradient1.frame = self.overlayTextView.bounds;
        self.overlayTextView.backgroundColor = [UIColor clearColor];
        double x = 1.4;
        UIColor *myColor1 = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
        gradient1.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor1 CGColor], nil];
        [self.overlayTextView.layer insertSublayer:gradient1 atIndex:0];
      
        
        
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
  
        //Deafult tip to 20%
        self.tipSegment.selectedSegmentIndex = 1;
        [self segmentSelect];
        
        
        for (int i = 0; i < [self.myInvoice.items count]; i++) {
            
            NSDictionary *itemDictionary = [self.myInvoice.items objectAtIndex:i];
            NSMutableDictionary *myDictionary = [NSMutableDictionary dictionaryWithDictionary:itemDictionary];
            
            [myDictionary setValue:@"no" forKey:@"IsPayingFor"];
            
            itemDictionary = [NSDictionary dictionaryWithDictionary:myDictionary];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.myTableView) {
        
        
        NSDictionary *dictionaryItem = [self.myInvoice.items objectAtIndex:indexPath.row];
        
        
        if ([[dictionaryItem valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
            [dictionaryItem setValue:@"no" forKey:@"IsPayingFor"];
            
            int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
            double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
            
            self.myItemizedTotal -= value;
            
        }else if ([[dictionaryItem valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
            
            
        }else{
            //Selecting it
            int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
            double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
            
            NSLog(@"Adding Value: %f", value);
            self.myItemizedTotal += value;

            [dictionaryItem setValue:@"yes" forKey:@"IsPayingFor"];

        }
    
        
        [self.myTableView reloadData];
    
        if (![self isAnyRowSelected]) {
            self.myItemizedTotal = 0.0;
          
            
            [self showFullTotal];
        }else{
            //some are still selected
            
            [self setItemizedTotalValue];
           
            
            
        }
        
    }
}

-(void)setItemizedTotalValue{
    
    double myPercent = self.myItemizedTotal/self.myInvoice.subtotal;
    

    
    double myTax = self.myInvoice.tax * myPercent;
    double myServiceCharge = self.myInvoice.serviceCharge * myPercent;
    double myDiscount = self.myInvoice.discount * myPercent;
    


    double myTotal = self.myItemizedTotal + myTax + myServiceCharge - myDiscount;

    
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", myTotal];
    self.totalLabel.text = [@"My Total:  " stringByAppendingString:self.totalLabel.text];
    
    
    
}

-(void)deselectAllItems{
    for (int i = 0; i < [self.myInvoice.items count]; i++) {
        
        NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
        
        [item setValue:@"no" forKey:@"IsPayingFor"];
    }
    
    [self.myTableView reloadData];
}

-(void)showFullTotal{
    double amountPaid = [self.myInvoice calculateAmountPaid];
    if (amountPaid > 0.0) {
        self.isPartialPayment = YES;
    }
    double amountDue = self.myInvoice.amountDue;
    
    double newDue = amountDue - amountPaid;
    if (newDue < 0.0001) {
        newDue = 0;
    }
    
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", newDue];
    self.totalLabel.text = [@"My Total:  " stringByAppendingString:self.totalLabel.text];
}
-(BOOL)isAnyRowSelected{
    
    for (int i = 0; i < [self.myInvoice.items count]; i++) {
        
        NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
        
        if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
            return YES;
        }
    }
    
    return NO;
    
}

-(void)setUpScrollView{
    
    
    @try {
        for (int i = 0; i < 24; i++) {
            
            BOOL addButton = NO;
            NSString *numberText;
            if ((i < 4) || (i > 21)) {
                if (i == 3) {
                    numberText = @"-";
                }else{
                    numberText = @"";
                }
            }else{
                addButton = YES;
                numberText = [NSString stringWithFormat:@"%d", i-1];
            }
            
            int size;
            if (i == 3) {
                size = 35;
            }else{
                size = 16;
            }
            
            LucidaBoldLabel *numberLabel = [[LucidaBoldLabel alloc] initWithFrame:CGRectMake(i * 45, 5, 45, 45) andSize:size];
            numberLabel.textAlignment = UITextAlignmentCenter;
            numberLabel.text = numberText;
            numberLabel.clipsToBounds = YES;
            numberLabel.userInteractionEnabled = YES;
            
            if (addButton) {
                NumberLineButton *numberButton = [NumberLineButton buttonWithType:UIButtonTypeCustom];
                numberButton.frame = CGRectMake(0, 0, 45, 45);
                numberButton.offset = i * 45;
                [numberButton addTarget:self action:@selector(scrollToNumber:) forControlEvents:UIControlEventTouchUpInside];
                [numberLabel addSubview:numberButton];
                
                UIView *rightCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 18, 5, 3)];
                rightCircle.backgroundColor = [UIColor blackColor];
                rightCircle.layer.cornerRadius = 6.0;
                [numberLabel addSubview:rightCircle];
                
            }
            
            [self.numberSliderScrollView addSubview:numberLabel];
            
            
            
            
            
            
            
        }
        
        self.numberSliderScrollView.contentSize = CGSizeMake(1115, 45);
        self.numberSliderScrollView.backgroundColor = [UIColor clearColor];
        self.numberSliderScrollView.delegate = self;
        self.numberSliderScrollView.showsHorizontalScrollIndicator = NO;
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.setUpScrollView" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}


-(void)setValueForOffset:(int)offset{
    
    @try {
        int xValue = offset + 135;
        
        LucidaBoldLabel *myLabel = (LucidaBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:xValue/45];
        
        double yourPercent;
        
        if ([myLabel.text isEqualToString:@"-"]) {
            self.numberOfPeopleSelected = 0;
            yourPercent = 0;
            
        }else{
            self.numberOfPeopleSelected = [myLabel.text intValue];
            yourPercent = 1.0/self.numberOfPeopleSelected * 100;
            
        }
        

        
        
        double myDue = self.myInvoice.amountDue * yourPercent / 100.0;

        self.splitMyPaymentTextField.text = [NSString stringWithFormat:@"%.2f", myDue];
        
        
                
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.setValueForOffset" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}

-(void)scrollToNumber:(id)sender{
    
    @try {
        NumberLineButton *myButton = (NumberLineButton *)sender;
        
        int newOffset = myButton.offset - 135;
        [self.numberSliderScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
        [self setValueForOffset:newOffset];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollToNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    
    @try {
        NSLog(@"Velocitiy: %f", velocity.x);
        
        CGFloat xOffset = targetContentOffset->x;
        int intOffset = round(xOffset);
        
        int whole = floor(intOffset/45.0);
        
        int remainder = intOffset % 45;
        
        if (remainder >= 22) {
            whole++;
        }
        
        int newOffset = 45 * whole;
        
        if (velocity.x == 0) {
            [self.numberSliderScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
            [self setValueForOffset:newOffset];
        }
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollViewWillEndDragging" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    @try {
        CGFloat xOffset = scrollView.contentOffset.x;
        int intOffset = round(xOffset);
        
        int whole = floor(intOffset/45.0);
        
        int remainder = intOffset % 45;
        
        if (remainder >= 22) {
            whole++;
        }
        
        int newOffset = 45 * whole;
        
        [self.numberSliderScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
        [self setValueForOffset:newOffset];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollViewDidEndDecelerating" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    @try {
        CGFloat xOffset = scrollView.contentOffset.x;
        xOffset +=23;
        
        int index = floor(xOffset/45.0);
        index = index + 3;
        
        for (int i = 0; i < [[self.numberSliderScrollView subviews] count]; i++) {
            
            if (i != index) {
                if ([LucidaBoldLabel class] == [[[self.numberSliderScrollView subviews] objectAtIndex:i] class]) {
                    LucidaBoldLabel *otherLabel = (LucidaBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:i];
                    [otherLabel setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:16]];
                    
                }
            }
        }
        
        LucidaBoldLabel *myLabel = (LucidaBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:index];
        [myLabel setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:35]];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollViewDidScroll" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)setUpView{
    
    
    self.bottomHalfView.backgroundColor = [UIColor clearColor];

    
    self.subLabel.text = [NSString stringWithFormat:@"$%.2f", [self.myInvoice subtotal]];
    self.taxLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.tax];
    self.gratLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.serviceCharge];
    self.discLabel.text = [NSString stringWithFormat:@"- $%.2f", self.myInvoice.discount];
    
    
    //**Set up balance screen
    RightViewController *right = [self.navigationController.sideMenu getRightSideMenu];
   
    right.invoiceController = self;
    right.myInvoice = self.myInvoice;
    double amountPaid = [self.myInvoice calculateAmountPaid];

    double amountDue = self.myInvoice.amountDue;
    
    double newDue = amountDue - amountPaid;
    if (newDue < 0.0001) {
        newDue = 0;
    }
    
    if (amountPaid > 0.0) {
        right.noPaymentsLabel.hidden = YES;
        right.alreadyPaidTable.hidden = NO;
        right.paymentsArray = self.myInvoice.payments;
        [right.alreadyPaidTable reloadData];
        right.seeWhoPaidLabel.hidden = NO;
    }else{
        right.alreadyPaidTable.hidden = YES;
        right.noPaymentsLabel.hidden = NO;
        right.seeWhoPaidLabel.hidden = YES;
    }
    
    right.totalDueLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.amountDue];
    right.totalRemainingLabel.text = [NSString stringWithFormat:@"$%.2f", newDue];
    right.alreadyPaidLabel.text = [NSString stringWithFormat:@"$%.2f", amountPaid];
    
    
    
    
 
    
    //New Code
    
  
    int moveY = 0;
    
    double alreadyPaid = [self.myInvoice calculateAmountPaid];
    if (alreadyPaid == 0.0){
        self.alreadyPaid.hidden = YES;
        self.alreadyPaidNameLabel.hidden = YES;
        moveY +=20;
    }else{
        self.alreadyPaidLabel.text = [NSString stringWithFormat:@"- $%.2f", alreadyPaid];
    }
    
    
    if (self.myInvoice.discount == 0.0) {
        self.discLabel.hidden = YES;
        self.discNameLabel.hidden = YES;
        moveY +=20;
    }else{
        
        CGRect myframe2 = self.discLabel.frame;
        myframe2.origin.y += moveY;
        self.discLabel.frame = myframe2;
        
        CGRect myframe3 = self.discNameLabel.frame;
        myframe3.origin.y += moveY;
        self.discNameLabel.frame = myframe3;
        
    }
    
    if (self.myInvoice.serviceCharge == 0.0) {
        self.gratLabel.hidden = YES;
        self.gratNameLabel.hidden = YES;
        moveY +=20;
    }else{
        
        CGRect myframe2 = self.gratLabel.frame;
        myframe2.origin.y += moveY;
        self.gratLabel.frame = myframe2;
        
        CGRect myframe3 = self.gratNameLabel.frame;
        myframe3.origin.y += moveY;
        self.gratNameLabel.frame = myframe3;
    }
    
    CGRect myframe = self.subtotalBackView.frame;
    myframe.origin.y += moveY;
    self.subtotalBackView.frame = myframe;
    
    NSLog(@"MoveY: %d", moveY);
    NSLog(@"Height: %f", self.myTableView.frame.size.height);
    
    CGRect myframe1 = self.myTableView.frame;
    myframe1.size.height += moveY;
    self.myTableView.frame = myframe1;
    
    
    NSLog(@"Height: %f", self.myTableView.frame.size.height);

    
    
    
    
    //
    
    int tableCount = [self.myInvoice.items count];
    
   // double amountPaid = [self.myInvoice calculateAmountPaid];
    if(amountPaid > 0.0) {
        tableCount++;
    }
    
    int tableHeight = tableCount * 24 + tableCount + 10;
    
    //self.myTableView.frame = CGRectMake(0, 20, 300, tableHeight);
    
    //self.dividerLabel.frame = CGRectMake(0, tableHeight + 10, 300, 21);
    int bottomViewY = tableHeight + 20;
    
    if (bottomViewY < 120) {
        bottomViewY = 120;
        int height = (120 - tableHeight)/2 + tableHeight;
        //self.dividerLabel.frame = CGRectMake(0, height, 300, 21);
    }
    
    //self.bottomHalfView.frame = CGRectMake(0, bottomViewY, 300, 134);
    
    double myDue = self.myInvoice.amountDue - amountPaid;
    self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", myDue];

    //bottom view
    /*
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
        frameName.origin.y = yValue + 2;
        self.gratNameLabel.frame = frameName;
        *
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
        frameName.origin.y = yValue + 2;
        self.discNameLabel.frame = frameName;
        
        
        
    }
  
    
    if(amountPaid > 0.0) {
        
       // self.payBillButton.title = @"Pay Remaining";
        self.isPartialPayment = YES;
        self.alreadyPaidLabel.hidden = NO;
        self.alreadyPaidNameLabel.hidden = NO;
        self.alreadyPaidLabel.text = [NSString stringWithFormat:@"-$%.2f", amountPaid];
        
        yValue += 20;
        
        CGRect frame = self.alreadyPaidLabel.frame;
        frame.origin.y = yValue;
        self.alreadyPaidLabel.frame = frame;
        
        CGRect frameName = self.alreadyPaidNameLabel.frame;
        frameName.origin.y = yValue+2;
        self.alreadyPaidNameLabel.frame = frameName;
        
        
        self.alreadyPaidButton.frame = CGRectMake(110, yValue - 4, 110 - 4, self.alreadyPaidNameLabel.frame.size.height + 9 - 4);
        self.alreadyPaidButton.hidden = NO;
     


    }else{
        
        self.alreadyPaidButton.hidden = YES;
        self.alreadyPaidLabel.hidden = YES;
        self.alreadyPaidNameLabel.hidden = YES;
    }
    
    
    CGRect frame = self.bottomHalfView.frame;
    frame.size.height = yValue + 45;
   // self.bottomHalfView.frame = frame;
    
    
    CGRect frameAmountName = self.amountNameLabel.frame;
    frameAmountName.origin.y = yValue + 27;
    //self.amountNameLabel.frame = frameAmountName;
    
    CGRect frameAmount = self.amountLabel.frame;
    frameAmount.origin.y = yValue + 23;
    //self.amountLabel.frame = frameAmount;
    
    CGRect frameLine = self.dividerView.frame;
    frameLine.origin.y = yValue + 18;
   // self.dividerView.frame = frameLine;
    
    
    [self.scrollView setContentSize:CGSizeMake(300, bottomViewY + yValue + 50)];
    
    */
    // this method is called after refresh too, so tip may need to be recalculated
    [self segmentSelect];
    
}

-(void)willAppearSetup{
    [self showFullTotal];
    
    [self.myTableView reloadData];
    [self.alreadyPaidTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        if (tableView == self.alreadyPaidTableView) {
            return [self.myInvoice.payments count];
        }
        return [self.myInvoice.items count];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        if (tableView == self.alreadyPaidTableView) {
            
            static NSString *alreadyPaidCell=@"alreadyPaidCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alreadyPaidCell];
    
            
            LucidaBoldLabel *nameLabel = (LucidaBoldLabel *)[cell.contentView viewWithTag:1];
            LucidaBoldLabel *amountLabel = (LucidaBoldLabel *)[cell.contentView viewWithTag:2];
            CorbelTextView *notesText = (CorbelTextView *)[cell.contentView viewWithTag:3];
            
            NSUInteger row = [indexPath row];
            
            NSDictionary *payment = [self.myInvoice.payments objectAtIndex:row];
            
            nameLabel.text = [payment valueForKey:@"Name"];
        
            double amountDouble = [[payment valueForKey:@"Amount"] doubleValue];
            
            amountLabel.text = [NSString stringWithFormat:@"$%.2f", amountDouble];
            
            if ([payment valueForKey:@"Notes"] && [[payment valueForKey:@"Notes"] length] > 0) {
                notesText.hidden = NO;
                notesText.text = [payment valueForKey:@"Notes"];
                
                CGSize constraints = CGSizeMake(200, 900);
                CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:@"LucidaGrande" size:14] constrainedToSize:constraints];
                
                CGRect frame = notesText.frame;
                frame.size.height = totalSize.height + 15;
                notesText.frame = frame;
                
                
            }else{
                notesText.hidden = YES;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;

            
        }else{
            static NSString *FirstLevelCell=@"FirstLevelCell";
            
            static NSInteger itemTag = 1;
            static NSInteger numberTag = 2;
            static NSInteger priceTag = 3;
            static NSInteger highLightTag = 4;

            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier: FirstLevelCell];
                
                
                
                UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 8, 188, 20)];
                itemLabel.tag = itemTag;
                [cell.contentView addSubview:itemLabel];
                
                UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(223, 7, 75, 20)];
                priceLabel.tag = priceTag;
                [cell.contentView addSubview:priceLabel];
                
                UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 7, 32, 20)];
                numberLabel.tag = numberTag;
                [cell.contentView addSubview:numberLabel];
                
                UIView *highLightView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 300, 27)];
                highLightView.tag = highLightTag;
                [cell.contentView addSubview:highLightView];
                
                
            }
            
            UILabel *itemLabel = (UILabel *)[cell.contentView viewWithTag:itemTag];
            UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
            UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:priceTag];
            UIView *highLightView = (UIView *)[cell.contentView viewWithTag:highLightTag];

            [cell.contentView sendSubviewToBack:highLightView];
            
            highLightView.layer.borderColor = [[UIColor blackColor] CGColor];
            highLightView.layer.borderWidth = 1.0;
            highLightView.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];//[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
            
            NSUInteger row = [indexPath row];
            
            
            
            
            itemLabel.backgroundColor = [UIColor clearColor];
            numberLabel.backgroundColor = [UIColor clearColor];
            priceLabel.backgroundColor = [UIColor clearColor];
            

            
            priceLabel.textAlignment = UITextAlignmentRight;
            numberLabel.textAlignment = UITextAlignmentLeft;
            
            
            NSDictionary *itemDictionary = [self.myInvoice.items objectAtIndex:row];
            
            itemLabel.text = [itemDictionary valueForKey:@"Description"];
            
            int num = [[itemDictionary valueForKey:@"Amount"] intValue];
            double value = [[itemDictionary valueForKey:@"Value"] doubleValue] * num;
            
            
            priceLabel.text = [NSString stringWithFormat:@"$%.2f", value];
            
            numberLabel.text = [NSString stringWithFormat:@"%d", [[itemDictionary valueForKey:@"Amount"] intValue]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([[itemDictionary valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
                highLightView.hidden = NO;
                itemLabel.textColor = [UIColor whiteColor];
                numberLabel.textColor = [UIColor whiteColor];
                priceLabel.textColor = [UIColor whiteColor];
                
                itemLabel.font = [UIFont fontWithName:@"Corbel-Bold" size:14];
                numberLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:14];
                priceLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:14];

            }else{
                highLightView.hidden = YES;
                
                itemLabel.textColor = [UIColor blackColor];
                numberLabel.textColor = [UIColor blackColor];
                priceLabel.textColor = [UIColor blackColor];
                
                itemLabel.font = [UIFont fontWithName:@"Corbel" size:14];
                numberLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
                priceLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
            }
            return cell;

        }
       
    
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (tableView == self.alreadyPaidTableView) {
            
            NSDictionary *payment = [self.myInvoice.payments objectAtIndex:indexPath.row];
            
            if ([payment valueForKey:@"Notes"]) {
                if ([[payment valueForKey:@"Notes"] length] > 0) {
                    
                    CGSize constraints = CGSizeMake(200, 900);
                    CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:@"LucidaGrande" size:14] constrainedToSize:constraints];
                    
                    return 25 + totalSize.height + 15;
                    
                }
            }
            return 33;
        }
        return 30;
    }
    @catch (NSException *exception) {
        
    }
   
}


- (IBAction)payNow:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"clickedPayButton"];
        
        BOOL haveCards;
        BOOL haveDwolla;
        BOOL showSheet = YES;
        
        if([self.myInvoice calculateAmountPaid] > 0) {
            //[ArcClient trackEvent:@"PAY_REMAINING"];
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
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not All Cards Accepted" message:@"One or more of your saved credit cards are not accepted by this merchant.  You will not see these cards in the list of payment choices" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                //[alert show];
                
                [self showTextOverlay];
                [self.actionSheet showInView:self.view];
                
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
    
    if (alertView == self.overpayAlert) {
        
        if (buttonIndex == 1) {
            //HERE
            
            [self showFullTotal];
            
            
         
            [self deselectAllItems];
            
        }
    }else{
        [self.actionSheet showInView:self.view];

    }

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self hideTextOverlay];
    
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
        self.totalLabel.text = [@"My Total:  " stringByAppendingString:self.totalLabel.text];

        
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
            
            double percentPaid = 0.0;
            if ([self.myInvoice calculateAmountPaid] == 0.0) {
                percentPaid = 100.0;
            }else{
                
                percentPaid = basePayment/[self.myInvoice amountDue] * 100.0;
            }
            
            DwollaPayment *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            controller.mySplitPercent = percentPaid;
            
        }else if ([[segue identifier] isEqualToString:@"goPayCreditCard"]) {
            
            // on this screen, can only pay the full remaining amount due
            double basePayment = [self.myInvoice amountDue] - [self.myInvoice calculateAmountPaid];
            //[self.myInvoice setBasePaymentAmount:basePayment];
                        
            double myTotal = [[self.totalLabel.text substringFromIndex:12] doubleValue];
            [self.myInvoice setBasePaymentAmount:myTotal];
            AddTipViewController *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;

            double percentPaid = 0.0;
            if ([self.myInvoice calculateAmountPaid] == 0.0) {
                percentPaid = 100.0;
            }else{
                
                percentPaid = basePayment/[self.myInvoice amountDue] * 100.0;
            }
            
            controller.mySplitPercent = percentPaid;
            
           
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
        
        int keyboardY = 200;
        if (self.view.frame.size.height > 500) {
            keyboardY = 288;
        }
        
        keyboardY = self.view.frame.size.height - 45;
        
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
        [tmpButton addTarget:self action:@selector(doneSplitMyPayment) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    self.refreshButton.enabled = NO;

    ArcClient *client = [[ArcClient alloc] init];
    [client getInvoice:loginDict];
}


-(void)invoiceComplete:(NSNotification *)notification{
    @try {
        
        [self.activity stopAnimating];
        self.refreshButton.enabled = YES;

        
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            NSDictionary *theInvoice = [[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"];
            
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

-(void)showTextOverlay{
  
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.overlayTextView.frame;
        frame.origin.y = 10;
        self.overlayTextView.frame = frame;
    }];
    
}

-(void)hideTextOverlay{
    
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.overlayTextView.frame;
        frame.origin.y = -124;
        self.overlayTextView.frame = frame;
    }];
}


-(void)showAlreadyPaid{
    
    @try {
        
        [ArcClient trackEvent:@"SEE_WHO_PAID"];

        
        self.alreadyPaid.hidden = NO;
        self.alreadyPaid.layer.cornerRadius = 2.0;
        self.alreadyPaid.layer.borderWidth = 2.0;
        self.alreadyPaid.layer.borderColor = [[UIColor blackColor] CGColor];
        
        self.alreadyPaidViewLabel.text = [NSString stringWithFormat:@"Already Paid: %@", [self.alreadyPaidLabel.text substringFromIndex:1]];
        self.alreadyPaidViewLabel.textColor = [UIColor redColor];
    }
    @catch (NSException *exception) {
        
    }
  
    
}

-(void)cancelAlreadyPaid{
    self.alreadyPaid.hidden = YES;
}



- (IBAction)showBalanceAction {
    
    [self.navigationController.sideMenu toggleRightSideMenu];
}

- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)payBillAction {
    
    double amountPaid = [self.myInvoice calculateAmountPaid];
    double amountDue = self.myInvoice.amountDue;
    
    double newDue = amountDue - amountPaid;
    if (newDue < 0.0001) {
        newDue = 0;
    }
    
    double myTotal = [[self.totalLabel.text substringFromIndex:12] doubleValue];

    if (myTotal > newDue) {
        self.overpayAlert = [[UIAlertView alloc] initWithTitle:@"Over Payment" message:@"You cannot pay more than is due on this bill." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Pay Remaining", nil];
        [self.overpayAlert show];
    }else{
        [self payNow:nil];

    }
    
    
}


- (IBAction)showSplitView {
    
    [self deselectAllItems];
    [self showFullTotal];
    
    [UIView animateWithDuration:0.6 animations:^{
       
        CGRect frame = self.splitView.frame;
        frame.origin.x = 0;
        self.splitView.frame = frame;
    }];
}


- (IBAction)cancelSplitAction {
    
    
    [UIView animateWithDuration:0.6 animations:^{
        
        CGRect frame = self.splitView.frame;
        frame.origin.x = -320;
        self.splitView.frame = frame;
    }];
    
    
    if ([self.splitMyPaymentTextField isFirstResponder]) {
        [self doneSplitMyPayment];
    }

   
    
}

- (IBAction)payFullSplitAction {
   
}
- (IBAction)splitMyPaymentDidBegin:(id)sender {
    [self showDoneButton];
    self.isEditingMyPayment = YES;
    [UIView animateWithDuration:0.6 animations:^{
        
        CGRect frame = self.view.frame;
        frame.origin.y = -216;
        self.view.frame = frame;
        
        
        CGRect frame1 = self.splitView.frame;
        frame1.origin.y  -= 50;
        self.splitView.frame = frame1;
        
    }];
    
    
}


-(void)doneSplitMyPayment{
    
    self.isEditingMyPayment = NO;
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
    
    [self.splitMyPaymentTextField resignFirstResponder];
    [UIView animateWithDuration:0.6 animations:^{
        
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
        
        CGRect frame1 = self.splitView.frame;
        frame1.origin.y  += 50;
        self.splitView.frame = frame1;
    }];
    
    double myDouble = [self.splitMyPaymentTextField.text doubleValue];
    self.splitMyPaymentTextField.text = [NSString stringWithFormat:@"%.2f", myDouble];
    
    [self becomeFirstResponder];
}


- (IBAction)splitSaveAction {
    
    double myDouble = [self.splitMyPaymentTextField.text doubleValue];
    
    if (myDouble > 0) {
        self.totalLabel.text = [NSString stringWithFormat:@"My Total:  $%@", self.splitMyPaymentTextField.text];
        [self showSplitButtons];

    }
    
 
    [self cancelSplitAction];
}


-(void)showSplitButtons{
    
}

-(void)hideSplitButtons{
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self willAppearSetup];
    }
}

@end
