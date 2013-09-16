//
//  AddCreditCard.m
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "AddCreditCard.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"
#import "SettingsView.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "NSString+CharArray.h"
#import "CreatePinView.h"

NSString *const VISA = @"V";
NSString *const MASTER_CARD = @"M";
NSString *const DISCOVER = @"D";
NSString *const DINERS_CLUB = @"N";
NSString *const AMERICAN_EXPRESS = @"A";

@interface AddCreditCard ()

-(void)showDoneButton;
-(NSString *)creditCardStatus;

@end

@implementation AddCreditCard
@synthesize creditDebitSegment;

-(void)viewDidAppear:(BOOL)animated{
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    //self.navigationController.navigationBarHidden = NO;
   // self.navigationController.navigationBar.clipsToBounds = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backspaceHit) name:@"backspaceNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
}
-(void)viewDidLoad{
    @try {
        
 
        
      
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
       
        
        //SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Add Card"];
        //self.navigationItem.titleView = navLabel;
        
        //SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Add Card"];
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
        
       
        
        self.addCardButton.tintColor = dutchDarkBlueColor;
        self.addCardButton.textColor = [UIColor whiteColor];
        self.addCardButton.text = @"Add";
        
        if (self.isIphone5) {
            self.addCardButton.text = @"Add Card";
        }
        
        [self.navigationController.navigationItem setHidesBackButton:YES];
        [self.navigationItem setHidesBackButton:YES];
        
        self.title = @"";
        
   
        
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;
        
        
        if (!isIos7) {
            int x = 20;
            if (self.isIphone5) {
                x = 30;
            }
            CGRect frame = self.bottomView.frame;
            frame.origin.y -= x;
            self.bottomView.frame = frame;
        }
        [self.myTableView reloadData];
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)goBackOne{
    [self.navigationController popViewControllerAnimated:YES];
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
        
        
        //[self.tableView setContentOffset:myPoint animated:YES];
        
        
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
       // self.tableView.frame = CGRectMake(0, 64, 320, viewHeight);
        
        
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
      //  self.tableView.frame = CGRectMake(0, 0, 320, viewHeight);
        
        
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
      //  self.tableView.frame = CGRectMake(0, 0, 320, viewHeight);
        
        
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
                    
                    NSString *creditDebitString = @"";
                    
                    if (self.creditDebitSegment.selectedSegmentIndex == 0) {
                        creditDebitString = @"CREDIT";
                    }else{
                        creditDebitString = @"DEBIT";
                    }
                    
                    //NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
                  //  ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                   // [mainDelegate insertCreditCardWithNumber:self.creditCardNumberText.text andSecurityCode:self.creditCardSecurityCodeText.text andExpiration:expiration andPin:self.creditCardPinText.text andCreditDebit:creditDebitString];
                    
                    //[self performSelector:@selector(popNow) withObject:nil afterDelay:0.5];
                    //NSString *action = [NSString stringWithFormat:@"%@_CARD_ADD", creditDebitString];

                    [self goPin];
                    
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        
        
        UITableViewCell *cell;

        
        if (indexPath.row == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"numberCell"];
            
            SteelfishTextFieldCreditCardiOS6 *numberText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:1];
            self.creditCardNumberText = numberText;
            self.creditCardNumberText.placeholder = @"1234 5678 9102 3456";
            self.creditCardNumberText.delegate = self;
            [self.creditCardNumberText setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            [self.creditCardNumberText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];

        }else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"expCell"];
            
            SteelfishTextFieldCreditCardiOS6 *expText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:1];
            self.expirationText = expText;
            self.expirationText.placeholder = @"MM/YY";
            
            SteelfishTextFieldCreditCardiOS6 *pinText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:2];
            self.creditCardSecurityCodeText = pinText;
            self.creditCardSecurityCodeText.placeholder = @"CVV";
            
            self.creditCardSecurityCodeText.delegate = self;
            self.expirationText.delegate = self;
            
            [self.creditCardSecurityCodeText setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.expirationText setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            [self.creditCardSecurityCodeText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            [self.expirationText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];

            
            
        }
        
        
  
        
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}





- (void)viewDidUnload {
    [self setAddCardButton:nil];
    [super viewDidUnload];
}
@end
