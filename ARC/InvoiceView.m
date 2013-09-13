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
#import "HomeNavigationController.h"
#import "RegisterDwollaView.h"
#import "ArcClient.h"
#import "ArcUtility.h"
#import "MFSideMenu.h"
#import "AdditionalTipViewController.h"
#import "NumberLineButton.h"
#import "RightViewController.h"
#import "MyGestureRecognizer.h"
#import "SteelfishLabel.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface InvoiceView ()

@end

@implementation InvoiceView

-(void)viewWillDisappear:(BOOL)animated{
    
    self.navigationController.sideMenu.allowSwipeOpenRight = NO;

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
    

    self.navigationController.sideMenu.allowSwipeOpenRight = YES;

    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hasShownInvoiceHint"] length] == 0) {
        [self showInvoiceHint];
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"hasShownInvoiceHint"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

  
    
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
        
        [rSkybox addEventToSession:@"viewInvoiceView"];
        
        self.splitDollarPercentBackView.hidden = YES;
        self.splitDollarPercentBackView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.splitDollarPercentBackView.layer.borderWidth = 2.0;
        self.splitDollarPercentBackView.layer.shadowOffset = CGSizeMake(0,0);
        self.splitDollarPercentBackView.layer.shadowRadius = 5;
        self.splitDollarPercentBackView.layer.shadowOpacity = 0.6;
        self.howManySaveButton.text = @"Save";
        self.howManySaveButton.tintColor = dutchDarkBlueColor;
        self.howManySaveButton.textColor = [UIColor whiteColor];
        
        self.howManyCancelButton.text = @"Cancel";
        
        self.cancelItemSplitButton.text = @"Cancel";
        
        self.splitDollarSaveButton.text = @"Save";
        self.splitDollarSaveButton.tintColor = dutchDarkBlueColor;
        self.splitDollarSaveButton.textColor = [UIColor whiteColor];
        
        self.splitDollarCancelButton.text = @"Cancel";

        self.cancelSplitPeople.text = @"Cancel";

        self.splitView.layer.cornerRadius = 3.0;
        self.splitView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.splitView.layer.borderWidth = 1.0;
        self.splitView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.splitView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
        self.splitView.layer.shadowOpacity = .5f;
        self.splitView.layer.shadowRadius = 10.0f;
        self.splitView.clipsToBounds = YES;
        
        
        self.howManyView.layer.cornerRadius = 3.0;
        self.howManyView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.howManyView.layer.borderWidth = 1.0;
        self.howManyView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.howManyView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
        self.howManyView.layer.shadowOpacity = .5f;
        self.howManyView.layer.shadowRadius = 10.0f;
        self.howManyView.clipsToBounds = YES;
        
        
        
        self.splitViewDollar.layer.cornerRadius = 3.0;
        self.splitViewDollar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.splitViewDollar.layer.borderWidth = 1.0;
        self.splitViewDollar.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.splitViewDollar.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
        self.splitViewDollar.layer.shadowOpacity = .5f;
        self.splitViewDollar.layer.shadowRadius = 10.0f;
        self.splitViewDollar.clipsToBounds = YES;
        
        
        self.itemSplitView.layer.cornerRadius = 3.0;
        self.itemSplitView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.itemSplitView.layer.borderWidth = 1.0;
        self.itemSplitView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.itemSplitView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
        self.itemSplitView.layer.shadowOpacity = .5f;
        self.itemSplitView.layer.shadowRadius = 10.0f;
        self.itemSplitView.clipsToBounds = YES;
        
        
        
        self.helpOverlay = [self.storyboard instantiateViewControllerWithIdentifier:@"invoiceHelpOverlay"];
        self.helpOverlay.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.view addSubview:self.helpOverlay.view];
        self.helpOverlay.view.alpha = 0.0;
        
        
        
        
        self.splitPercentageButton.text = @"÷";
        self.splitPercentageButton.tintColor = dutchDarkBlueColor;
        self.splitPercentageButton.textColor = [UIColor whiteColor];
        self.splitPercentageButton.cornerRadius = 0.0;
        self.splitDollarButton.text = @"$";
        self.splitDollarButton.tintColor = dutchDarkBlueColor;
        self.splitDollarButton.textColor = [UIColor whiteColor];
        self.splitDollarButton.cornerRadius = 0.0;

        
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
        
        
      //  self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
      //  self.topLineView.layer.shadowRadius = 1;
     //   self.topLineView.layer.shadowOpacity = 0.2;
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;

     
        
        self.splitCancelButton.text = @"Cancel";
        
        self.splitFullButton.textColor = [UIColor whiteColor];
        self.splitFullButton.text = @"Pay Full";
        self.splitFullButton.tintColor = dutchDarkBlueColor;
        
        self.splitSaveButton.textColor = [UIColor whiteColor];
        self.splitSaveButton.text = @"Save";
        self.splitSaveButton.tintColor = dutchDarkBlueColor;
    
        
        self.itemSplitSaveButton.textColor = [UIColor whiteColor];
        self.itemSplitSaveButton.text = @"Save";
        self.itemSplitSaveButton.tintColor = dutchDarkBlueColor;
        
        
        
        self.payBillButton.textColor = [UIColor whiteColor];
        self.payBillButton.text = @"Pay Bill!";
        self.payBillButton.tintColor = dutchGreenColor;
        self.payBillButton.cornerRadius = 3.0;
        self.payBillButton.borderColor = [UIColor darkGrayColor];
        self.payBillButton.borderWidth = 0.5;
        
        
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
      
        
        
        SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Invoice"];
        self.navigationItem.titleView = navLabel;
  
        SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Invoice"];
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
        
        self.alphaBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        self.alphaBackView.alpha = 0.5;
        self.alphaBackView.backgroundColor = [UIColor blackColor];
        self.alphaBackView.hidden = YES;
        [self.view insertSubview:self.alphaBackView belowSubview:self.itemSplitView];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.splitDollarPercentBackView.hidden = YES;

    
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
                [self adjustLength];
                
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
                    
                    BOOL isDuplicate = NO;
                    if ([[dictionaryItem valueForKey:@"Amount"] doubleValue] > 1) {
                        isDuplicate = YES;
                    }
                    
                    if ([[dictionaryItem valueForKey:@"isPaidFor"] isEqualToString:@"yes"]) {
                        
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Paid For" message:@"This item has already been paid for, please select a different item." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                        
                    }else if ([[dictionaryItem valueForKey:@"isPaidFor"] isEqualToString:@"maybe"] && !isDuplicate){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Partially Paid For" message:@"This item has already been partially paid for.  If you wish to pay for part of it also, press and hold on the item." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
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
                            double value = [[dictionaryItem valueForKey:@"Value"] doubleValue];
                            NSString *description = [dictionaryItem valueForKey:@"Description"];
                            
                            if (num > 1) {
                                
                                self.howManyTitle.text = [NSString stringWithFormat:@"%d %@, %.2f each", num, description, value];
                                [self showHowManyView];
                                self.howManyItemIndex = indexPath.row;
                                
                            }else{
                                
                                self.myItemizedTotal += value;
                                
                                [dictionaryItem setValue:@"yes" forKey:@"IsPayingFor"];
                            }
                            
                            
                        }
                        
                        
                    }
                    
               

                    
                }
            
            
            [self.myTableView reloadData];
            [self adjustLength];

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
    

    
    double myTax = [ArcUtility roundUpToNearestPenny:(self.myInvoice.tax * myPercent)];
    double myServiceCharge = [ArcUtility roundUpToNearestPenny:(self.myInvoice.serviceCharge * myPercent)];
    double myDiscount = [ArcUtility roundDownToNearestPenny:(self.myInvoice.discount * myPercent)];
    


    double myTotal = self.myItemizedTotal + myTax + myServiceCharge - myDiscount;
    //myTotal = [ArcUtility roundUpToNearestPenny:myTotal];
    

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
            
            SteelfishBoldLabel *numberLabel = [[SteelfishBoldLabel alloc] initWithFrame:CGRectMake(i * 45, 5, 45, 45) andSize:size];
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
            
            SteelfishBoldLabel *numberLabel = [[SteelfishBoldLabel alloc] initWithFrame:CGRectMake(i * 45, 5, 45, 45) andSize:size];
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
            
            SteelfishBoldLabel *myLabel = (SteelfishBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:xValue/45];
            
            double yourPercent;
            
            if ([myLabel.text isEqualToString:@"-"]) {
                self.numberOfPeopleSelected = 0;
                yourPercent = 0;
                
            }else{
                self.numberOfPeopleSelected = [myLabel.text intValue];
                yourPercent = 1.0/self.numberOfPeopleSelected * 100;
                
            }
            
            
            
            
            double myDue = self.myInvoice.amountDue * yourPercent / 100.0;
            
            //self.splitMyPaymentTextField.text = [NSString stringWithFormat:@"%.2f", myDue];
            
            self.splitPeopleYouPayLabel.text = [NSString stringWithFormat:@"You pay: $%.2f", myDue];
            self.splitMyDue = myDue;
            
        }else{
            int xValue = offset + 135;
            
            SteelfishBoldLabel *myLabel = (SteelfishBoldLabel *)[[self.itemSplitScrollView subviews] objectAtIndex:xValue/45];
            
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
            
            //self.itemSplitMyPaymentText.text = [NSString stringWithFormat:@"%.2f", myOwe];
            self.splitItemMyDue = myOwe;
            
            self.splitItemMyPaymentLabel.text = [NSString stringWithFormat:@"You pay: $%.2f", myOwe];
            
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
                    if ([SteelfishBoldLabel class] == [[[scrollView subviews] objectAtIndex:i] class]) {
                        SteelfishBoldLabel *otherLabel = (SteelfishBoldLabel *)[[scrollView subviews] objectAtIndex:i];
                        [otherLabel setFont: [UIFont fontWithName: FONT_BOLD size:16]];
                        
                    }
                }
            }
            
            if (index < [[scrollView subviews] count]) {
                SteelfishBoldLabel *myLabel = (SteelfishBoldLabel *)[[scrollView subviews] objectAtIndex:index];
                [myLabel setFont: [UIFont fontWithName: FONT_BOLD size:35]];
            }
           
        }
  
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.scrollViewDidScroll" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)setUpView{
    

    self.bottomHalfView.backgroundColor = [UIColor clearColor];

    
    self.subLabel.text = [NSString stringWithFormat:@"%.2f", [self.myInvoice subtotal]];
    self.taxLabel.text = [NSString stringWithFormat:@"%.2f", self.myInvoice.tax];
    self.gratLabel.text = [NSString stringWithFormat:@"%.2f", self.myInvoice.serviceCharge];
    self.discLabel.text = [NSString stringWithFormat:@"- %.2f", self.myInvoice.discount];
    
    
    //**Set up balance screen
    RightViewController *right = [self.navigationController.sideMenu getRightSideMenu];
   
    right.invoiceController = self;
    right.myInvoice = self.myInvoice;
    right.topInvoiceLabel.text = [NSString stringWithFormat:@"Check #: %@", self.myInvoice.number];
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
        right.paymentsArray = [NSMutableArray array];
    }
    
    right.totalDueLabel.text = [NSString stringWithFormat:@"%.2f", self.myInvoice.amountDue];
    right.totalRemainingLabel.text = [NSString stringWithFormat:@"%.2f", newDue];
    right.alreadyPaidLabel.text = [NSString stringWithFormat:@"%.2f", amountPaid];
    
    
    
    
 
    
    //New Code
    
  
    if (!self.isRefresh) {
        self.moveY = 0;
        
        double alreadyPaid = [self.myInvoice calculateAmountPaid];
        if (alreadyPaid == 0.0){
            self.alreadyPaid.hidden = YES;
            self.alreadyPaidNameLabel.hidden = YES;
            self.moveY +=20;
        }else{
            self.alreadyPaidLabel.text = [NSString stringWithFormat:@"- %.2f", alreadyPaid];
        }
        
        
        if (self.myInvoice.discount == 0.0) {
            self.discLabel.hidden = YES;
            self.discNameLabel.hidden = YES;
            self.moveY +=20;
        }else{
            
            CGRect myframe2 = self.discLabel.frame;
            myframe2.origin.y += self.moveY;
            self.discLabel.frame = myframe2;
            
            CGRect myframe3 = self.discNameLabel.frame;
            myframe3.origin.y += self.moveY;
            self.discNameLabel.frame = myframe3;
            
        }
        
        if (self.myInvoice.serviceCharge == 0.0) {
            self.gratLabel.hidden = YES;
            self.gratNameLabel.hidden = YES;
            self.moveY +=20;
        }else{
            
            CGRect myframe2 = self.gratLabel.frame;
            myframe2.origin.y += self.moveY;
            self.gratLabel.frame = myframe2;
            
            CGRect myframe3 = self.gratNameLabel.frame;
            myframe3.origin.y += self.moveY;
            self.gratNameLabel.frame = myframe3;
        }
        
        CGRect myframe = self.subtotalBackView.frame;
        myframe.origin.y += self.moveY;
        self.subtotalBackView.frame = myframe;
        
        
        
        CGRect myframe1 = self.myTableView.frame;
        myframe1.size.height += self.moveY;
        self.myTableView.frame = myframe1;
    }
    
    

    [self adjustLength];

    
    
    double myDue = self.myInvoice.amountDue - amountPaid;
    self.amountLabel.text = [NSString stringWithFormat:@"%.2f", myDue];

}

-(void)adjustLength{
    
    float height = self.myTableView.frame.size.height;
    
    int numItems = [self.myInvoice.items count];
    
    NSLog(@"NUM ITEMS: %d", numItems);
    
   // float neededHeight = numItems * 30 + 15;
    
    float neededHeight = 15;
    
    for (int i = 0; i < numItems; i++) {
        NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
        if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]) {
            neededHeight += 60;
        }else{
            neededHeight += 30;
        }
    }
    
    
    if (neededHeight < 100) {
        neededHeight = 100;
    }
    
    int maxTableHeight = 0;
    if (self.view.frame.size.height > 500) {
        maxTableHeight = 200 + self.moveY;
    }else{
        maxTableHeight = 112 + self.moveY;
    }
    
    NSLog(@"Needed Height: %f",neededHeight);

    NSLog(@"Max Height: %d", maxTableHeight);

    
    if (neededHeight < maxTableHeight) {
        
        if (height > neededHeight) {
            
            float wastedSpace = height - neededHeight;
            
            
            CGRect frame = self.myTableView.frame;
            frame.size.height -= wastedSpace;
            self.myTableView.frame = frame;
            
            CGRect frame1 = self.receiptView.frame;
            frame1.size.height -= wastedSpace;
            self.receiptView.frame = frame1;
            
            
            CGRect frame2 = self.bottomHalfView.frame;
            frame2.origin.y -= wastedSpace;
            self.bottomHalfView.frame = frame2;
            
            
            //move the payView
            
            CGRect frame3 = self.payView.frame;
            frame3.origin.y -= wastedSpace/2.0;
            self.payView.frame = frame3;
        }else{
            //current height is less than what is needed
            
            float neededSpace = neededHeight - height;
            float spaceToMove = neededSpace;
            
            if (spaceToMove + height > maxTableHeight) {
                spaceToMove = maxTableHeight - height;
            }
            
            NSLog(@"Space TO MOVE: %f", spaceToMove);
            
            CGRect frame = self.myTableView.frame;
            frame.size.height += spaceToMove;
            self.myTableView.frame = frame;
            
            CGRect frame1 = self.receiptView.frame;
            frame1.size.height += spaceToMove;
            self.receiptView.frame = frame1;
            
            
            CGRect frame2 = self.bottomHalfView.frame;
            frame2.origin.y += spaceToMove;
            self.bottomHalfView.frame = frame2;
            
            
            //move the payView
            
            CGRect frame3 = self.payView.frame;
            frame3.origin.y += spaceToMove/2.0;
            self.payView.frame = frame3;
            
            
            
            
        }
        
    }else{
        
        
        //need more than can have...move up to max table height
        
        float spaceToMove = maxTableHeight - height;
        
        CGRect frame = self.myTableView.frame;
        frame.size.height += spaceToMove;
        self.myTableView.frame = frame;
        
        CGRect frame1 = self.receiptView.frame;
        frame1.size.height += spaceToMove;
        self.receiptView.frame = frame1;
        
        
        CGRect frame2 = self.bottomHalfView.frame;
        frame2.origin.y += spaceToMove;
        self.bottomHalfView.frame = frame2;
        
        
        //move the payView
        
        CGRect frame3 = self.payView.frame;
        frame3.origin.y += spaceToMove/2.0;
        self.payView.frame = frame3;
        
        
    }
    
}

-(void)willAppearSetup{
    [self showFullTotal];
    
    [self.myTableView reloadData];
    [self.alreadyPaidTableView reloadData];
    
    if ([self.paidItemsArray count] > 0) {
        [self showPaidItems];
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
    
            
            SteelfishBoldLabel *nameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
            SteelfishBoldLabel *amountLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:2];
            SteelfishTextView *notesText = (SteelfishTextView *)[cell.contentView viewWithTag:3];
            
            NSUInteger row = [indexPath row];
            
            NSDictionary *payment = [self.myInvoice.payments objectAtIndex:row];
            
            nameLabel.text = [payment valueForKey:@"Name"];
        
            double amountDouble = [[payment valueForKey:@"Amount"] doubleValue];
            
            amountLabel.text = [NSString stringWithFormat:@"$%.2f", amountDouble];
            
            if ([payment valueForKey:@"Notes"] && [[payment valueForKey:@"Notes"] length] > 0) {
                notesText.hidden = NO;
                notesText.text = [payment valueForKey:@"Notes"];
                
                CGSize constraints = CGSizeMake(200, 900);
                CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:FONT_REGULAR size:14] constrainedToSize:constraints];
                
                CGRect frame = notesText.frame;
                frame.size.height = totalSize.height + 15;
                notesText.frame = frame;
                
                
            }else{
                notesText.hidden = YES;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;

            
        }else{
            
            int fontSize = 16;
            
            BOOL isSubLevel = NO;
            //BOOL isTopLevel = NO;
            
            static NSString *NormalCell=@"NormalCell";
            static NSString *SubCell=@"SubCell";

            static NSInteger itemTag = 1;
            static NSInteger numberTag = 2;
            static NSInteger priceTag = 3;
            static NSInteger highLightTag = 4;
            static NSInteger myPayTag = 5;
            static NSInteger alreadyPaidTag = 6;



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
                    
                    
                    
                    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 6, 158, 20)];
                    itemLabel.tag = itemTag;
                    [cell.contentView addSubview:itemLabel];
                    
                    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(223, 6, 75, 20)];
                    priceLabel.tag = priceTag;
                    [cell.contentView addSubview:priceLabel];
                    
                    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 6, 32, 20)];
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
                    
                    
                    
                    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 6, 188, 20)];
                    itemLabel.tag = itemTag;
                    [cell.contentView addSubview:itemLabel];
                    
                    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(223, 5, 75, 20)];
                    priceLabel.tag = priceTag;
                    [cell.contentView addSubview:priceLabel];
                    
                    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 5, 32, 20)];
                    numberLabel.tag = numberTag;
                    [cell.contentView addSubview:numberLabel];
                    
                    UIView *highLightView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 300, 27)];
                    highLightView.tag = highLightTag;
                    [cell.contentView addSubview:highLightView];
                    
                    UILabel *myPayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, 300, 25)];
                    myPayLabel.tag = myPayTag;
                    [cell.contentView addSubview:myPayLabel];
                    
                    UILabel *alrealdyPaidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 300, 30)];
                    alrealdyPaidLabel.tag = alreadyPaidTag;
                    [cell.contentView addSubview:alrealdyPaidLabel];
                    

                }
                                
                
            }
            
            UILabel *itemLabel = (UILabel *)[cell.contentView viewWithTag:itemTag];
            UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
            UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:priceTag];
            UIView *highLightView = (UIView *)[cell.contentView viewWithTag:highLightTag];
            UILabel *myPayLabel = (UILabel *)[cell.contentView viewWithTag:myPayTag];
            UILabel *alreadyPaidLabel = (UILabel *)[cell.contentView viewWithTag:alreadyPaidTag];



            [cell.contentView sendSubviewToBack:highLightView];
            
            highLightView.layer.borderColor = [[UIColor blackColor] CGColor];
            highLightView.layer.borderWidth = 1.0;
            highLightView.alpha = 1.0;
            highLightView.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];//[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
            highLightView.frame = CGRectMake(0, 2, 300, 27);
            
            
            
            
            itemLabel.backgroundColor = [UIColor clearColor];
            numberLabel.backgroundColor = [UIColor clearColor];
            priceLabel.backgroundColor = [UIColor clearColor];
            myPayLabel.backgroundColor = [UIColor clearColor];

            

            
            priceLabel.textAlignment = UITextAlignmentRight;
            numberLabel.textAlignment = UITextAlignmentLeft;
            myPayLabel.textAlignment = UITextAlignmentCenter;
            
            alreadyPaidLabel.textColor = [UIColor whiteColor];
            alreadyPaidLabel.textAlignment = UITextAlignmentCenter;
            alreadyPaidLabel.hidden = YES;
            alreadyPaidLabel.backgroundColor = [UIColor clearColor];
            
            
            myPayLabel.textColor = [UIColor whiteColor];
            myPayLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize-1];
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
                
                itemLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize];
                numberLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize];
                priceLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize];

            }else if ([[itemDictionary valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
                
                //If paying for partial
                CGRect frame = highLightView.frame;
                frame.size.height = 45;
                highLightView.frame = frame;
                
                highLightView.hidden = NO;
                itemLabel.textColor = [UIColor whiteColor];
                numberLabel.textColor = [UIColor whiteColor];
                priceLabel.textColor = [UIColor whiteColor];
                
                itemLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize];
                numberLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize];
                priceLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize];
                
                myPayLabel.hidden = NO;
                myPayLabel.text = [NSString stringWithFormat:@"You Pay: %.2f", [[itemDictionary valueForKey:@"AmountPayingFor"] doubleValue]];
                
            
                
            
            }else{
                highLightView.hidden = YES;
                
                itemLabel.textColor = [UIColor blackColor];
                numberLabel.textColor = [UIColor blackColor];
                priceLabel.textColor = [UIColor blackColor];
                
                itemLabel.font = [UIFont fontWithName:FONT_REGULAR size:fontSize];
                numberLabel.font = [UIFont fontWithName:FONT_REGULAR size:fontSize];
                priceLabel.font = [UIFont fontWithName:FONT_REGULAR size:fontSize];
            }
            
            
            if (highLightView.hidden == YES) {
                
            
                if ([[itemDictionary valueForKey:@"isPaidFor"] isEqualToString:@"yes"]) {
                    
                    [cell.contentView bringSubviewToFront:highLightView];
                    alreadyPaidLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize+3];

                    [cell.contentView bringSubviewToFront:alreadyPaidLabel];

                    alreadyPaidLabel.hidden = NO;
                    alreadyPaidLabel.text = @"PAID";
                    highLightView.hidden = NO;
                    highLightView.layer.borderColor = [[UIColor blackColor] CGColor];
                    highLightView.layer.borderWidth = 1.0;
                    highLightView.backgroundColor = [UIColor lightGrayColor];
                    highLightView.alpha = 0.7;
                    
                }else if ([[itemDictionary valueForKey:@"isPaidFor"] isEqualToString:@"maybe"]){
                    
                    [cell.contentView bringSubviewToFront:highLightView];
                    alreadyPaidLabel.font = [UIFont fontWithName:FONT_BOLD size:fontSize+1];

                    [cell.contentView bringSubviewToFront:alreadyPaidLabel];
                    
                    alreadyPaidLabel.hidden = NO;
                    alreadyPaidLabel.text = @"% Paid";
                    highLightView.hidden = NO;
                    highLightView.layer.borderColor = [[UIColor blackColor] CGColor];
                    highLightView.layer.borderWidth = 1.0;
                    highLightView.backgroundColor = [UIColor lightGrayColor];
                    highLightView.alpha = 0.7;
                    
                    
                }else{
                    
                }
                
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
            
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundColor:[UIColor clearColor]];

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
        
        
        if ([[selectedItem valueForKey:@"isPaidFor"] isEqualToString:@"yes"]) {
            
            if (self.isShowingAlreadyPaidAlert) {
                
            }else{
                self.isShowingAlreadyPaidAlert = YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Paid For" message:@"This item has already been paid for, please select a different item." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
           

        }else{
            if (num == 1) {
                
                
                [self showSplitViewItem];
                self.itemSplitIndex = myPress.selectedCell;
                
                
                
                self.itemSplitName.text = [NSString stringWithFormat:@"%@: $%.2f", [selectedItem valueForKey:@"Description"], [[selectedItem valueForKey:@"Value"] doubleValue]];
                
                
                if ([[selectedItem valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]) {
                    self.itemSplitMyPaymentText.text = [NSString stringWithFormat:@"%.2f", [[selectedItem valueForKey:@"AmountPayingFor"] doubleValue]];
                }
                
                self.itemSplitScrollView.contentOffset = CGPointMake(0.0, 0.0);
                
                [self.itemSplitMyPaymentText becomeFirstResponder];
                
                
            }else{
                
                NSDictionary *dictionaryItem = [self.myInvoice.items objectAtIndex:myPress.selectedCell];
                
                int num = [[dictionaryItem valueForKey:@"Amount"] intValue];
                double value = [[dictionaryItem valueForKey:@"Value"] doubleValue];
                NSString *description = [dictionaryItem valueForKey:@"Description"];
                
                
                self.howManyTitle.text = [NSString stringWithFormat:@"%d %@, %.2f each", num, description, value];
                [self showHowManyView];
                self.howManyItemIndex = myPress.selectedCell;
                
                
                /*
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
                 [self adjustLength];
                 */
                
            }
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
                    CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:FONT_REGULAR size:14] constrainedToSize:constraints];
                    
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
        
        NSString *event = [NSString stringWithFormat:@"clickedPayButton - invoiceId: %d", self.myInvoice.invoiceId];
        [rSkybox addEventToSession:event];

        [self performSegueWithIdentifier:@"goPayCreditCard" sender:nil];
        /*
        
      
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"] length] > 0) {
            
         
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
            
            [self performSegueWithIdentifier:@"goPayCreditCard" sender:self];
                        
        }
         
         */
        
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
            
            if (self.isShowingAlreadyPaidAlert) {
                self.isShowingAlreadyPaidAlert = NO;
                
            }else{
                [self.actionSheet showInView:self.view];

            }
            
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
                        
                        while (myPercent > 1) {
                            myPercent -= 1;
                            
                            NSMutableDictionary *newItem = [NSMutableDictionary dictionary];

                            [newItem setValue:[NSNumber numberWithInt:1] forKey:@"Amount"];
                            [newItem setValue:[tmpItem valueForKey:@"Id"] forKey:@"ItemId"];
                            [newItem setValue:[NSNumber numberWithInt:1] forKey:@"Percent"];
                            [self.myItemArray addObject:newItem];
                            
                        }
                        
                        [sendInItem setValue:[NSNumber numberWithInt:1] forKey:@"Amount"];
                        [sendInItem setValue:[tmpItem valueForKey:@"Id"] forKey:@"ItemId"];
                        [sendInItem setValue:[NSNumber numberWithDouble:myPercent] forKey:@"Percent"];
                        [self.myItemArray addObject:sendInItem];
                        
                    }
                    
                }
                
            
                
                
                controller.myItemsArray = [NSArray arrayWithArray:self.myItemArray];



            }
            
            
            
           
        }else if ([[segue identifier] isEqualToString:@"goSplitCheck"]) {
            
          
            
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
                NSLog(@"Payments Class: %@", [payments class]);
                
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
            
            self.didShowPaidItems = NO;

            [self showPaidItems];
            
            
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
        
        //First loop to see if anything needs to be itemized out because part of it is already paid for
        for (int i = 0; i < [self.myInvoice.items count]; i++) {
            
            NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
            
            if ([[[item valueForKey:@"Amount"] stringValue] isEqualToString:@"2"]) {
                
                for (int j = 0; j < [self.paidItemsArray count]; j++) {
                    
                    NSDictionary *paidItem = [self.paidItemsArray objectAtIndex:j];
                    
                    if ([[[paidItem valueForKey:@"ItemId"] stringValue] isEqualToString:[[item valueForKey:@"Id"] stringValue]] && ![[[paidItem valueForKey:@"Amount"] stringValue] isEqualToString:[[item valueForKey:@"Amount"] stringValue]]) {
                        //Itemize it
                        
                        [item setValue:@"yes" forKey:@"IsTopLevel"];
                        
                        NSMutableArray *newObjectArray = [NSMutableArray array];
                        NSMutableArray *newArray =  [NSMutableArray arrayWithArray:self.myInvoice.items];

                        int num = [[item valueForKey:@"Amount"] intValue];
                        
                        for (int i = 0; i < num; i++) {
                            
                            NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
                            [newItem setValue:[NSDecimalNumber numberWithInt:1] forKey:@"Amount"];
                            [newItem setValue:[item valueForKey:@"Value"] forKey:@"Value"];
                            [newItem setValue:[item valueForKey:@"Description"] forKey:@"Description"];
                            [newItem setValue:[item valueForKey:@"Id"] forKey:@"Id"];
                            [newItem setValue:@"yes" forKey:@"IsSubLevel"];
                            
                            
                            [newObjectArray addObject:newItem];
                        }
                        
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i + 1, [newObjectArray count])];
                        
                        [newArray insertObjects:newObjectArray atIndexes:indexSet];
                        
                        self.myInvoice.items = [NSArray arrayWithArray:newArray];
                        
                        break;
                        
                        
                        
                        
                    }
                }
                
            }
            
            
        }
        
        //Receipt is now itemized out where it needs to be
        
        for (int i = 0; i < [self.myInvoice.items count]; i++) {
          //
          //  NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
            
            for (int j = 0; j < [self.paidItemsArray count]; j++) {
                
            //    NSDictionary *paidItem = [self.paidItemsArray objectAtIndex:j];
                
                
            }
            
            
            
            
        }
        
        
        
        
        for (int i = 0; i < [self.paidItemsArray count]; i++) {
         //   NSDictionary *paidItem = [self.paidItemsArray objectAtIndex:i];
        }
        
        
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InvoiceView.markPaidItems" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
 
    
}
-(void)noPaymentSources{
    
    [self performSegueWithIdentifier:@"goPayCreditCard" sender:self];

    /*
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
     */
    
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
    self.splitDollarPercentBackView.hidden = YES;

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
    
    self.alphaBackView.hidden = NO;
    
    [UIView animateWithDuration:0.0 animations:^{
       
        CGRect frame = self.splitView.frame;
        frame.origin.y += 320;
        self.splitView.frame = frame;
    }];
    
    self.splitView.clipsToBounds = NO;

}

- (IBAction)showSplitViewDollar {
    
    [self.splitDollarMyPaymentText becomeFirstResponder];
    [self deselectAllItems];
    [self showFullTotal];
    
    self.alphaBackView.hidden = NO;
    
    [UIView animateWithDuration:0.0 animations:^{
        
        CGRect frame = self.splitViewDollar.frame;
        if (self.isIphone5) {
            frame.origin.y += 320;
        }else{
            frame.origin.y += 260;

        }
        self.splitViewDollar.frame = frame;
    }];
    
    self.splitViewDollar.clipsToBounds = NO;
    
}

- (IBAction)showSplitViewItem {
    

    self.alphaBackView.hidden = NO;
    
    [UIView animateWithDuration:0.0 animations:^{
        
        CGRect frame = self.itemSplitView.frame;
        frame.origin.y = 90;
        self.itemSplitView.frame = frame;
    }];
    
    self.itemSplitView.clipsToBounds = NO;
    
}

- (IBAction)cancelSplitAction {
    
    self.alphaBackView.hidden = YES;

    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame = self.splitView.frame;
        frame.origin.y -= 320;
        self.splitView.frame = frame;
    }];
    self.splitView.clipsToBounds = YES;

    
    
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
    
    double myDouble = self.splitMyDue;
    
    if (myDouble > 0) {
        self.totalLabel.text = [NSString stringWithFormat:@"My Total:  $%.2f", myDouble];
        [self showSplitButtons];

    }
    
 
    [self cancelSplitAction];
    
    [self payBillAction];
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
    
    double myItemPayemnt = self.splitItemMyDue;
    double itemPrice = [[item valueForKey:@"Value"] doubleValue];
    
    
    if (myItemPayemnt > itemPrice) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Over Payment" message:@"You cannot pay for more than the cost of this item." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        
        [self closeItemSplitAction];
        
        self.myItemizedTotal += myItemPayemnt;
        
        [self.myTableView reloadData];
        [self adjustLength];
        if (![self isAnyRowSelected]) {
            self.myItemizedTotal = 0.0;
            [self showFullTotal];
        }else{
            //some are still selected
            [self setItemizedTotalValue];
        }
        
        self.splitItemMyPaymentLabel.text = @"";
    }
    
    

}
- (IBAction)closeItemSplitAction {
    
    self.alphaBackView.hidden = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame = self.itemSplitView.frame;
        frame.origin.y -= 320;
        self.itemSplitView.frame = frame;
    }];
    
    self.itemSplitView.clipsToBounds = NO;
    
    
}

- (IBAction)splitPercentageAction {
    
    self.splitDollarPercentBackView.hidden = YES;

    [self showSplitView];
}
- (IBAction)splitDollarAction {
    
    self.splitDollarPercentBackView.hidden = YES;

    [self showSplitViewDollar];

}



-(void)showInvoiceHint{
    
    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showHint) userInfo:nil repeats:NO];
    
    if (myTimer) {
        
    }
    
    
}

-(void)showHint{
    
   

    [UIView animateWithDuration:1.0 animations:^{
        self.helpOverlay.view.alpha = 1.0;
    }];
    [self.helpOverlay startNow];
    
    
   
    
    
}

-(void)hideHint{
    
    
    [UIView animateWithDuration:1.0 animations:^{
        self.helpOverlay.view.alpha = 0.0;
    }];
}
- (IBAction)splitDollarSaveAction {
    double myPayment = [self.splitDollarMyPaymentText.text doubleValue];
    self.splitDollarMyPaymentText.text = [NSString stringWithFormat:@"%.2f", myPayment];
    
    if (myPayment > 0) {
        self.totalLabel.text = [NSString stringWithFormat:@"My Total:  $%.2f", myPayment];

    }
    [self splitDollarCancelAction];

    [self payBillAction];
    
}
- (IBAction)splitDollarCancelAction {
    
    self.alphaBackView.hidden = YES;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame = self.splitViewDollar.frame;
        if (self.isIphone5) {
            frame.origin.y -= 320;
        }else{
            frame.origin.y -= 260;
            
        }
        self.splitViewDollar.frame = frame;
    }];
    self.splitViewDollar.clipsToBounds = YES;
    
    
    
    [self.splitDollarMyPaymentText resignFirstResponder];
}
- (IBAction)splitMyPaymentEditChanged {
    

}

-(void)showHowManyView{
    
    
    [self.howManyText becomeFirstResponder];
    self.howManyView.hidden = NO;
    self.alphaBackView.hidden = NO;
    
    
    
    
   

    
    
}

-(IBAction)saveHowManyView{
    
    
    NSDictionary *dictionaryItem = [self.myInvoice.items objectAtIndex:self.howManyItemIndex];
    double myAmount = [self.howManyText.text doubleValue];
    double itemValue = [[dictionaryItem valueForKey:@"Value"] doubleValue];
    
    double itemAmount = [[dictionaryItem valueForKey:@"Amount"] doubleValue];
    
    if (myAmount > itemAmount) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many" message:@"You cannot pay for more items than are on the bill." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }else{
        
        NSDictionary *item = [self.myInvoice.items objectAtIndex:self.howManyItemIndex];
        
        double myItemPayemnt = myAmount * itemValue;
        
        
        if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"yes"]) {
            
            double value = [[item valueForKey:@"Value"] doubleValue];
            self.myItemizedTotal -= value;
            
        }else if ([[item valueForKey:@"IsPayingFor"] isEqualToString:@"maybe"]){
            
            double myValue = [[item valueForKey:@"AmountPayingFor"] doubleValue];
            self.myItemizedTotal -= myValue;
        }
        
        [item setValue:@"maybe" forKey:@"IsPayingFor"];
        [item setValue:[NSNumber numberWithDouble:myItemPayemnt] forKey:@"AmountPayingFor"];
        
        [self closeItemSplitAction];
        
        self.myItemizedTotal += myItemPayemnt;
        
        [self.myTableView reloadData];
        [self adjustLength];

        if (![self isAnyRowSelected]) {
            self.myItemizedTotal = 0.0;
            [self showFullTotal];
        }else{
            //some are still selected
            [self setItemizedTotalValue];
        }
        
        
        
        
        [self.howManyText resignFirstResponder];
        self.howManyView.hidden = YES;
        
        self.alphaBackView.hidden = YES;
        
        self.howManyText.text = @"";
        
    }
    
    

   

}

-(IBAction)cancelHowManyView{
    self.howManyText.text = @"";

    [self.howManyText resignFirstResponder];

    self.howManyView.hidden = YES;

    self.alphaBackView.hidden = YES;

}


//************************************************SHOWING PAID ITEMS



-(void)showPaidItems{
    
    
    if (!self.didShowPaidItems) {
        
        self.didShowPaidItems = YES;
        
        [self consolidatePartialPayments];
        
        NSMutableArray *myPaidItemsArray = [NSMutableArray arrayWithArray:self.paidItemsArray];
        
        NSLog(@"MyPaid Items: %@", myPaidItemsArray);
        
        
        for (int i = 0; i < [self.myInvoice.items count]; i++) {
            
            NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
            
            
            for (int j = 0; j < [myPaidItemsArray count]; j++) {
                
                NSDictionary *paidItem = [myPaidItemsArray objectAtIndex:j];
                
                
                if ([[paidItem valueForKey:@"ItemId"] intValue] == [[item valueForKey:@"Id"] intValue]) {
                    
                    //Item is at least partially paid for
                    
                    if ([[paidItem valueForKey:@"Percent"] doubleValue] == 1.0) {
                        
                        double paidItemAmount = [[paidItem valueForKey:@"Amount"] doubleValue];
                        double myItemAmount = [[item valueForKey:@"Amount"] doubleValue];
                        
                        if (paidItemAmount >= myItemAmount) {
                            [item setValue:@"yes" forKey:@"isPaidFor"];
                            
                            [myPaidItemsArray removeObjectAtIndex:j];
                            break;
                        }else{
                            [item setValue:@"maybe" forKey:@"isPaidFor"];
                            
                            [myPaidItemsArray removeObjectAtIndex:j];
                            break;
                        }
                        
                    }else{
                        //[item setValue:@"maybe" forKey:@"isPaidFor"];
                        
                    }
                    
                }
                
                [item setValue:@"ano" forKey:@"isPaidFor"];
                
            }
            
            
        }
        
        self.paidItemsArray = [NSMutableArray arrayWithArray:myPaidItemsArray];
        
        
        NSLog(@"PaidItemsArray: %@", self.paidItemsArray);
        
        //myPaidItems array still contains payments of partial Items, go through again
        
        for (int i = 0; i < [self.myInvoice.items count]; i++) {
            
            NSDictionary *item = [self.myInvoice.items objectAtIndex:i];
            
            
            if ([[item valueForKey:@"isPaidFor"] isEqualToString:@"ano"]) {
                
                
                for (int j = 0; j < [myPaidItemsArray count]; j++) {
                    
                    NSDictionary *paidItem = [myPaidItemsArray objectAtIndex:j];
                    
                    
                    if ([[paidItem valueForKey:@"ItemId"] intValue] == [[item valueForKey:@"Id"] intValue]) {
                        
                        //Item is at least partially paid for
                        
                        [item setValue:@"maybe" forKey:@"isPaidFor"];
                        
                        [myPaidItemsArray removeObjectAtIndex:j];
                        break;
                        
                        
                    }
                    
                    [item setValue:@"ano" forKey:@"isPaidFor"];
                    
                }
                
                
            }
            
            
            
            
        }
        
        
        
        
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"isPaidFor" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];
        self.myInvoice.items = [NSMutableArray arrayWithArray:[self.myInvoice.items sortedArrayUsingDescriptors:sortDescriptors]];
        
        
        
        [self.myTableView reloadData];
        
        
    }
    
    
}

-(void)consolidatePartialPayments{
    
    
    @try {
        
        for (int i = 0; i < [self.paidItemsArray count]; i++) {
            
            NSDictionary *paidItem = [self.paidItemsArray objectAtIndex:i];
            
            if (i != [self.paidItemsArray count] - 1) {
                
                
                for (int j = i+1; j < [self.paidItemsArray count]; j++) {
                    
                    NSDictionary *paidItemCheck = [self.paidItemsArray objectAtIndex:j];
                    
                    if ([[paidItem valueForKey:@"ItemId"] doubleValue] == [[paidItemCheck valueForKey:@"ItemId"] doubleValue]) {
                        
                        double initialPercent = [[paidItem valueForKey:@"Percent"] doubleValue];
                        double newPercent = [[paidItemCheck valueForKey:@"Percent"] doubleValue];
                        //NSLog(@"InitPercent: %f", initialPercent);
                        //NSLog(@"NewPercent: %f", newPercent);
                        
                        initialPercent += newPercent;
                        
                        [paidItem setValue:[NSNumber numberWithDouble:initialPercent] forKey:@"Percent"];
                        
                        [self.paidItemsArray removeObjectAtIndex:j];
                        j--;
                    }
                }
            }
        }
        //Consolidated, but Percent might be > 1.0
        
        for (int i = 0; i < [self.paidItemsArray count]; i++) {
            
            NSDictionary *paidItem = [self.paidItemsArray objectAtIndex:i];
            
            if ([[paidItem valueForKey:@"Percent"] doubleValue] > 1.0) {
                //uh oh
                double percent = [[paidItem valueForKey:@"Percent"] doubleValue];
                
                
                NSDictionary *newPaidItem = @{@"Amount": [NSNumber numberWithDouble:percent], @"ItemId":[paidItem valueForKey:@"ItemId"], @"PaidBy":[paidItem valueForKey:@"PaidBy"], @"PaidByAct":[paidItem valueForKey:@"PaidByAct"], @"Percent":[NSNumber numberWithDouble:1.0]};
                [self.paidItemsArray addObject:newPaidItem];
                /*
                while (percent > 1.0) {
                    
                    //reduce the count by 1, and add a new separate item
                    percent -= 1;
                    NSDictionary *newPaidItem = @{@"Amount": [paidItem valueForKey:@"Amount"], @"ItemId":[paidItem valueForKey:@"ItemId"], @"PaidBy":[paidItem valueForKey:@"PaidBy"], @"PaidByAct":[paidItem valueForKey:@"PaidByAct"], @"Percent":[NSNumber numberWithDouble:1.0]};
                    [self.paidItemsArray addObject:newPaidItem];
                    
                    
                }
                 */
                //Set the new percent to the remaining fraction
               // [paidItem setValue:[NSNumber numberWithDouble:percent] forKey:@"Amount"];
                //[paidItem setValue:[NSNumber numberWithInt:1] forKey:@"Amount"];
                
                [self.paidItemsArray removeObjectAtIndex:i];
                i--;

                
            }
        }
         
        
    }
    @catch (NSException *exception) {
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.splitDollarPercentBackView.hidden = YES;

}


- (IBAction)splitDollarPercentAction {
    
    if (self.splitDollarPercentBackView.hidden == YES) {
        self.splitDollarPercentBackView.hidden = NO;
    }else{
        self.splitDollarPercentBackView.hidden = YES;
    }
}
- (void)viewDidUnload {
    [self setSplitDollarPercentBackView:nil];
    [super viewDidUnload];
}
@end
