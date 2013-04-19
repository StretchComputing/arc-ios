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
#import "AdditionalTipViewController.h"
#import "NumberLineButton.h"
#import "RightViewController.h"
#import "MyGestureRecognizer.h"

#define REFRESH_HEADER_HEIGHT 52.0f

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
        
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
        
        if (self.isIos6) {
            self.refreshControl = [[UIRefreshControl alloc] init];
            [self.refreshControl addTarget:self action:@selector(refreshInvoice) forControlEvents:UIControlEventValueChanged];
            [self.myTableView addSubview:self.refreshControl];
        }else{
            [self setupStrings];
            [self addPullToRefreshHeader];
        }
        
        
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
    
        
        self.itemSplitSaveButton.textColor = [UIColor whiteColor];
        self.itemSplitSaveButton.text = @"Save";
        self.itemSplitSaveButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
        
        
        
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
        
        if ([dictionaryItem valueForKey:@"IsTopLevel"] && [[dictionaryItem valueForKey:@"IsTopLevel"] isEqualToString:@"yes"]) {
            
            [dictionaryItem setValue:@"no" forKey:@"IsTopLevel"];
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.myInvoice.items];
            
            for (int i = indexPath.row; i < [self.myInvoice.items count]; i++) {
                
                NSDictionary *newItem = [newArray objectAtIndex:i];
                
                if ([[newItem valueForKey:@"Description"] isEqualToString:[dictionaryItem valueForKey:@"Description"]] && [[newItem valueForKey:@"IsSubLevel"] isEqualToString:@"yes"]) {
                    
                    
                    if ([[newItem valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
                        
                        int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
                        double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
                        
                        self.myItemizedTotal -= value;
                        
                    }else if ([[dictionaryItem valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
                        
                        
                        double amountPayingFor = [[dictionaryItem valueForKey:@"AmountPayingFor"] doubleValue];
                        self.myItemizedTotal -= amountPayingFor;
                        
                    }
                    
                    [newArray removeObjectAtIndex:i];

                    i--;
                    
            
                }
                
                
                self.myInvoice.items = [NSArray arrayWithArray:newArray];
                [self.myTableView reloadData];
                
                if (![self isAnyRowSelected]) {
                    self.myItemizedTotal = 0.0;
                    [self showFullTotal];
                }else{
                    //some are still selected
                    [self setItemizedTotalValue];                    
                }
            }
        }else{
            
            
            if ([[dictionaryItem valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
                [dictionaryItem setValue:@"no" forKey:@"IsPayingFor"];
                
                int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
                double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
                
                self.myItemizedTotal -= value;
                
            }else if ([[dictionaryItem valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
                
                [dictionaryItem setValue:@"no" forKey:@"IsPayingFor"];

                double amountPayingFor = [[dictionaryItem valueForKey:@"AmountPayingFor"] doubleValue];
                self.myItemizedTotal -= amountPayingFor;
                
                
            }else{
                //Selecting it
                int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
                
                if (num < 1) {
                    self.payAllSelectedIndex = indexPath.row;
                    NSString *title = [NSString stringWithFormat:@"%d %@", num, [dictionaryItem valueForKey:@"Description"]];
                    self.payAllAlert = [[UIAlertView alloc] initWithTitle:title message:@"Pay for all?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [self.payAllAlert show];
                }else{
                    
                    int num = [[dictionaryItem valueForKey:@"Amount"] intValue];

                    double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
                    
                    self.myItemizedTotal += value;
                    
                    [dictionaryItem setValue:@"yes" forKey:@"IsPayingFor"];
                    
                }
                
                
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
}


/*
 int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
 
 double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
 
 self.myItemizedTotal += value;
 
 [dictionaryItem setValue:@"yes" forKey:@"IsPayingFor"];
 
 */
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
        
        if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"yes"] || [[item valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]) {
            return YES;
        }
    }
    
    return NO;
    
}

-(void)setUpScrollView{
    
    
    @try {
        for (int i = 0; i < 25; i++) {
            
            BOOL addButton = NO;
            NSString *numberText;
            if ((i < 4) || (i > 22)) {
                if (i == 3) {
                    numberText = @"-";
                }else{
                    numberText = @"";
                }
            }else{
                addButton = YES;
                numberText = [NSString stringWithFormat:@"%d", i-2];
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
        
        
        for (int i = 0; i < 25; i++) {
            
            BOOL addButton = NO;
            NSString *numberText;
            if ((i < 4) || (i > 22)) {
                if (i == 3) {
                    numberText = @"-";
                }else{
                    numberText = @"";
                }
            }else{
                addButton = YES;
                numberText = [NSString stringWithFormat:@"%d", i-2];
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
                [numberButton addTarget:self action:@selector(scrollToNumberSplit:) forControlEvents:UIControlEventTouchUpInside];
                [numberLabel addSubview:numberButton];
                
                UIView *rightCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 18, 5, 3)];
                rightCircle.backgroundColor = [UIColor blackColor];
                rightCircle.layer.cornerRadius = 6.0;
                [numberLabel addSubview:rightCircle];
                
            }
            
            [self.itemSplitScrollView addSubview:numberLabel];
            
            
            
            
            
            
            
        }
        
        
        
        
        self.numberSliderScrollView.contentSize = CGSizeMake(1160, 45);
        self.numberSliderScrollView.backgroundColor = [UIColor clearColor];
        self.numberSliderScrollView.delegate = self;
        self.numberSliderScrollView.showsHorizontalScrollIndicator = NO;
        
        self.itemSplitScrollView.contentSize = CGSizeMake(1160, 45);
        self.itemSplitScrollView.backgroundColor = [UIColor clearColor];
        self.itemSplitScrollView.delegate = self;
        self.itemSplitScrollView.showsHorizontalScrollIndicator = NO;
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.setUpScrollView" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}


-(void)setValueForOffset:(int)offset :(UIScrollView *)scrollView{
    
    @try {
        
        if (scrollView == self.numberSliderScrollView) {
            
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
            
        }else{
            int xValue = offset + 135;
            
            LucidaBoldLabel *myLabel = (LucidaBoldLabel *)[[self.itemSplitScrollView subviews] objectAtIndex:xValue/45];
            
            double yourPercent;
            
            if ([myLabel.text isEqualToString:@"-"]) {
                self.numberOfPeopleSelected = 0;
                yourPercent = 0;
                
            }else{
                self.numberOfPeopleSelected = [myLabel.text intValue];
                yourPercent = 1.0/self.numberOfPeopleSelected * 100;
                
            }
            
            
            
            
            NSDictionary *item = [self.myInvoice.items objectAtIndex:self.itemSplitIndex];
            
            double value = [[item valueForKey:@"Value"] doubleValue];
            
            double myOwe = value * yourPercent / 100.0;
            
            self.itemSplitMyPaymentText.text = [NSString stringWithFormat:@"%.2f", myOwe];
            
            //your percent /100 * price of the item
            
         
        }
        
        
        
                
        
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
        [self setValueForOffset:newOffset :self.numberSliderScrollView];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollToNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}


-(void)scrollToNumberSplit:(id)sender{
    
    @try {
        NumberLineButton *myButton = (NumberLineButton *)sender;
        
        int newOffset = myButton.offset - 135;
        [self.itemSplitScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
        [self setValueForOffset:newOffset :self.itemSplitScrollView];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollToNumberSplit" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    
    @try {
        
        if (scrollView == self.itemSplitScrollView || scrollView == self.numberSliderScrollView) {
            CGFloat xOffset = targetContentOffset->x;
            int intOffset = round(xOffset);
            
            int whole = floor(intOffset/45.0);
            
            int remainder = intOffset % 45;
            
            if (remainder >= 22) {
                whole++;
            }
            
            int newOffset = 45 * whole;
            
            if (velocity.x == 0) {
                [scrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
                [self setValueForOffset:newOffset :scrollView];
            }
        }
        
   
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollViewWillEndDragging" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    @try {
        
        if (scrollView == self.itemSplitScrollView || scrollView == self.numberSliderScrollView) {

            CGFloat xOffset = scrollView.contentOffset.x;
            int intOffset = round(xOffset);
            
            int whole = floor(intOffset/45.0);
            
            int remainder = intOffset % 45;
            
            if (remainder >= 22) {
                whole++;
            }
            
            int newOffset = 45 * whole;
            
            [scrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
            [self setValueForOffset:newOffset :scrollView];
            
        }
    
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollViewDidEndDecelerating" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    @try {
        
        if (scrollView == self.myTableView) {
            
            if (!self.isIos6) {
                if (self.isLoading) {
                    // Update the content inset, good for section headers
                    if (scrollView.contentOffset.y > 0)
                        self.myTableView.contentInset = UIEdgeInsetsZero;
                    else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
                        self.myTableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
                } else if (self.isDragging && scrollView.contentOffset.y < 0) {
                    // Update the arrow direction and label
                    [UIView beginAnimations:nil context:NULL];
                    if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                        // User is scrolling above the header
                        self.refreshLabel.text = self.textRelease;
                        [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
                    } else { // User is scrolling somewhere within the header
                        self.refreshLabel.text = self.textPull;
                        [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
                    }
                    [UIView commitAnimations];
                }
            }
    
            
        }else{
            CGFloat xOffset = scrollView.contentOffset.x;
            xOffset +=23;
            
            int index = floor(xOffset/45.0);
            index = index + 3;
            
            for (int i = 0; i < [[scrollView subviews] count]; i++) {
                
                if (i != index) {
                    if ([LucidaBoldLabel class] == [[[scrollView subviews] objectAtIndex:i] class]) {
                        LucidaBoldLabel *otherLabel = (LucidaBoldLabel *)[[scrollView subviews] objectAtIndex:i];
                        [otherLabel setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:16]];
                        
                    }
                }
            }
            
            LucidaBoldLabel *myLabel = (LucidaBoldLabel *)[[scrollView subviews] objectAtIndex:index];
            [myLabel setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:35]];
        }
  
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
    
  
    if (!self.isRefresh) {
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
        
        
        
        CGRect myframe1 = self.myTableView.frame;
        myframe1.size.height += moveY;
        self.myTableView.frame = myframe1;
    }
    
    


    
    
    double myDue = self.myInvoice.amountDue - amountPaid;
    self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", myDue];


   

    
}

-(void)willAppearSetup{
    [self showFullTotal];
    
    [self.myTableView reloadData];
    [self.alreadyPaidTableView reloadData];
    
    if ([self.paidItemsArray count] > 0) {
        [self markPaidItems];
    }
    
        
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
            
            BOOL isSubLevel = NO;
            BOOL isTopLevel = NO;
            
            static NSString *NormalCell=@"NormalCell";
            static NSString *SubCell=@"SubCell";

            static NSInteger itemTag = 1;
            static NSInteger numberTag = 2;
            static NSInteger priceTag = 3;
            static NSInteger highLightTag = 4;
            static NSInteger myPayTag = 5;


            NSUInteger row = [indexPath row];
            NSDictionary *itemDictionary = [self.myInvoice.items objectAtIndex:row];

            if ([itemDictionary valueForKey:@"IsSubLevel"] && [[itemDictionary valueForKey:@"IsSubLevel"] isEqualToString:@"yes"]) {
                isSubLevel = YES;
            }
            
            UITableViewCell *cell;
            
            if (isSubLevel) {
                cell = [tableView dequeueReusableCellWithIdentifier:SubCell];
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:NormalCell];

            }
            
            if (cell == nil) {
                
                
                if (isSubLevel) {
                    
                    cell = [[UITableViewCell alloc]
                            initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier: SubCell];
                    
                    
                    
                    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 8, 158, 20)];
                    itemLabel.tag = itemTag;
                    [cell.contentView addSubview:itemLabel];
                    
                    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(223, 7, 75, 20)];
                    priceLabel.tag = priceTag;
                    [cell.contentView addSubview:priceLabel];
                    
                    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 7, 32, 20)];
                    numberLabel.tag = numberTag;
                    [cell.contentView addSubview:numberLabel];
                    
                    UIView *highLightView = [[UIView alloc] initWithFrame:CGRectMake(27, 2, 273, 27)];
                    highLightView.tag = highLightTag;
                    [cell.contentView addSubview:highLightView];
                    
                    UILabel *myPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 23, 273, 25)];
                    myPayLabel.tag = myPayTag;
                    [cell.contentView addSubview:myPayLabel];

                    
                    
                }else{
                    cell = [[UITableViewCell alloc]
                            initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier: NormalCell];
                    
                    
                    
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
                    
                    UILabel *myPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, 300, 25)];
                    myPayLabel.tag = myPayTag;
                    [cell.contentView addSubview:myPayLabel];

                }
                                
                
            }
            
            UILabel *itemLabel = (UILabel *)[cell.contentView viewWithTag:itemTag];
            UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
            UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:priceTag];
            UIView *highLightView = (UIView *)[cell.contentView viewWithTag:highLightTag];
            UILabel *myPayLabel = (UILabel *)[cell.contentView viewWithTag:myPayTag];


            [cell.contentView sendSubviewToBack:highLightView];
            
            highLightView.layer.borderColor = [[UIColor blackColor] CGColor];
            highLightView.layer.borderWidth = 1.0;
            highLightView.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];//[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
            
            
            
            
            
            itemLabel.backgroundColor = [UIColor clearColor];
            numberLabel.backgroundColor = [UIColor clearColor];
            priceLabel.backgroundColor = [UIColor clearColor];
            myPayLabel.backgroundColor = [UIColor clearColor];

            

            
            priceLabel.textAlignment = UITextAlignmentRight;
            numberLabel.textAlignment = UITextAlignmentLeft;
            myPayLabel.textAlignment = UITextAlignmentCenter;
            
            
            myPayLabel.textColor = [UIColor whiteColor];
            myPayLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:13];
            myPayLabel.hidden = YES;
            
            
            itemLabel.text = [itemDictionary valueForKey:@"Description"];
            
            int num = [[itemDictionary valueForKey:@"Amount"] intValue];
            double value = [[itemDictionary valueForKey:@"Value"] doubleValue] * num;
            
            
            priceLabel.text = [NSString stringWithFormat:@"%.2f", value];
            
            numberLabel.text = [NSString stringWithFormat:@"%d", [[itemDictionary valueForKey:@"Amount"] intValue]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([[itemDictionary valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
                
                CGRect frame = highLightView.frame;
                frame.size.height = 27;
                highLightView.frame = frame;
                
                highLightView.hidden = NO;
                itemLabel.textColor = [UIColor whiteColor];
                numberLabel.textColor = [UIColor whiteColor];
                priceLabel.textColor = [UIColor whiteColor];
                
                itemLabel.font = [UIFont fontWithName:@"Corbel-Bold" size:14];
                numberLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:14];
                priceLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:14];

            }else if ([[itemDictionary valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
                
                //If paying for partial
                CGRect frame = highLightView.frame;
                frame.size.height = 45;
                highLightView.frame = frame;
                
                highLightView.hidden = NO;
                itemLabel.textColor = [UIColor whiteColor];
                numberLabel.textColor = [UIColor whiteColor];
                priceLabel.textColor = [UIColor whiteColor];
                
                itemLabel.font = [UIFont fontWithName:@"Corbel-Bold" size:14];
                numberLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:14];
                priceLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:14];
                
                myPayLabel.hidden = NO;
                myPayLabel.text = [NSString stringWithFormat:@"You Pay: %.2f", [[itemDictionary valueForKey:@"AmountPayingFor"] doubleValue]];
                
            
                
            
            }else{
                highLightView.hidden = YES;
                
                itemLabel.textColor = [UIColor blackColor];
                numberLabel.textColor = [UIColor blackColor];
                priceLabel.textColor = [UIColor blackColor];
                
                itemLabel.font = [UIFont fontWithName:@"Corbel" size:14];
                numberLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
                priceLabel.font = [UIFont fontWithName:@"LucidaGrande" size:14];
            }
            
            if ([itemDictionary valueForKey:@"IsTopLevel"] && [[itemDictionary valueForKey:@"IsTopLevel"] isEqualToString:@"yes"]) {
                itemLabel.textColor = [UIColor darkGrayColor];
                numberLabel.textColor = [UIColor darkGrayColor];
                priceLabel.textColor = [UIColor darkGrayColor];
            }
            
           
            for (UIGestureRecognizer *recognizer in [cell gestureRecognizers]) {
                [cell removeGestureRecognizer:recognizer];
            }
            
            if (![[itemDictionary valueForKey:@"IsTopLevel"]isEqualToString:@"yes"]) {
                MyGestureRecognizer *lpgr = [[MyGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                lpgr.minimumPressDuration = 0.5f; //seconds
                lpgr.delegate = self;
                lpgr.selectedCell = row;
                [cell addGestureRecognizer:lpgr];
            }
            return cell;

        }
       
    
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
	
}


-(void)longPress:(id)sender{
    
    @try {
        MyGestureRecognizer *myPress = (MyGestureRecognizer *)sender;

        NSDictionary *selectedItem = [self.myInvoice.items objectAtIndex:myPress.selectedCell];
        int num = [[selectedItem valueForKey:@"Amount"] intValue];
        
        if (num == 1) {

            
            self.itemSplitView.hidden = NO;
            self.itemSplitIndex = myPress.selectedCell;
            
            
            
            self.itemSplitName.text = [NSString stringWithFormat:@"%@: $%.2f", [selectedItem valueForKey:@"Description"], [[selectedItem valueForKey:@"Value"] doubleValue]];
            
            
            if ([[selectedItem valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]) {
                self.itemSplitMyPaymentText.text = [NSString stringWithFormat:@"%.2f", [[selectedItem valueForKey:@"AmountPayingFor"] doubleValue]];
            }
            
            self.itemSplitScrollView.contentOffset = CGPointMake(0.0, 0.0);
            
            [self.itemSplitMyPaymentText becomeFirstResponder];
            
            
        }else{
            
            //open up the rows
            
            NSMutableArray *newArray =  [NSMutableArray arrayWithArray:self.myInvoice.items];
            
            [selectedItem setValue:@"yes" forKey:@"IsTopLevel"];
            
            NSMutableArray *newObjectArray = [NSMutableArray array];
            
            for (int i = 0; i < num; i++) {
                
                NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
                [newItem setValue:[NSDecimalNumber numberWithInt:1] forKey:@"Amount"];
                [newItem setValue:[selectedItem valueForKey:@"Value"] forKey:@"Value"];
                [newItem setValue:[selectedItem valueForKey:@"Description"] forKey:@"Description"];
                [newItem setValue:[selectedItem valueForKey:@"Id"] forKey:@"Id"];
                [newItem setValue:@"yes" forKey:@"IsSubLevel"];
                
                
                [newObjectArray addObject:newItem];
            }
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(myPress.selectedCell + 1, [newObjectArray count])];
            
            [newArray insertObjects:newObjectArray atIndexes:indexSet];
            
            self.myInvoice.items = [NSArray arrayWithArray:newArray];
            
            [self.myTableView reloadData];
            
            
        }
        
      
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.longPress" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
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
        }else{
            
            NSDictionary *item = [self.myInvoice.items objectAtIndex:indexPath.row];
            
            if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
                return 60;
            }
            
            return 30;

            
        }
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
                    
                    [self performSegueWithIdentifier:@"goPayCreditCard" sender:self];
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
                        [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", tmpCard.sample]];
                        
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
               
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.payNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    @try {
        if (alertView == self.overpayAlert) {
            
            if (buttonIndex == 1) {
                //HERE
                
                [self showFullTotal];
                
                
                
                [self deselectAllItems];
                
            }
        }else if (alertView == self.payAllAlert){
            
            NSDictionary *dictionaryItem = [self.myInvoice.items objectAtIndex:self.payAllSelectedIndex];
            int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
            
            
            if (buttonIndex == 0) {
                //NO - sub items
                
                NSMutableArray *newArray =  [NSMutableArray arrayWithArray:self.myInvoice.items];
                
                [dictionaryItem setValue:@"yes" forKey:@"IsTopLevel"];
                
                NSMutableArray *newObjectArray = [NSMutableArray array];
                
                for (int i = 0; i < num; i++) {
                    
                    NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
                    [newItem setValue:[NSDecimalNumber numberWithInt:1] forKey:@"Amount"];
                    [newItem setValue:[dictionaryItem valueForKey:@"Value"] forKey:@"Value"];
                    [newItem setValue:[dictionaryItem valueForKey:@"Description"] forKey:@"Description"];
                    [newItem setValue:[dictionaryItem valueForKey:@"Id"] forKey:@"Id"];
                    [newItem setValue:@"yes" forKey:@"IsSubLevel"];
                    
                    
                    [newObjectArray addObject:newItem];
                }
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.payAllSelectedIndex + 1, [newObjectArray count])];
                
                [newArray insertObjects:newObjectArray atIndexes:indexSet];
                
                self.myInvoice.items = [NSArray arrayWithArray:newArray];
                
                [self.myTableView reloadData];
                
             

            }else{
                //YES
                
                
                
                
                double value = [[dictionaryItem valueForKey:@"Value"] doubleValue] * num;
                
                self.myItemizedTotal += value;
                
                [dictionaryItem setValue:@"yes" forKey:@"IsPayingFor"];
                
                [self.myTableView reloadData];
                
                if (![self isAnyRowSelected]) {
                    self.myItemizedTotal = 0.0;
                    
                    
                    [self showFullTotal];
                }else{
                    //some are still selected
                    
                    [self setItemizedTotalValue];
                    
                    
                    
                }
                
                
            }
            
            
            
        }else{
            [self.actionSheet showInView:self.view];
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exceptions; %@", exception);
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
            AdditionalTipViewController *controller = [segue destinationViewController];
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
            
            
            if ([self isAnyRowSelected]) {
                
                self.myItemArray = [NSMutableArray array];
                
                for (int i = 0; i < [self.myInvoice.items  count]; i++) {
                    
                    NSDictionary *tmpItem = [self.myInvoice.items objectAtIndex:i];
                    NSMutableDictionary *sendInItem = [NSMutableDictionary dictionary];
                    if ([[tmpItem valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
                        
                        [sendInItem setValue:[tmpItem valueForKey:@"Amount"] forKey:@"Amount"];
                        [sendInItem setValue:[tmpItem valueForKey:@"Id"] forKey:@"ItemId"];
                        [sendInItem setValue:[NSNumber numberWithDouble:1.0] forKey:@"Percent"];
                        [self.myItemArray addObject:sendInItem];
                        
                    }else if ([[tmpItem valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
                        
                        
                        double myAmount = [[tmpItem valueForKey:@"AmountPayingFor"] doubleValue];
                        double totalAmount = [[tmpItem valueForKey:@"Value"] doubleValue];
                        
                        double myPercent = myAmount/totalAmount;
                        
                        [sendInItem setValue:[NSNumber numberWithInt:1] forKey:@"Amount"];
                        [sendInItem setValue:[tmpItem valueForKey:@"Id"] forKey:@"ItemId"];
                        [sendInItem setValue:[NSNumber numberWithDouble:myPercent] forKey:@"Percent"];
                        [self.myItemArray addObject:sendInItem];
                        
                    }
                    
                }
                
            
                controller.myItemsArray = [NSArray arrayWithArray:self.myItemArray];



            }
            
            
            
           
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
        
        if ([string isEqualToString:@""]) {
            return YES;
        }
        
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
        

        self.isRefresh = YES;
        [self.refreshControl endRefreshing];
        if (self.shouldCallStop) {
            [self stopLoading];
        }
        
        
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
            
            self.paidItemsArray = [NSMutableArray array];
            @try {
                NSArray *payments = [theInvoice valueForKey:@"Payments"];
                for (int i = 0; i < [payments count]; i++) {
                    NSDictionary *payment = [payments objectAtIndex:i];
                    
                    NSArray *paidItems = [payment valueForKey:@"PaidItems"];
                    
                    NSString *paidBy = [[payments valueForKey:@"Name"] objectAtIndex:0];
                    NSString *paidByAct = [[payments valueForKey:@"Account"] objectAtIndex:0];
                    
                    for (int j = 0; j < [paidItems count]; j++) {
                        NSDictionary *paidItem = [paidItems objectAtIndex:j];
                        [paidItem setValue:paidBy forKey:@"PaidBy"];
                        [paidItem setValue:paidByAct forKey:@"PaidByAct"];
                        
                        [self.paidItemsArray addObject:paidItem];
                    }
                }
                
                
                
            }
            @catch (NSException *exception) {
                
            }
        
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


-(void)markPaidItems{
    
    @try {
        
        for (int i = 0; i < [self.paidItemsArray count]; i++) {
            NSDictionary *paidItem = [self.paidItemsArray objectAtIndex:i];
            NSLog(@"Paid Item: %@", paidItem);
        }
        
        
        NSLog(@"Test");
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.markPaidItems" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

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

    
    NSString *myTotalString = [NSString stringWithFormat:@"%.6f", myTotal];
    NSString *newDueString = [NSString stringWithFormat:@"%.6f", newDue];

    
    if ([myTotalString doubleValue] > [newDueString doubleValue]) {
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




//iOS 5 pull to refresh code

- (void)setupStrings{
    self.textPull = @"Pull down to refresh...";
    self.textRelease = @"Release to refresh...";
    self.textLoading = @"Loading...";
    
}


//Scroll down to refresh method
- (void)addPullToRefreshHeader {
    
    
    self.refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    self.refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    self.refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    self.refreshLabel.backgroundColor = [UIColor clearColor];
    self.refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.refreshLabel.textAlignment = UITextAlignmentCenter;
    
    self.refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    self.refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                         (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                         27, 44);
    
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;
    
    [self.refreshHeaderView addSubview:self.refreshLabel];
    [self.refreshHeaderView addSubview:self.refreshArrow];
    [self.refreshHeaderView addSubview:self.refreshSpinner];
    
    [self.myTableView addSubview:self.refreshHeaderView];
    
    
    
    
}

//Scroll down to refresh method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isLoading) return;
    self.isDragging = YES;
}



//Scroll down to refresh method
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.isLoading) return;
    self.isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
    
    
}

//Scroll down to refresh method
- (void)startLoading {
    self.isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.myTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        
        self.refreshLabel.text = self.textLoading;
        self.refreshArrow.hidden = YES;
        [self.refreshSpinner startAnimating];
    }];
    
    
    // Refresh action!
    [self refresh];
}

//Scroll down to refresh method
- (void)stopLoading {
    self.shouldCallStop = NO;
    self.isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    
    self.myTableView.contentInset = UIEdgeInsetsZero;
    [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    
    [UIView commitAnimations];
}

//Scroll down to refresh method
- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];
    
    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];
    
}

//Scroll down to refresh method
- (void)refresh {
    // Don't forget to call stopLoading at the end.
    self.shouldCallStop = YES;
    
    [self refreshInvoice];
    
    
}



- (IBAction)itemSplitSaveAction {
    
    NSDictionary *item = [self.myInvoice.items objectAtIndex:self.itemSplitIndex];
    
    double myItemPayemnt = [self.itemSplitMyPaymentText.text doubleValue];
    double itemPrice = [[item valueForKey:@"Value"] doubleValue];
    
    
    if (myItemPayemnt > itemPrice) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Overpayment" message:@"You cannot pay for more than the cost of this item." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        
        if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
            
            double value = [[item valueForKey:@"Value"] doubleValue];
            self.myItemizedTotal -= value;
            
        }else if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
            
            double myValue = [[item valueForKey:@"AmountPayingFor"] doubleValue];
            self.myItemizedTotal -= myValue;
        }
        
        [item setValue:@"maybe" forKey:@"IsPayingFor"];
        [item setValue:[NSNumber numberWithDouble:myItemPayemnt] forKey:@"AmountPayingFor"];
        
        self.itemSplitView.hidden = YES;
        [self.itemSplitMyPaymentText resignFirstResponder];
        
        self.myItemizedTotal += myItemPayemnt;
        
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
- (IBAction)closeItemSplitAction {
    self.itemSplitView.hidden = YES;
    [self.itemSplitMyPaymentText resignFirstResponder];
}
@end
