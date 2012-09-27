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

@interface AddCreditCard ()

-(void)showDoneButton;
-(NSString *)creditCardStatus;

@end

@implementation AddCreditCard
@synthesize creditDebitSegment;

-(void)viewDidAppear:(BOOL)animated{
    [self.creditCardNumberText becomeFirstResponder];

}

-(void)viewDidLoad{
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Add Card"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Add Card"];
		self.navigationItem.backBarButtonItem = temp;
        
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
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
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
        
        [self showDoneButton];
        
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
        [tmpButton setTitle:@"Done" forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tmpButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [tmpButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
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
        self.pickerView.hidden = YES;
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        [self endText];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.hideKeyboard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)changeExpiration:(UIButton *)sender{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        [self.pickerView removeFromSuperview];
        self.hideKeyboardView = nil;
        self.pickerView = nil;
        
        [self showDoneButton];
        
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
        
        if ([self.creditCardSecurityCodeText.text isEqualToString:@""] && [self.creditCardNumberText.text isEqualToString:@""]){
            
            return @"empty";
        }else{
            //At least one is entered, must all be entered
            if (![self.creditCardSecurityCodeText.text isEqualToString:@""]   && ![self.creditCardNumberText.text isEqualToString:@""]){
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
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
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
                    
                
<<<<<<< HEAD
                    NSString *creditDebitString = @"";
                    
                    if (self.creditDebitSegment.selectedSegmentIndex == 0) {
                        creditDebitString = @"CREDIT";
                    }else{
                        creditDebitString = @"DEBIT";
                    }
                    
                    NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
                    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [mainDelegate insertCreditCardWithNumber:self.creditCardNumberText.text andSecurityCode:self.creditCardSecurityCodeText.text andExpiration:expiration andPin:self.creditCardPinText.text andCreditDebit:creditDebitString];
                    
                    [self performSelector:@selector(popNow) withObject:nil afterDelay:0.5];
                    NSString *action = [NSString stringWithFormat:@"%@_CARD_ADD", creditDebitString];
                    [ArcClient trackEvent:action];
=======
                    [self goPin];
                    
                  
>>>>>>> nickprivate
                    
                    
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
        
        NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
        
        
        tmp.creditDebitString = creditDebitString;
        tmp.expiration = expiration;
        tmp.securityCode = self.creditCardSecurityCodeText.text;
        tmp.cardNumber = self.creditCardNumberText.text;
        tmp.fromRegister = NO;
        
        NSString *action = [NSString stringWithFormat:@"Add %@ Card", creditDebitString];
        [ArcClient trackEvent:action];
        
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



- (BOOL) luhnCheck:(NSString *)stringToTest {
    
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

@end
