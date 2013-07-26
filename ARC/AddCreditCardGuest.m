//
//  AddCreditCardGuest.m
//  ARC
//
//  Created by Nick Wroblewski on 4/21/13.
//
//


#import "AddCreditCardGuest.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"
#import "SettingsView.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "NSString+CharArray.h"
#import "CreatePinView.h"
#import "ArcUtility.h"
#import "GuestCreateAccount.h"

@interface AddCreditCardGuest ()

-(void)showDoneButton;
-(NSString *)creditCardStatus;

@end

@implementation AddCreditCardGuest
@synthesize creditDebitSegment;

-(void)viewDidAppear:(BOOL)animated{
    
    
    self.totalPaymentLabel.text = [NSString stringWithFormat:@"Total Payment: $%.2f", self.myInvoice.basePaymentAmount + self.myInvoice.gratuity];

    if (!self.selectCardIo) {
        [self.creditCardNumberText becomeFirstResponder];
    }else{
        // [self showDoneButton];
    }
    
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:@"createPaymentNotification" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backspaceHit) name:@"backspaceNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
}
-(void)viewDidLoad{
    @try {
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
        
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
        
        
        //CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Add Card"];
        //self.navigationItem.titleView = navLabel;
        
        //CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Add Card"];
		//self.navigationItem.backBarButtonItem = temp;
        
        [rSkybox addEventToSession:@"viewAddCreditCardScreen"];
        
        self.creditCardNumberText.text = @"";
        self.creditCardPinText.text = @"";
        self.creditCardSecurityCodeText.text = @"";
        self.expirationMonth = @"01";
        self.expirationYear = @"2012";
        
        self.months = @[@"01 - Jan", @"02 - Feb", @"03 - March", @"04 - April", @"05 - May", @"06 - June", @"07 - July", @"08 - Aug", @"09 - Sept", @"10 - Oct", @"11 - Nov", @"12 - Dec"];
        
        self.years = @[@"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", @"2023", @"2024", @"2025", @"2026", @"2027", @"2028", @"2029", @"2030"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
        self.creditCardNumberText.delegate = self;
        self.creditCardSecurityCodeText.delegate = self;
        self.expirationText.delegate = self;
        
        [self.creditCardNumberText setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.creditCardSecurityCodeText setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.expirationText setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        [self.navigationController.navigationItem setHidesBackButton:YES];
        [self.navigationItem setHidesBackButton:YES];
        
        self.title = @"";
        
        
        UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        backView1.backgroundColor = [UIColor blackColor];
        [self.navigationController.navigationBar addSubview:backView1];
        
        
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        backView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        backView.backgroundColor = dutchTopNavColor;
        
        [self.navigationController.navigationBar addSubview:backView];
        
        
        
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        lineView.layer.shadowOffset = CGSizeMake(0, 1);
        lineView.layer.shadowRadius = 1;
        lineView.layer.shadowOpacity = 0.2;
        lineView.backgroundColor = dutchTopLineColor;

        
        [self.navigationController.navigationBar addSubview:lineView];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setImage:[UIImage imageNamed:@"backarrow.png"] forState:UIControlStateNormal];
        tmpButton.frame = CGRectMake(0, 0, 44, 44);
        [tmpButton addTarget:self action:@selector(goBackOne) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:tmpButton];
        
        LucidaBoldLabel *tmpLabel = [[LucidaBoldLabel alloc] initWithFrame:CGRectMake(0, 2, 320, 46) andSize:20];
        tmpLabel.text = @"Payment Info";
        tmpLabel.textAlignment = UITextAlignmentCenter;
        [self.navigationController.navigationBar addSubview:tmpLabel];
        
        
        self.loadingTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        self.loadingTopView.backgroundColor = [UIColor blackColor];
        self.loadingTopView.alpha = 0.2;
        self.loadingTopView.hidden = YES;
        [self.navigationController.navigationBar addSubview:self.loadingTopView];
        
        UIImageView *imageBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 560)];
        imageBackView.image = [UIImage imageNamed:@"newBackground.png"];
        
        self.tableView.backgroundView = imageBackView;
        
        
        if (self.view.frame.size.height < 480) {
            self.addCardButton = [[NVUIGradientButton alloc] initWithFrame:CGRectMake(252, 6, 66, 33)];
            [self.addCardButton addTarget:self action:@selector(addCard) forControlEvents:UIControlEventTouchUpInside];
            
            self.addCardButton.text = @"Pay";
            [self.navigationController.navigationBar addSubview:self.addCardButton];
            
        }else{
            self.addCardButton.text = @"Confirm Payment";
            
        }
        
        
        
        self.addCardButton.tintColor = [UIColor colorWithRed:17.0/255.0 green:196.0/255.0 blue:29.0/215.0 alpha:1];
        self.addCardButton.textColor = [UIColor whiteColor];
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)goBackOne{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)editBegin:(id)sender {
    @try {
        
        UITextField *selectedField = (UITextField *)sender;
        
        CGPoint myPoint;
        
        if (selectedField.tag == 10) {
            //CC #
            myPoint = CGPointMake(0, 0);
            
        }else if (selectedField.tag == 11){
            //security code
            
            myPoint = CGPointMake(0, 0);
            
        }else if (selectedField.tag == 12){
            //pin
            
            int y = 174;
            if (self.isIphone5) {
                y = 140;
            }
            myPoint = CGPointMake(0, y);
            
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        
        [self.tableView setContentOffset:myPoint animated:YES];
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.editBegin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)editEnd:(id)sender {
    @try {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        int viewHeight = 416;
        if (self.isIphone5) {
            viewHeight = 503;
        }
        self.tableView.frame = CGRectMake(0, 64, 320, viewHeight);
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.editEnd" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}



-(void)keyboardWillShow:(id)sender{
    @try {
        
        //[self showDoneButton];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.keyboardWillShow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyHeight = 158;
        if (self.isIphone5) {
            keyHeight = 245;
        }
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyHeight, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor clearColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.cornerRadius = 3.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        [self.hideKeyboardView addSubview:tmpView];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpButton.frame = CGRectMake(8, 5, 69, 35);
        [tmpButton setTitle:@"Add" forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tmpButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [tmpButton addTarget:self action:@selector(addCard) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:tmpButton];
        [self.view.superview addSubview:self.hideKeyboardView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        int viewHeight = 200;
        if (self.isIphone5) {
            viewHeight = 287;
        }
        self.tableView.frame = CGRectMake(0, 0, 320, viewHeight);
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}
-(void)keyboardWillHide:(id)sender{
    @try {
        
        //[self.hideKeyboardView removeFromSuperview];
        //self.hideKeyboardView = nil;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.keyboardWillHide" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)hideKeyboard{
    @try {
        
        [self.creditCardPinText resignFirstResponder];
        [self.creditCardNumberText resignFirstResponder];
        [self.creditCardSecurityCodeText resignFirstResponder];
        [self.expirationText resignFirstResponder];
        
        self.pickerView.hidden = YES;
        //[self.hideKeyboardView removeFromSuperview];
        //self.hideKeyboardView = nil;
        [self endText];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.hideKeyboard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)changeExpiration:(UIButton *)sender{
    @try {
        
        //[self.hideKeyboardView removeFromSuperview];
        //[self.pickerView removeFromSuperview];
        //self.hideKeyboardView = nil;
        self.pickerView = nil;
        
        // [self showDoneButton];
        
        if (sender.tag == 22) {
            //month
            self.isExpirationMonth = YES;
        }else{
            //year
            self.isExpirationMonth = NO;
        }
        
        [self.creditCardPinText resignFirstResponder];
        [self.creditCardNumberText resignFirstResponder];
        [self.creditCardSecurityCodeText resignFirstResponder];
        [self.expirationText resignFirstResponder];
        
        
        int pickerY = 200;
        if (self.isIphone5) {
            pickerY = 287;
        }
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, pickerY, 320, 315)];
        self.pickerView.delegate = self;
        self.pickerView.showsSelectionIndicator = YES;
        
        [self.view.superview addSubview:self.pickerView];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.changeExpiration" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    @try {
        
        if (self.isExpirationMonth) {
            self.creditCardExpirationMonthLabel.text = [self.months objectAtIndex:row];
            self.expirationMonth = [[self.months objectAtIndex:row] substringToIndex:2];
        }else{
            self.creditCardExpirationYearLabel.text = [self.years objectAtIndex:row];
            self.expirationYear = [NSString stringWithString:[self.years objectAtIndex:row]];
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    @try {
        
        NSUInteger numRows;
        
        if (self.isExpirationMonth) {
            numRows = 12;
        }else {
            numRows = 19;
        }
        
        return numRows;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    @try {
        
        if (self.isExpirationMonth) {
            return [self.months objectAtIndex:row];
        }else{
            return [self.years objectAtIndex:row];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    @try {
        
        int sectionWidth = 300;
        
        return sectionWidth;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(NSString *)creditCardStatus{
    @try {
        
        if ([self.creditCardSecurityCodeText.text isEqualToString:@""] && [self.creditCardNumberText.text isEqualToString:@""] && [self.expirationText.text isEqualToString:@""]){
            
            return @"empty";
        }else{
            //At least one is entered, must all be entered
            if (![self.creditCardSecurityCodeText.text isEqualToString:@""] && ![self.creditCardNumberText.text isEqualToString:@""] && ([self.expirationText.text length] == 5)){
                return @"valid";
            }else{
                return @"invalid";
            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.creditCardStatus" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)endText{
    @try {
        
        //[self.hideKeyboardView removeFromSuperview];
        //self.hideKeyboardView = nil;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.1];
        
        int viewHeight = 416;
        if (self.isIphone5) {
            viewHeight = 503;
        }
        self.tableView.frame = CGRectMake(0, 0, 320, viewHeight);
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.endText" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}


-(void)addCard{
    
    
    @try {
        
        
        if (self.creditDebitSegment.selectedSegmentIndex == -1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credit or Debit?" message:@"Please select whether this is a credit or debit card." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }else{
            
            if ([[self creditCardStatus] isEqualToString:@"valid"]) {
                
                
                if ([self luhnCheck:self.creditCardNumberText.text]) {
                    
                    [self createPayment];
                    
                }else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Card" message:@"Please enter a valid card number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    
                }
                
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Please fill out all credit card information first" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.addCard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
     
}


-(void)createPayment{
    
    
    @try{
        
        
        
        //[self.activity startAnimating];
        self.loadingViewController.displayText.text = @"Sending Payment...";
        [self.loadingViewController startSpin];
        self.loadingTopView.hidden = NO;
        self.loadingTopView.alpha = 0.2;

        
        NSString *amountString = [NSString stringWithFormat:@"%.2f", self.myInvoice.basePaymentAmount];
        NSLog(@"AmountString: %@", amountString);
        self.myInvoice.basePaymentAmount = [amountString doubleValue];
        
        NSString *gratString = [NSString stringWithFormat:@"%.2f", self.myInvoice.gratuity];
        NSLog(@"Grat: %@", gratString);
        self.myInvoice.gratuity = [gratString doubleValue];
        
        NSLog(@"Grat: %f", self.myInvoice.gratuity);
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        NSNumber *invoiceAmount = [NSNumber numberWithDouble:[self.myInvoice amountDue]];
        [ tempDictionary setObject:invoiceAmount forKey:@"InvoiceAmount"];
        
        NSNumber *amount = [NSNumber numberWithDouble:[self.myInvoice basePaymentAmount]];
        
        [ tempDictionary setObject:amount forKey:@"Amount"];
        
        [ tempDictionary setObject:@"" forKey:@"AuthenticationToken"];
        
        NSString *ccNumber = [self.creditCardNumberText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        [ tempDictionary setObject:ccNumber forKey:@"FundSourceAccount"];
        
        NSNumber *grat = [NSNumber numberWithDouble:[self.myInvoice gratuity]];
        [tempDictionary setObject:grat forKey:@"Gratuity"];
        
        NSLog(@"Grat: %f", self.myInvoice.gratuity);
        NSLog(@"Grat: %f", [grat doubleValue]);

        
        
        [ tempDictionary setObject:self.transactionNotes forKey:@"Notes"];
        
        NSString *guestId = @"";

        if (self.isGuest) {
            guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"guestId"];
        }else{
            guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];

        }

        
        NSLog(@"GuestId: %@", guestId);
        
        [ tempDictionary setObject:guestId forKey:@"CustomerId"];
        
        [ tempDictionary setObject:@"" forKey:@"Tag"];
        
        [ tempDictionary setObject:self.expirationText.text forKey:@"Expiration"];
        
        NSString *invoiceIdString = [NSString stringWithFormat:@"%d", self.myInvoice.invoiceId];
        [ tempDictionary setObject:invoiceIdString forKey:@"InvoiceId"];
        NSString *merchantIdString = [NSString stringWithFormat:@"%d", self.myInvoice.merchantId];
        [ tempDictionary setObject:merchantIdString forKey:@"MerchantId"];
        
        [ tempDictionary setObject:self.creditCardSecurityCodeText.text forKey:@"Pin"];
        
        [ tempDictionary setObject:@"CREDIT" forKey:@"Type"];
       
        
        NSString *cardType = [ArcUtility getCardTypeForNumber:ccNumber];
        
        [ tempDictionary setObject:cardType forKey:@"CardType"];
        
        //For Metrics
        [tempDictionary setObject:self.myInvoice.splitType forKey:@"SplitType"];
        [tempDictionary setObject:self.myInvoice.splitPercent forKey:@"PercentEntry"];
        [tempDictionary setObject:self.myInvoice.tipEntry forKey:@"TipEntry"];
        
        
        if (self.mySplitPercent > 0.0) {
            self.mySplitPercent = self.mySplitPercent / 100.0;
            [tempDictionary setValue:[NSNumber numberWithDouble:self.mySplitPercent] forKey:@"PercentPaid"];
        }
        
        if ([self.myItemsArray count] > 0) {
            [tempDictionary setValue:self.myItemsArray forKey:@"Items"];
        }
        
        
        loginDict = tempDictionary;
        self.addCardButton.enabled = NO;
        //self.navigationItem.hidesBackButton = YES;
        ArcClient *client = [[ArcClient alloc] init];
        
        self.creditCardNumberText.enabled = NO;
        self.creditCardSecurityCodeText.enabled = NO;
        self.expirationText.enabled = NO;
        
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(createPaymentTimer) userInfo:nil repeats:NO];
        
        [client createPayment:loginDict];
        
    }
    @catch (NSException *e) {
        //self.errorLabel.text = @"*Error retreiving credit card.";
        
        NSLog(@"E: %@", e);
        
        [rSkybox sendClientLog:@"AddCreditCardGuest.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)paymentSuccess{
    
    double totalPayment = [self.myInvoice basePaymentAmount] + [self.myInvoice gratuity];
    NSString *payAmount = [NSString stringWithFormat:@"%.2f", totalPayment];
    
    NSString *payString = @"";
    NSString *title = @"";
    if([self.myInvoice paidInFull]) {
        title = @"Paid in Full";
        payString = [NSString stringWithFormat:@"Please confirm payment with server before leaving the restaurant."];
    } else {
        title = @"Success!";
        payString = [NSString stringWithFormat:@"Congratulations, your payment of $%@ was successfully processed!", payAmount];
    }
            
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:payString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];

    
    if (self.isGuest) {
        [self performSegueWithIdentifier:@"saveInfo" sender:nil];

    }else{
        
        CreatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"createPin"];
        
        NSString *creditDebitString = @"Credit";
        
        tmp.creditDebitString = creditDebitString;
        tmp.expiration = self.expirationText.text;
        tmp.securityCode = self.creditCardSecurityCodeText.text;
        tmp.cardNumber = [self.creditCardNumberText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        tmp.isLoggedInUser = YES;
        
        // determine what type of credit card this is
        
        // NSString *action = [NSString stringWithFormat:@"%@_CARD_ADD", creditDebitString];
        //[ArcClient trackEvent:action];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:tmp animated:NO];        

    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"saveInfo"]) {
            
            GuestCreateAccount *next = [segue destinationViewController];
            next.myInvoice = self.myInvoice;
            next.ccNumber = self.creditCardNumberText.text;
            next.ccSecurityCode = self.creditCardSecurityCodeText.text;
            next.ccExpiration = self.expirationText.text;
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GuestCreateAccount.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)paymentComplete:(NSNotification *)notification{
    
    
    @try {
        
        self.creditCardNumberText.enabled = YES;
        self.creditCardSecurityCodeText.enabled = YES;
        self.expirationText.enabled = YES;
        
        
        //self.navigationItem.hidesBackButton = NO;
        
        // NSLog(@"Notification: %@", notification);
        
        [self.myTimer invalidate];
        
        //[self hideHighVolumeOverlay];
        
        BOOL editCardOption = NO;
        BOOL duplicateTransaction = NO;
        BOOL displayAlert = NO;
        BOOL networkError = NO;
        
        self.addCardButton.enabled = YES;
        // self.navigationItem.hidesBackButton = NO;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        //[self.activity stopAnimating];
        [self.loadingViewController stopSpin];
        self.loadingTopView.hidden = YES;
        
        NSString *errorMsg= @"";
        if ([status isEqualToString:@"success"]) {
            [rSkybox addEventToSession:@"creditCardPaymentCompleteSuccess"];
            
            //success
            // self.errorLabel.text = @"";
            BOOL paidInFull = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"InvoicePaid"] boolValue];
            // self.paymentPointsReceived =  [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"Points"] intValue];
            
            if(paidInFull) [self.myInvoice setPaidInFull:paidInFull];
            int paymentId = [[[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] valueForKey:@"PaymentId"] intValue];
            [self.myInvoice setPaymentId:paymentId];
            
            
            [self paymentSuccess];
        
            
        } else if([status isEqualToString:@"error"]){
            [rSkybox addEventToSession:@"creditCardPaymentCompleteFail"];
            
            
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == CANNOT_GET_PAYMENT_AUTHORIZATION) {
                //errorMsg = @"Credit card not approved.";
                editCardOption = YES;
            } else if(errorCode == FAILED_TO_VALIDATE_CARD) {
                // TODO need explanation from Jim to put proper error msg
                //errorMsg = @"Failed to validate credit card";
                editCardOption = YES;
            } else if (errorCode == FIELD_FORMAT_ERROR){
               // errorMsg = @"Invalid Credit Card Field Format";
                editCardOption = YES;
            }else if(errorCode == INVALID_ACCOUNT_NUMBER) {
                // TODO need explanation from Jim to put proper error msg
               // errorMsg = @"Invalid credit/debit card number";
                editCardOption = YES;
            } else if(errorCode == MERCHANT_CANNOT_ACCEPT_PAYMENT_TYPE) {
                // TODO put exact type of credit card not accepted in msg -- Visa, MasterCard, etc.
                errorMsg = @"Merchant does not accept credit/debit card";
            } else if(errorCode == OVER_PAID) {
                errorMsg = @"Over payment. Please check invoice and try again.";
            } else if(errorCode == INVALID_AMOUNT) {
                errorMsg = @"Invalid amount. Please re-enter payment and try again.";
            } else if(errorCode == INVALID_EXPIRATION_DATE) {
                //errorMsg = @"Invalid expiration date.";
                editCardOption = YES;
            }  else if (errorCode == UNKOWN_ISIS_ERROR){
                //editCardOption = YES;
                errorMsg = @"Arc Error, Try Again.";
            }else if (errorCode == PAYMENT_MAYBE_PROCESSED){
                errorMsg = @"This payment may have already processed.  To be sure, please wait 30 seconds and then try again.";
                displayAlert = YES;
            }else if(errorCode == DUPLICATE_TRANSACTION){
                duplicateTransaction = YES;
            }else if (errorCode == CHECK_IS_LOCKED){
                errorMsg = @"This check is currently locked.  Please try again in a few minutes.";
                displayAlert = YES;
            }else if (errorCode == CARD_ALREADY_PROCESSED){
                errorMsg = @"This card has already been used for payment on this invoice.  A card may only be used once per invoice.  Please try again with a different card.";
                displayAlert = YES;
            }else if (errorCode == NO_AUTHORIZATION_PROVIDED){
                errorMsg = @"Invalid Authorization, please try again.";
                displayAlert = YES;
            }else if (errorCode == NETWORK_ERROR){
                
                networkError = YES;
                errorMsg = @"Arc is having problems connecting to the internet.  Please check your connection and try again.  Thank you!";
                
            }else if (errorCode == NETWORK_ERROR_CONFIRM_PAYMENT){
                
                networkError = YES;
                errorMsg = @"Arc experienced a problem with your internet connection while trying to confirm your payment.  Please check with your server to see if your payment was accepted.";
                
            }
            else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if (displayAlert) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Warning" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else{
            
            if ([errorMsg length] > 0) {
                if (networkError) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet  Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Failed" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
            }
            
            
            // self.errorLabel.text = errorMsg;
            
        }
        
        if (editCardOption) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your payment may have failed due to invalid credit card information.  Would you like to view/edit the card you tried to make this payment with?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"View/Edit", nil];
            [alert show];
        }else if (duplicateTransaction){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Transaction" message:@"Arc has recorded a similar transaction that happened recently.  To avoid a duplicate transaction, please wait 30 seconds and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCardGuest.paymentComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    

}






-(void)createPaymentTimer{
    
    
    [self showHighVolumeOverlay];
}


-(void)showHighVolumeOverlay{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingViewController.displayText.text = @"Arc is experiencing high volume, or a weak internet connection, please be patient...";
        self.loadingViewController.displayText.font = [UIFont fontWithName:[self.loadingViewController.displayText.font fontName] size:16];
        
        self.loadingViewController.displayText.numberOfLines = 3;
        CGRect frame = self.loadingViewController.mainBackView.frame;
        frame.origin.y -= 20;
        frame.size.height += 20;
        frame.origin.x = 10;
        frame.size.width = 300;
        self.loadingViewController.mainBackView.frame = frame;
        
        CGRect frame2 = self.loadingViewController.displayText.frame;
        frame2.origin.y -= 20;
        frame2.size.height += 20;
        frame2.origin.x = 10;
        frame2.size.width = 300;
        self.loadingViewController.displayText.frame = frame2;
        
    }];
}



-(void)goPin{
    
    @try {
        
        CreatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"createPin"];
        
        NSString *creditDebitString = @"Credit";
        
        if (self.creditDebitSegment.selectedSegmentIndex == 1) {
            creditDebitString = @"Debit";
        }
        
        //NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
        NSString *expiration = self.expirationText.text;
        
        tmp.creditDebitString = creditDebitString;
        tmp.expiration = expiration;
        tmp.securityCode = self.creditCardSecurityCodeText.text;
        tmp.cardNumber = [self.creditCardNumberText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        tmp.fromRegister = NO;
        
        // determine what type of credit card this is
        
        // NSString *action = [NSString stringWithFormat:@"%@_CARD_ADD", creditDebitString];
        //[ArcClient trackEvent:action];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:tmp animated:NO];
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.addCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)popNow{
    @try {
        
        SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
        tmp.creditCardAdded = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.popNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (NSString *) cardType:(NSString *)stringToTest {
    return @"";
}




- (BOOL) luhnCheck:(NSString *)stringToTest {
    
    stringToTest = [stringToTest stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableArray *stringAsChars = [stringToTest toCharArray];
    
	BOOL isOdd = YES;
	int oddSum = 0;
	int evenSum = 0;
    
	for (int i = [stringToTest length] - 1; i >= 0; i--) {
        
		int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
        
		if (isOdd)
			oddSum += digit;
		else
			evenSum += digit/5 + (2*digit) % 10;
        
		isOdd = !isOdd;
	}
    
	return ((oddSum + evenSum) % 10 == 0);
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    @try {
        self.isDelete = NO;
        
        
        if (textField == self.creditCardNumberText){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                return TRUE;
            }
            
            if ([self.creditCardNumberText.text length] >= 20) {
                
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }else if (textField == self.expirationText){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                
                
                return TRUE;
            }
            if ([self.expirationText.text length] >= 5) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }else if (textField == self.creditCardSecurityCodeText){
            
            if ([string isEqualToString:@""]) {
                
                
                return TRUE;
            }
            
            if ([self.creditCardSecurityCodeText.text length] >= 4) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }
        return TRUE;
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"AddCreditCard.shouldChangeCharacters" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)valueChanged:(id)sender{
    
    @try {
        if (self.isIos6) {
            if (sender == self.expirationText) {
                
                [self formatExpiration];
            }else if (sender == self.creditCardNumberText){
                [self formatCreditCard:NO];
            }else{
                
            }
        }else{
            
            if (self.shouldIgnoreValueChanged) {
                self.shouldIgnoreValueChanged = NO;
            }else{
                if (sender == self.creditCardNumberText){
                    [self formatCreditCard:NO];
                }
            }
            
            if (self.shouldIgnoreValueChangedExpiration) {
                self.shouldIgnoreValueChangedExpiration = NO;
            }else{
                if (sender == self.expirationText) {
                    
                    [self formatExpiration];
                }
            }
            
            
            
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"AddCreditCard.valueChanged" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
}

-(void)formatCreditCard:(BOOL)final{
    
    @try {
        if (!self.isDelete) {
            
            
            NSString *cardNumber = self.creditCardNumberText.text;
            BOOL isAmex = NO;
            
            if ([cardNumber length] > 1) {
                if ([[cardNumber substringToIndex:2] isEqualToString:@"34"] || [[cardNumber substringToIndex:2] isEqualToString:@"37"]) {
                    isAmex = YES;
                }
            }
            
            if (isAmex) {
                
                
                if (final) {
                    
                    cardNumber = [NSString stringWithFormat:@"%@ %@ %@", [cardNumber substringToIndex:4], [cardNumber substringWithRange:NSMakeRange(4, 6)], [cardNumber substringFromIndex:10]];
                    
                }else{
                    if ([cardNumber length] == 4) {
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 11){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 17){
                        [self.expirationText becomeFirstResponder];
                    }else if ([cardNumber length] == 5) {
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:4], [cardNumber substringFromIndex:4]];
                    }else if ([cardNumber length] == 12){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:11], [cardNumber substringFromIndex:11]];
                        
                    }
                }
                
                
                
            }else{
                
                if (final) {
                    
                    cardNumber = [NSString stringWithFormat:@"%@ %@ %@ %@", [cardNumber substringToIndex:4], [cardNumber substringWithRange:NSMakeRange(4, 4)], [cardNumber substringWithRange:NSMakeRange(8, 4)], [cardNumber substringFromIndex:12]];
                }else{
                    if ([cardNumber length] == 4) {
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 9){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 14){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 19){
                        [self.expirationText becomeFirstResponder];
                    }else if ([cardNumber length] == 5) {
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:4], [cardNumber substringFromIndex:4]];
                    }else if ([cardNumber length] == 10){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:9], [cardNumber substringFromIndex:9]];
                        
                    }else if ([cardNumber length] == 15){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:14], [cardNumber substringFromIndex:14]];
                    }
                }
                
            }
            
            
            
            if (!self.isIos6) {
                self.shouldIgnoreValueChanged = YES;
            }
            self.creditCardNumberText.text = cardNumber;
        }
    }
    
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"AddCreditCard.formatCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}

-(void)formatExpiration{
    
    @try {
        NSString *expiration = self.expirationText.text;
        
        if (self.isDelete) {
            
            if ([expiration length] == 2) {
                expiration = [expiration substringToIndex:1];
            }
            
        }else{
            if ([expiration length] == 5) {
                [self.creditCardSecurityCodeText becomeFirstResponder];
            }
            
            if ([expiration length] == 1) {
                if (![expiration isEqualToString:@"1"] && ![expiration isEqualToString:@"0"]) {
                    expiration = [NSString stringWithFormat:@"0%@/", expiration];
                }
            }else if ([expiration length] == 2){
                expiration = [expiration stringByAppendingString:@"/"];
            }
        }
        
        if (!self.isIos6) {
            self.shouldIgnoreValueChangedExpiration = YES;
        }
        
        self.expirationText.text = expiration;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"AddCreditCard.formatException" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)backspaceHit{
    
    @try {
        if (([self.creditCardSecurityCodeText.text length] == 0) && [self.creditCardSecurityCodeText isFirstResponder]) {
            [self.expirationText becomeFirstResponder];
        }else if (([self.expirationText.text length] == 0) && [self.expirationText isFirstResponder]) {
            [self.creditCardNumberText becomeFirstResponder];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"AddCreditCard.backSpaceHit" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}


-(void)scanCard{
    
    self.selectCardIo = YES;
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
    
    @try {
        
        [ArcClient trackEvent:@"CARD.IO_SCAN_ATTEMPTED"];
        
        
        CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
        scanViewController.collectCVV = YES;
        scanViewController.collectExpiry = YES;
        
        //54bb17d6425a400194570cefaeaf5219
        scanViewController.appToken = @"54bb17d6425a400194570cefaeaf5219"; // get your app token from the card.io website
        [self presentModalViewController:scanViewController animated:YES];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.scanCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    
    @try {
        
        [ArcClient trackEvent:@"CARD.IO_SCAN_CANCELED"];
        
        [scanViewController dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.userDidCancelPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    
    @try {
        
        [ArcClient trackEvent:@"CARD.IO_SCAN_SUCCESSFUL"];
        
        self.creditCardNumberText.text = info.cardNumber;
        NSString *expirationYearString = [NSString stringWithFormat:@"%i", info.expiryYear];
        self.expirationText.text = [NSString stringWithFormat:@"%02i/%@", info.expiryMonth, [expirationYearString substringFromIndex:2]];
        self.creditCardSecurityCodeText.text = info.cvv;
        [self formatCreditCard:YES];
        
        
        [scanViewController dismissModalViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.userDidProvideCreditCardInfo" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
    
}

- (void)viewDidUnload {
    [self setAddCardButton:nil];
    [self setTotalPaymentLabel:nil];
    [super viewDidUnload];
}
@end
