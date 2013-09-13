//
//  EditCreditCard.m
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "EditCreditCard.h"
#import "CreditCard.h"
#import "ArcAppDelegate.h"
#import "SettingsView.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "ValidatePinView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+CharArray.h"
#import "CreatePinView.h"
#import "CreditCardPayment.h"
#import "ViewCreditCards.h"

@interface EditCreditCard ()

@end

@implementation EditCreditCard

-(void)editPin{
    
    //self.navigationController.navigationBarHidden = YES;
    CreatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"createPin"];
    
    tmp.isEditPin = YES;
    
    [self.navigationController pushViewController:tmp animated:NO];

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    @try {
        [self.navigationController.navigationItem setHidesBackButton:YES];
        [self.navigationItem setHidesBackButton:YES];
        
       // self.navigationController.navigationBarHidden = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backspaceHit) name:@"backspaceNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
        if (self.isFromPayment) {
            self.deleteCardButton.hidden = YES;
        }else{
            self.deleteCardButton.hidden = NO;
        }
        if (self.pinDidChange) {
            self.pinDidChange = NO;
            self.oldPin = self.newPin;
            
        }
        
        if ([self.creditCardSample rangeOfString:@"Credit Card"].location == NSNotFound && [self.creditCardSample rangeOfString:@"Debit Card"].location == NSNotFound) {
            
            self.cardNameText.text = [self.creditCardSample substringWithRange:NSMakeRange(0, [self.creditCardSample length] - 10)];
                                     
                                      
        }
    }
    @catch (NSException *exception) {
        
    }
  

}
-(void)viewDidAppear:(BOOL)animated{
    
    if (self.cancelAuth) {
    
        [self.navigationController popViewControllerAnimated:NO];
        
    }else if (self.cancelAuthLock){
        
        int index = [[self.navigationController viewControllers] count] - 2;
        ViewCreditCards *tmp = [[self.navigationController viewControllers] objectAtIndex:index];
        tmp.showCardLocked = YES;
        
        [self.navigationController popViewControllerAnimated:NO];
        
    }else if (self.deleteCardNow){
        
        int index = [[self.navigationController viewControllers] count] - 2;
        ViewCreditCards *tmp = [[self.navigationController viewControllers] objectAtIndex:index];
        tmp.deleteCardNow = YES;
        
        [self.navigationController popViewControllerAnimated:NO];
        
    }else{
        if (!self.didAuth){
    
            ValidatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"validatePin"];
            tmp.cardNumber = self.creditCardNumber;
            tmp.securityCode = self.creditCardSecurityCode;
            
            [self.navigationController pushViewController:tmp animated:NO];
        }else{
            [self loadTable];
        }
    }
    
}
-(void)viewDidLoad{
    @try {
        self.cardNameText.delegate = self;
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
        self.editPinButton.text = @"Edit PIN";
        
        self.saveChangesButton.text = @"Save Changes";
        self.saveChangesButton.tintColor = dutchDarkBlueColor;
        self.saveChangesButton.textColor = [UIColor whiteColor];
        
        self.deleteButton.text = @"Delete Card";
        self.deleteButton.textColor = [UIColor whiteColor];
        self.deleteButton.tintColor = [UIColor redColor];
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
       
        self.title = @"";
        
        
        //SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Edit Card"];
        //self.navigationItem.titleView = navLabel;
        
        //SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Edit Card"];
		//self.navigationItem.backBarButtonItem = temp;
        
        //ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        //NSArray *cards = [mainDelegate getCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
        
        

        self.expirationMonth = @"01";
        self.expirationYear = @"2012";
        
        self.months = @[@"01 - Jan", @"02 - Feb", @"03 - March", @"04 - April", @"05 - May", @"06 - June", @"07 - July", @"08 - Aug", @"09 - Sept", @"10 - Oct", @"11 - Nov", @"12 - Dec"];
        
        self.years = @[@"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", @"2023", @"2024", @"2025", @"2026", @"2027", @"2028", @"2029", @"2030"];
        
   
        
        
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
        
        
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;
        
        [self.myTableView reloadData];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)goBackOne{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)deleteCardAction {
    @try {
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
        
        [self.loadingViewController startSpin];
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Deleting Card...";
        [self performSelector:@selector(cardDeleted) withObject:nil afterDelay:1.0];
        

        
        NSString *action = [NSString stringWithFormat:@"%@_CARD_DELETE", [self getCardType]];
        [ArcClient trackEvent:action];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.deleteCardAction" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)cardDeleted{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Deleted!" message:@"Your card was successfully deleted." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    ViewCreditCards *tmp = [[self.navigationController viewControllers] objectAtIndex:1];
    [self.navigationController popToViewController:tmp animated:YES];
}
- (NSString *)getCardType {
    @try {
        NSString *creditDebitString = @"";
        NSString *sample = [self.creditCardSample lowercaseString];
        if ([sample rangeOfString:@"credit"].location == NSNotFound) {
            creditDebitString = @"DEBIT";
        } else {
            creditDebitString = @"CREDIT";
        }
        return creditDebitString;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.getCardType" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)loadTable{

    
    @try {
        
        if ([self.creditCardExpiration length] > 5) {
            
            self.expirationText.text = [NSString stringWithFormat:@"%@/%@", [self.creditCardExpiration substringToIndex:2], [self.creditCardExpiration substringFromIndex:5]];
        }else{
            self.expirationText.text = self.creditCardExpiration;

        }
        
        @try {
            
            BOOL isAmex = NO;
            
            if ([self.displayNumber length] > 1) {
                if ([[self.displayNumber substringToIndex:2] isEqualToString:@"34"] || [[self.displayNumber substringToIndex:2] isEqualToString:@"37"]) {
                    isAmex = YES;
                }
            }
            
            if (isAmex) {

                self.cardNumberTextField.text = [NSString stringWithFormat:@"%@ %@ %@", [self.displayNumber substringToIndex:4], [self.displayNumber substringWithRange:NSMakeRange(4, 6)], [self.displayNumber substringFromIndex:10]];
                
            }else{
                  self.cardNumberTextField.text = [NSString stringWithFormat:@"%@ %@ %@ %@", [self.displayNumber substringToIndex:4], [self.displayNumber substringWithRange:NSMakeRange(4, 4)], [self.displayNumber substringWithRange:NSMakeRange(8, 4)], [self.displayNumber substringWithRange:NSMakeRange(12, 4)]];
            }
            
        }
        @catch (NSException *exception) {
            self.cardNumberTextField.text = self.displayNumber;
        }
       
      
        
        self.securityCodeTextField.text = self.displaySecurityCode;
        
        self.cardNumberTextField.delegate = self;
        self.expirationText.delegate = self;
        self.securityCodeTextField.delegate = self;
        
        self.cardNumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.expirationText.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.securityCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        
        if ([self.creditCardSample rangeOfString:@"Credit"].location != NSNotFound){
            self.cardTypesSegmentedControl.selectedSegmentIndex = 0;
        }
        
        if ([self.creditCardSample rangeOfString:@"Debit"].location != NSNotFound){
            self.cardTypesSegmentedControl.selectedSegmentIndex = 1;
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"EditCreditCard.loadTable" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
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
        
        
      //  [self.tableView setContentOffset:myPoint animated:YES];
        
        
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
     //   self.tableView.frame = CGRectMake(0, 64, 320, viewHeight);
        
        
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
        
        keyHeight = self.view.frame.size.height - 216 - 45;
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyHeight, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor whiteColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.borderColor = [dutchTopLineColor CGColor];
        self.hideKeyboardView.layer.borderWidth = 1.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        //[self.hideKeyboardView addSubview:tmpView];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpButton.frame = CGRectMake(8, 5, 69, 35);
        [tmpButton setTitle:@"Done" forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [tmpButton setTitleColor:dutchDarkBlueColor forState:UIControlStateNormal];
       // [tmpButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [tmpButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:tmpButton];
        [self.view.superview addSubview:self.hideKeyboardView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        int viewHeight = 200;
        if (self.isIphone5) {
            viewHeight = 287;
        }
       // self.tableView.frame = CGRectMake(0, 0, 320, viewHeight);
        
        
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
        
        [self.cardNumberTextField resignFirstResponder];
        [self.securityCodeTextField resignFirstResponder];
        [self.expirationText resignFirstResponder];
        [self.cardNameText resignFirstResponder];


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
        
        [self.cardNumberTextField resignFirstResponder];
        [self.securityCodeTextField resignFirstResponder];
        [self.expirationText resignFirstResponder];

        
        int pickerY = 200;
        if (self.isIphone5) {
            pickerY = 287;
        }
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, pickerY, 320, 315)];
        //self.pickerView.delegate = self;
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
        
        if ([self.securityCodeTextField.text isEqualToString:@""] && [self.cardNumberTextField.text isEqualToString:@""]){
            
            return @"empty";
        }else{
            //At least one is entered, must all be entered
            if (![self.securityCodeTextField.text isEqualToString:@""]   && ![self.cardNumberTextField.text isEqualToString:@""]){
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
       // self.tableView.frame = CGRectMake(0, 0, 320, viewHeight);
        
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AddCreditCard.endText" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
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





-(void)saveCardAction{
    
    
    if (self.cardTypesSegmentedControl.selectedSegmentIndex == -1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credit or Debit?" message:@"Please select whether this is a credit or debit card." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }else{
        
        if ([[self creditCardStatus] isEqualToString:@"valid"]) {
            
            
            if ([self luhnCheck:self.cardNumberTextField.text]) {
                
                
                [self runEdit];
                
                
                
                
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

-(void)runEdit{
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
    
    //NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];

    NSString *expiration = self.expirationText.text;
    NSString *creditDebitString = @"Credit";
    
    if ([self.cardNameText.text length] > 0) {
        creditDebitString = self.cardNameText.text;
    }
    
    NSString *cardNumber = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [mainDelegate insertCreditCardWithNumber:cardNumber andSecurityCode:self.securityCodeTextField.text andExpiration:expiration andPin:self.oldPin andCreditDebit:creditDebitString];
    
    if (self.isFromPayment) {
        CreditCardPayment *tmp = [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2];
        tmp.didEditCard = YES;
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Saving Card...";
        
        [self performSelector:@selector(cardSaved) withObject:nil afterDelay:1.0];
        
        
    }
    
}

-(void)cardSaved{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Saved!" message:@"Your card was successfully updated." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    ViewCreditCards *tmp = [[self.navigationController viewControllers] objectAtIndex:1];
    [self.navigationController popToViewController:tmp animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    @try {
        self.isDelete = NO;
        
        
        
        if (textField == self.cardNumberTextField){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                return TRUE;
            }
            
            if ([self.cardNumberTextField.text length] >= 20) {
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
            
        }else if (textField == self.securityCodeTextField){
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            
            if ([self.securityCodeTextField.text length] >= 4) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }else if (textField == self.cardNameText){
            
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            
            if ([string isEqualToString:@" "]) {
                return FALSE;
            }
            
            if ([self.cardNameText.text length] >= 10) {
                
                return FALSE;
            }
            
            
            NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
            BOOL valid = [[string stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
          
            return valid;
            
            
        }
        return TRUE;

    }
    @catch (NSException *exception) {
          [rSkybox sendClientLog:@"EditCreditCard.shouldChangeCharacters" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
  
    
}



-(void)valueChanged:(id)sender{
    
    @try {
        if (self.isIos6) {
            if (sender == self.expirationText) {
                
                [self formatExpiration];
            }else if (sender == self.cardNumberTextField){
                [self formatCreditCard];
            }else{
                
            }
        }else{
            
            if (self.shouldIgnoreValueChanged) {
                self.shouldIgnoreValueChanged = NO;
            }else{
                if (sender == self.cardNumberTextField){
                    [self formatCreditCard];
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
        [rSkybox sendClientLog:@"EditCreditCard.valueChanged" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }

    
    
}

-(void)formatCreditCard{
    
    @try {
       
        if (!self.isDelete) {
            
            
            NSString *cardNumber = self.cardNumberTextField.text;
            BOOL isAmex = NO;
            
            if ([cardNumber length] > 1) {
                if ([[cardNumber substringToIndex:2] isEqualToString:@"34"] || [[cardNumber substringToIndex:2] isEqualToString:@"37"]) {
                    isAmex = YES;
                }
            }
            
            if (isAmex) {
                
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
            
            
            
            if (!self.isIos6) {
                self.shouldIgnoreValueChanged = YES;
            }
            self.cardNumberTextField.text = cardNumber;
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"EditCreditCard.formatCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
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
                [self.securityCodeTextField becomeFirstResponder];
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
         [rSkybox sendClientLog:@"EditCreditCard.formatExpiration" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
   
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return @"Credit Card Information";
    
    
}


-(void)backspaceHit{
    
    @try {
        if (([self.securityCodeTextField.text length] == 0) && [self.securityCodeTextField isFirstResponder]) {
            [self.expirationText becomeFirstResponder];
        }else if (([self.expirationText.text length] == 0) && [self.expirationText isFirstResponder]) {
            [self.cardNumberTextField becomeFirstResponder];
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"EditCreditCard.backspaceHit" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        
        
        UITableViewCell *cell;
        
        
        if (indexPath.row == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"numberCell"];
            
            SteelfishTextFieldCreditCardiOS6 *numberText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:1];
            self.cardNumberTextField = numberText;
            self.cardNumberTextField.placeholder = @"1234 5678 9102 3456";
            self.cardNumberTextField.delegate = self;
            [self.cardNumberTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            [self.cardNumberTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            
        }else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"expCell"];
            
            SteelfishTextFieldCreditCardiOS6 *expText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:1];
            self.expirationText = expText;
            self.expirationText.placeholder = @"MM/YY";
            
            SteelfishTextFieldCreditCardiOS6 *pinText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:2];
            self.securityCodeTextField = pinText;
            self.securityCodeTextField.placeholder = @"CVV";
            
            self.securityCodeTextField.delegate = self;
            self.expirationText.delegate = self;
            
            [self.securityCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.expirationText setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            [self.securityCodeTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            [self.expirationText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            
            
            
        }
        
        
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditCreditCard.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

@end
